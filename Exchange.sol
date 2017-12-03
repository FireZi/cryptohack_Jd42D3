pragma solidity ^0.4.5;
import "Token0.sol";
import "Token1.sol";
import "Token2.sol";
import "backpack.sol";

contract Exchange
{
    //token wallet
    uint[3] public tokenAmount;
    address[3] public tokenAddress;
    
    //node for transactions
    struct Transaction
    {
        address sender;
        uint8 currencyFrom;
        uint8 currencyTo;
        uint valueFrom;
        uint8 indexQueue;
        uint indexArray;
    }
    
    //two different array for local testing machine
    Transaction[] public transactions;
    uint[] public endBlock;
    
    //coef Tokens to BTC
    uint[3] public btcToken;
    
    event ToOracleUpdate();
    uint lastUpdateBlock = 0;
    
    //queue node
    struct Debt
    {
       address sender;
       uint8 currencyFrom;
       uint valueFrom;
       uint indexTransactions;
    }
    
    struct Array
    {
        Debt[] arr;
    }
    
    //queue on 2 arrays
    struct Queue
    {
        Array[2] q;
    }
    
    //queues for Tokens
    Queue [3] Debts;
    
    uint INF = 1 << 200;
    
    function Exchange(address Token0_address, address Token1_address, address Token2_address)
    {
        tokenAmount[0] = 0;
        tokenAmount[1] = 0;
        tokenAmount[2] = 0;
        tokenAddress[0] = Token0_address;
        tokenAddress[1] = Token1_address;
        tokenAddress[2] = Token2_address;
    }
    
    event SendToken(address, uint, uint8);
    
    //receive transaction
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block) public
    {
        if(currencyFrom > 2 || currencyTo > 2) //check whether he send me money on token
            return;
        //SENDING MONEY HERE
        checkToUpdate();
        SendToken(msg.sender, valueFrom, currencyFrom);
        backpack bp = backpack(msg.sender);
        bp.sendToken(valueFrom, currencyFrom);
        //----------------------------
        Debts[currencyTo].q[0].arr.push(Debt(msg.sender, currencyFrom, valueFrom, transactions.length));
        transactions.push(Transaction(msg.sender, currencyFrom, currencyTo, valueFrom, 0, 
        Debts[currencyTo].q[0].arr.length - 1));
        endBlock.push(Block);
        tokenAmount[currencyFrom] += valueFrom;
        for(int i = 0; i < 2; i++)
        {
        while(Debts[currencyFrom].q[0].arr.length + Debts[currencyFrom].q[1].arr.length != 0)
        {
            if(Debts[currencyFrom].q[1].arr.length == 0)
            {
                while(Debts[currencyFrom].q[0].arr.length != 0)
                {
                    //MEMORY
                    Debts[currencyFrom].q[1].arr.push(Debts[currencyFrom].q[0].arr[Debts[currencyFrom].q[0].arr.length - 1]);
                    delete Debts[currencyFrom].q[0].arr[Debts[currencyFrom].q[0].arr.length - 1];
                    Debts[currencyFrom].q[0].arr.length--;
                    transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions].indexQueue = 1;
                    transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions].indexArray = Debts[currencyFrom].q[1].arr.length - 1;
                }
            }
            while(Debts[currencyFrom].q[1].arr.length != 0)
            {
                if(Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions == INF)
                {
                    delete Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1];
                    Debts[currencyFrom].q[1].arr.length--;
                    continue;
                }
                if(tokenAmount[currencyFrom] <
                    Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                    btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                    btcToken[currencyFrom])
                    break; 
                tokenAmount[currencyFrom] -= Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                    btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                    btcToken[currencyFrom];
                //SENDMONEY MONEY HERE
                    if (currencyFrom == 0) {
                        Token0(tokenAddress[0]).send(Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].sender,
                        Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                        btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                        btcToken[currencyFrom]);
                    }
                    
                    if (currencyFrom == 1) {
                        Token0(tokenAddress[1]).send(Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].sender,
                        Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                        btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                        btcToken[currencyFrom]);
                    }
                    
                    if (currencyFrom == 2) {
                        Token2(tokenAddress[2]).send(Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].sender,
                        Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                        btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                        btcToken[currencyFrom]);                 
                    }
                //
                Debts[transactions[transactions.length - 1].currencyTo].q[transactions[transactions.length - 1].indexQueue].arr[transactions[transactions.length - 1].indexArray].indexTransactions = 
                Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions;
                transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions] = 
                transactions[transactions.length - 1];
                endBlock[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions] = endBlock[transactions.length - 1];
                delete endBlock[endBlock.length - 1];
                endBlock.length--;
                delete transactions[transactions.length - 1];
                transactions.length--;
                delete Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1];
                Debts[currencyFrom].q[1].arr.length--;
            }
            if(
            Debts[currencyFrom].q[1].arr.length != 0 && tokenAmount[currencyFrom] <
            Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
            btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
            btcToken[currencyFrom])
                break;
        }
        currencyFrom = currencyTo;
        }
    }
    
    function deleteIndex(uint index) private
    {
        checkToUpdate();
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = INF;
        transactions[index] = transactions[transactions.length - 1];
        endBlock[index ] = endBlock[endBlock.length - 1];
        delete transactions[transactions.length - 1];
        delete endBlock[endBlock.length - 1];
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = index;
    }

    function checkToDelete(uint index) {
        if (endBlock[index] > block.number) {
            deleteIndex(index);
        }
    }

    function getEndBlock() constant returns (uint[] endBlocks) {
        endBlocks = endBlock;
    }
    
    function checkToUpdate() private {
        if (lastUpdateBlock + 100 < block.number) {
            lastUpdateBlock = block.number;
            updateCurrency();
        }
    }
    
    function updateCurrency() private {
        ToOracleUpdate();
    }
    
    function currencyFromOracle(uint token0, uint token1, uint token2) public {
        btcToken[0] = token0;
        btcToken[1] = token1;
        btcToken[2] = token2;
    }
}