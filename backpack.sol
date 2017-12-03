pragma solidity ^0.4.5;
import "Token0.sol";
import "Token1.sol";
import "Token2.sol";
import "Exchange.sol";

contract backpack
{
    address exchange_address; // example address
    address Token0_address;
    address Token1_address; 
    address Token2_address;
    address contract_owner;
    
    function backpack(address _exchange_address, address _Token0_address,
                      address _Token1_address, address _Token2_address, address _contract_owner) {
         exchange_address = _exchange_address;
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
            Token0 buffer = Token0(Token0_address);
            buffer.send(exchange_address, amount);
        }
        if (value == 1) {
            Token1 buffer = Token1(Token1_address);
            buffer.send(exchange_address, amount);
        }
        if (value == 2) {
            Token2 buffer = Token2(Token2_address);
            buffer.send(exchange_address, amount);
        }
    }
    
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block) {
        if (msg.sender != contract_owner) {
            return;
        }
        Exchange ex = Exchange(exchange_address);
        ex.transfer(currencyFrom, currencyTo, valueFrom, Block);
    }

}
