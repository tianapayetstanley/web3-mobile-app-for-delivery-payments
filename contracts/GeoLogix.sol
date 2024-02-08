// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./trigonometry.sol";

contract GeoLogix
{
    //Set of States
    enum StateType { Created, InTransit, Completed}
    // enum SensorType { None, Humidity, Temperature }

    //List of properties
    StateType public  state;
    address public  company; // aka owner
    address public  device;
    address public  driver;

    struct RequiredCheckpoint{
        int lat;
        int lng;
        uint timestamp;
    }

    RequiredCheckpoint[] public requiredCheckpoints;
    RequiredCheckpoint[] public compliance;
    RequiredCheckpoint[] public nonCompliance;


    constructor(address _device, address _company, address _driver) payable {
        // Ensure that at least 5 Ether is sent to the contract upon creation
        require(msg.value >= 5 ether, "Minimum 5 Ether required");
        company = _company;
        device = _device;
        driver = _driver; 
        state = StateType.Created;
    }

    // modifier that checks the current user calling the contract function is the owner
    modifier onlyOwner(){
        require(msg.sender == company);
        _;
    }

    function addRequiredCheckpoint(uint _lat, uint _lng, uint _timestamp) public onlyOwner{
        RequiredCheckpoint memory checkpoint = RequiredCheckpoint(_lat, _lng, _timestamp);
        requiredCheckpoints.push(checkpoint);
        // initially add all checkpoints to non-compliance list
        nonCompliance.push(checkpoint);
    }
 

    function IngestTelemetry(int _lat, int _lng, int _timestamp) public
    {
        // Separately check for states and sender 
        // to avoid not checking for state when the sender is the device
        // because of the logical OR
        if ( state == StateType.Completed )
        {
            revert();
        }

        if (device != msg.sender)
        {
            revert();
        }

        state = StateType.InTransit;

        // check if the coordinate is within a checkpoint of 100m and if true 
        // returns true and the index of the required checkpoint index
        (bool isCoordinateWithinACheckpointResult, uint index) = isCoordinateWithinACheckpoint(_lat, _lng);
        if(!isCoordinateWithinACheckpointResult){
            revert();
        }else{
            RequiredCheckpoint memory requiredChekpoint = requiredCheckpoints[index];
            // check if the time difference is after a max of 5 minutes from the defined checkpoint
            if( _timestamp > requiredChekpoint.timestamp + 300){
                revert();
            }

            // else remove from non-compliance and add to compliance
            nonCompliance.remove(index);
            compliance.push(RequiredCheckpoint(_lat, _lng, _timestamp));
        }

       
    }

    function isCoordinateWithinACheckpoint(int _lat,int _lng) internal view returns (bool,int){
        for (uint256 i = 0; i < requiredCheckpoints.length; i++) {
            RequiredCheckpoint memory checkpoint = requiredCheckpoints[i];
            // if the coordinate is within 100 meters of the checkpoint
            if (calculateDistance(_lat, _lng, checkpoint.lat, checkpoint.lng) <=100){
                return (true,i);
            }
        } 
        return (false,-1);
    }



    function calculateDistance(int _lat1, int _lng1, int _lat2, int _lng2) internal pure returns (uint256) {
        uint p = 0.017453292519943295;
        int a = 0.5 - Trigonometry.cos((_lat2 - _lat1) * p)/2 + 
            Trigonometry.cos(_lat1 * p) * Trigonometry.cos(_lat2 * p) * 
            (1 - Trigonometry.cos((_lng2 - _lng1) * p))/2;

        int distance = 12742 * Math.asin(Math.sqrt(a));
        return distance; //meters
    }

    function complete() public payable onlyOwner{
        // keep the state checking, message sender, and device checks separate
        // to not get cloberred by the order of evaluation for logical OR
        if ( state == StateType.Completed ){
            // no need to transfer again
            revert();
        }

        // calculate how many compliance are there, and 
        // if >= 75% transfer all the balance to driver,
        // >=50% transfer 3 ether to driver,
        // <50% transfer the balance to the owner
        if(compliance.length >= requiredCheckpoints.length * 0.75){
            // transfer all balance
            payable(driver).transfer(address(this).balance);
        }else if(compliance.length >= requiredCheckpoints.length * 0.5){
            // transfer 3 ether
            payable(driver).transfer(3 ether);
        }else{
            // transfer balance to company from the contract
            payable(company).transfer(address(this).balance);
        }
       
        state = StateType.Completed;
        
    }

    // useful for when a function that doesn’t exist or match any function in a contract is called
    // and if some ether is sent to it, it'll add it to the contract balance
    fallback() external payable{}
}