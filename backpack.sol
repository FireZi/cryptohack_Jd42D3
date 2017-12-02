pragma solidity ^0.4.5;

contract backpack
{
    uint exchange_adress; // example address
    uint Token0_address;
    uint Token1_address; 
    uint Token2_address;
    uint contract_owner;
    
    function backpack(uint _exchange_adress, uint _Token0_address,
                      uint _Token1_address, uint _Token2_address, uint _contract_owner) {
         exchange_adress = _exchange_adress;
         Token0_address = _Token0_address;
         Token1_address = _Token1_address;
         Token2_address = _Token2_address;
         contract_owner = _contract_owner;
    }                  
    
    function sendToken(uint receiver, uint amount, uint value) {
        if (msg.sender != exchange_adress && msg.sender != contract_owner) {
            return;
        }
        
        if (value == 0) {
            Token0 buffer = Token0(Token0_address);
            buffer.send(receiver, amount);
        }
        if (value == 1) {
            Token1 buffer = Token1(Token1_address);
            buffer.send(receiver, amount);
        }
        if (value == 2) {
            Token2 buffer = Token2(Token2_address);
            buffer.send(receiver, amount);
        }
    }
    
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block) {
        Exchange ex = Exchange(exchange_adress);
        ex.transfer(currencyFrom, currencyTo, valueFrom, Block);
    }

}
