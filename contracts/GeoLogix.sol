// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract GeoLogix
{
    //Set of States
    enum StateType { Created, InTransit, Completed}

    StateType public  state;
    address public  company; // aka owner
    address public  device;
    address public  driver;

    struct Checkpoint{
        uint id;
        int lat;
        int lng;
        uint distance;
        uint timestamp;
    }

   Checkpoint[] public checkpoints;
   Checkpoint[] public compliance;
   Checkpoint[] public nonCompliance;


    constructor(address _device, address _company, address _driver) payable {
        // Ensure that at least 0.005 Ether is sent to the contract upon creation
        require(msg.value >= 0.005 ether, "Minimum 0.005 Ether required");
        company = _company;
        device = _device;
        driver = _driver; 
        state = StateType.Created;
    }

    // modifier that checks the current user calling the contract function is the owner
    modifier onlyOwner(){
        require(msg.sender == company, "Account must be company/owner");
        _;
    }

    function addCheckpoint(uint _id, int _lat, int _lng, uint _distance, uint _timestamp) public onlyOwner{
        Checkpoint memory checkpoint = Checkpoint(_id,_lat, _lng,_distance, _timestamp);
        checkpoints.push(checkpoint);
    }
 

    function IngestTelemetry(uint _id,int _lat, int _lng, uint _distance, uint _timestamp) public{
        // if the state is already completed, no more telemetry can be ingested
        require(state != StateType.Completed,"State already completed" );
        require(device == msg.sender,"Account not from Device");

        state = StateType.InTransit;

        // find the index of a checkpoint given a timestamp and return an index
         int index = findACheckpointGivenAnId(_id);
        if(index == -1){
            nonCompliance.push(Checkpoint(_id,_lat, _lng,_distance, _timestamp));
        }else{
            Checkpoint memory checkpoint = checkpoints[uint256(index)];
            // check if the distance is greater than the distance of the checkpoint outlined or the timestamp is 5 minutes(300,000 milliseconds) or more after the timestamp of the checkpoint
            if( _distance > checkpoint.distance ||  
            (_timestamp > checkpoint.timestamp + 300000)){
                nonCompliance.push(Checkpoint(_id,_lat, _lng,_distance, _timestamp));
            }else{
            compliance.push(Checkpoint(_id,_lat, _lng,_distance, _timestamp));
            }
        }

       
    }

    function findACheckpointGivenAnId(uint _id) internal view returns (int){
        for (uint256 i = 0; i < checkpoints.length; i++) {
            Checkpoint memory checkpoint = checkpoints[i];
            if (_id == checkpoint.id){
                return int(i);
            }
        } 
        return -1;
    }



    function complete() public payable onlyOwner{

       require(state != StateType.Completed,"State already completed");
       
        // calculate how many compliance are there, and 
        // if >= 75% transfer all the balance to driver,
        // >=50% transfer 0.003 ether to driver,
        // <50% transfer the balance to the owner
        if(compliance.length >= checkpoints.length *3/4){
            // transfer all balance
            payable(driver).transfer(address(this).balance);
        }else if(compliance.length >= checkpoints.length * 1/2){
            // transfer 0.003 ether
            payable(driver).transfer(0.003 ether);
            payable(company).transfer(address(this).balance - 0.003 ether);
        }else{
            // transfer balance to company from the contract
            payable(company).transfer(address(this).balance);
        }
       
        state = StateType.Completed;
        
    }

    
}