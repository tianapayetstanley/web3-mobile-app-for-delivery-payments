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

   
   mapping(uint => Checkpoint) public checkpointsMap;
   mapping(uint => Checkpoint) public compliancesMap;
   mapping(uint => Checkpoint) public nonCompliancesMap;

   uint[] checkpointIds;
   uint[] complianceIds;
   uint[] nonComplianceIds;

   uint public checkpointId = 0;


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

    function addCheckpoint( int _lat, int _lng, uint _distance, uint _timestamp) public onlyOwner{
        Checkpoint memory checkpoint = Checkpoint(checkpointId,_lat, _lng,_distance, _timestamp);
        checkpointsMap[checkpointId] = checkpoint;
        checkpointIds.push(checkpointId);
        checkpointId++;
    }

    function getCheckpointIds() public view returns (uint[] memory){
        return checkpointIds;
    }

    function getComplianceIds() public view returns (uint[] memory){
        return complianceIds;
    }

    function getNonComplianceIds() public view returns (uint[] memory){
        return nonComplianceIds;
    }
 

    function IngestTelemetry(uint _id,int _lat, int _lng, uint _distance, uint _timestamp) public{
        // if the state is already completed, no more telemetry can be ingested
        require(state != StateType.Completed,"State already completed" );
        require(device == msg.sender,"Account not from Device");

        state = StateType.InTransit;

        // find a checkpoint given an id
        Checkpoint memory checkpoint = checkpointsMap[_id];
       
        // check if the distance is greater than the distance of the checkpoint outlined or the timestamp is 5 minutes(300,000 milliseconds) or more after the timestamp of the checkpoint
        // commented out the timestamp code  for sake of simplicity
        if( _distance > checkpoint.distance ||  (_timestamp > checkpoint.timestamp + 300000)){
            nonCompliancesMap[_id] = Checkpoint(_id,_lat, _lng,_distance, _timestamp);
            nonComplianceIds.push(_id);
        }else{
            compliancesMap[_id] = Checkpoint(_id,_lat, _lng,_distance, _timestamp);
            complianceIds.push(_id);
        }
        
    }

    



    function complete() public payable onlyOwner{

       require(state != StateType.Completed,"State already completed");
       
        // calculate how many compliance are there, and 
        // if >= 75% transfer all the balance to driver,
        // >=50% transfer 0.003 ether to driver,
        // <50% transfer the balance to the owner
        if(complianceIds.length >= checkpointIds.length *3/4){
            // transfer all balance
            payable(driver).transfer(address(this).balance);
        }else if(complianceIds.length >= checkpointIds.length * 1/2){
            // transfer 0.003 ether
            payable(driver).transfer(0.003 ether);
            payable(company).transfer(address(this).balance - 0.003 ether);
        }else{
            // transfer balance to company from the contract
            payable(company).transfer(address(this).balance);
        }
       
        state = StateType.Completed;
        
    }

    // can be called by the company if its necessary to start from scratch
    function resetEverything() public onlyOwner{
        state = StateType.Created;
        for (uint i = 0; i < checkpointIds.length; i++){
            delete checkpointsMap[checkpointIds[i]];
        }
        for (uint i = 0; i < complianceIds.length; i++){
            delete compliancesMap[complianceIds[i]];
        }

        for (uint i = 0; i < nonComplianceIds.length; i++){
            delete nonCompliancesMap[nonComplianceIds[i]];
        }

        
        delete  checkpointIds ;
       delete complianceIds ;
       delete nonComplianceIds ;
       
        checkpointId = 0;
    }

}