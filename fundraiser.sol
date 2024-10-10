// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract fundraise{
    mapping (address=>uint) public contributors;
    address public manager;
    uint public mincontri;
    uint public deadline;
    uint public target;
    uint public raised;
    uint public noofcontris;
    struct request{
    string desc;
    address payable rec;
    uint val;
    bool completed;
    uint noofvoters;
    mapping (address=>bool) voters;
    }
    mapping (uint=>request) public reqs;
    uint public noofreqs;
    constructor(uint t,uint dl){
        target=t;
        deadline=block.timestamp + dl;
        mincontri=1 ether;
        manager=msg.sender;
    }
    function sendeth() public payable {
        require(block.timestamp<deadline,"aipay");
        require(msg.value>=mincontri,"bhikari");
        raised+=msg.value;
        if(contributors[msg.sender]==0){
            noofcontris++;
        }
        contributors[msg.sender]+=msg.value;
    }
    function getbal() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raised<target);
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
    }
    modifier onlymanager(){
        require(msg.sender==manager,"Only manager");
        _;
    }
    function createreq(string memory desc,address payable ad,uint amount) public onlymanager{
    request storage create=reqs[noofreqs]; 
    noofreqs++;
    create.desc=desc;
    create.val=amount;
    create.noofvoters=0;
    create.rec=ad;
    create.completed=false;
    }
    function votereq(uint reqno) public{
    require(contributors[msg.sender]>0,"You must contribute");
    request storage thisreq=reqs[reqno]; 
    require(thisreq.voters[msg.sender]==false,"you have voted");
    thisreq.voters[msg.sender]==true;
    thisreq.noofvoters++;
    }
    function makepayment(uint reqno) public onlymanager{
        require(raised>=target);
        request storage thisreq=reqs[reqno]; 
        require(thisreq.completed==false,"already completed");
        require(thisreq.noofvoters>noofcontris/2,"rejected");
        thisreq.rec.transfer(thisreq.val);
        thisreq.completed=true;
    } 
}
