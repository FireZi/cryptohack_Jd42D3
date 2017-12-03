pragma solidity ^0.4.5;

contract Exchange
{
    //token wallet
    uint [3] tokenAmount;
    address [3] tokenAddress;
    
    uint lastBlock; 
    
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
    Transaction [] transactions;
    uint [] endBlock;
    
    //coef Tokens to BTC
    uint [3] btcToken;
    
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
        Debt [] arr;
    }
    
    //queue on 2 arrays
    struct Queue
    {
        Array [2] q;
    }
    
    //queues for Tokens
    Queue [3] Debts;
    
    uint INF = 1 << 200;
    
    function Exchange(address Token0, address Token1, address Token2)
    {
        tokenAmount[0] = 0;
        tokenAmount[1] = 0;
        tokenAmount[2] = 0;
        tokenAddress[0] = Token0;
        tokenAddress[1] = Token1;
        tokenAddress[2] = Token2;
    }
    
    event SendToken(address, uint, uint8);
    
    //receive transaction
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block)
    {
        if(currencyFrom > 2 || currencyTo > 2) //check whether he send me money on token
            return;
            
        checkToUpdate();
        SendToken(msg.sender, valueFrom, currencyFrom);
        msg.sender.call(bytes4(sha3("sendToken(uint, uint)")), valueFrom, currencyFrom);
        
        Debts[currencyTo].q[0].arr.push(Debt(msg.sender, currencyFrom, valueFrom, transactions.length));
        transactions.push(Transaction(msg.sender, currencyFrom, currencyTo, valueFrom, 0, 
        Debts[currencyTo].q[0].arr.length - 1));
        endBlock.push(Block);
        tokenAmount[currencyFrom] += valueFrom;
        while(Debts[currencyFrom].q[0].arr.length + Debts[currencyFrom].q[1].arr.length != 0)
        {
            if(Debts[currencyFrom].q[1].arr.length == 0)
            {
                while(Debts[currencyFrom].q[0].arr.length != 0)
                {
                    //MEMORY
                    Debts[currencyFrom].q[1].arr.push(Debts[currencyFrom].q[0].arr[Debts[currencyFrom].q[0].arr.length - 1]);
                    delete Debts[currencyFrom].q[0].arr[Debts[currencyFrom].q[0].arr.length - 1];
                    transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions].indexQueue = 1;
                    transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions].indexArray = Debts[currencyFrom].q[1].arr.length - 1;
                }
            }
            while(Debts[currencyFrom].q[1].arr.length != 0)
            {
                if(Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions == INF)
                {
                    delete Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1];
                    continue;
                }
                if(tokenAmount[currencyFrom] <
                    Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                    btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                    btcToken[currencyFrom])
                    break; 
                //
                //----------------------------------------------------------------------------
                //
                tokenAddress[currencyFrom].call(bytes4(sha3("send(address, uint)")), Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].sender,
                Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
                    btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
                    btcToken[currencyFrom]);
                //
                //
                //
                Debts[transactions[transactions.length - 1].currencyTo].q[transactions[transactions.length - 1].indexQueue].arr[transactions[transactions.length - 1].indexArray].indexTransactions = 
                Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions;
                transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions] = 
                transactions[transactions.length - 1];
                endBlock[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions] = endBlock[transactions.length - 1];
                delete endBlock[endBlock.length - 1];
                delete transactions[transactions.length - 1];
                delete Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1];
            }
            if(
            Debts[currencyFrom].q[1].arr.length != 0 && tokenAmount[currencyFrom] <
            Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].valueFrom * 
            btcToken[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].currencyFrom] / 
            btcToken[currencyFrom])
                break;
        }
    }
    
    function deleteIndex(uint index)
    {
        checkToUpdate();
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = INF;
        transactions[index] = transactions[transactions.length - 1];
        endBlock[index ] = endBlock[endBlock.length - 1];
        delete transactions[transactions.length - 1];
        delete endBlock[endBlock.length - 1];
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = index;
    }
    
    function checkToUpdate() private {
        if (lastUpdateBlock + 100 > block.number) {
            updateCurrency();
        }
    }
    
    function updateCurrency() private {
        ToOracleUpdate();
    }
    
    function currencyFromOracle(uint token0, uint token1, uint token2) {
        btcToken[0] = token0;
        btcToken[1] = token1;
        btcToken[2] = token2;
    }
}
