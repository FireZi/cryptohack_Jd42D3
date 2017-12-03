pragma solidity ^0.4.5;

contract backpack
{
    address exchange_address; // example address
    address Token0_address;
    address Token1_address; 
    address Token2_address;
    address contract_owner;
    
    function backpack(address _exchange_address, address _Token0_address,
                      address _Token1_address, address _Token2_address, address _contract_owner) {
         exchange_address = exchange_address;
         Token0_address = _Token0_address;
         Token1_address = _Token1_address;
         Token2_address = _Token2_address;
         contract_owner = _contract_owner;
    }                  
    
    function sendToken(uint amount, uint value) {
        if (msg.sender != exchange_address && msg.sender != contract_owner) {
            return;
        }
        
        if (value == 0) {
            Token0_address.call(bytes4(sha3("send(address, uint)")), exchange_address, amount);
        }
        if (value == 1) {
            Token1_address.call(bytes4(sha3("send(address, uint)")), exchange_address, amount);
        }
        if (value == 2) {
            Token2_address.call(bytes4(sha3("send(address, uint)")), exchange_address, amount);
        }
    }
    
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block) {
        if (msg.sender != contract_owner) {
            return;
        }
        exchange_address.call(bytes4(sha3("transfer(uint8, uint8, uint, uint)")), currencyFrom, currencyTo, valueFrom, Block);
    }

}
