 pragma solidity ^0.4.0;
contract Token0
{
    mapping (address => uint) balances;
    function give(uint amount)
    {
        balances[msg.sender] += amount;
    }
    function send(address receiver, uint amount)
    {
        if(balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }
    function queryBalance(address addr) constant returns (uint balance)
    {
        balance = balances[addr];
    }
}
