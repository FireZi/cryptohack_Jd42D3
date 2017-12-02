pragma solidity ^0.4.5;

contract backpack
{
    uint exchange_adress = 0x123456; // example address
    uint Token0_address = 0x234567; 
    uint Token1_address = 0x345678;
    uint Token2_address = 0x456789;
    
    
    function sendToken(uint receiver, uint amount, uint value) {
        if (msg.sender != exchange_adress) return;
        
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

}
