pragma solidity ^0.4.5;

contract Exchange
{
    //token wallet
    uint [3] tokenAmount;
    
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
    
    function Exchange()
    {
        tokenAmount[0] = tokenAmount[1] = tokenAmount[2] = 0;
        lastBlock = 0;
        checkCoef();
    }
    
    function checkCoef()
    {
        if(block.number - lastBlock < 10)
            return;
        lastBlock = block.number;
        //
        //
        //HERE PLEASE WORK WITH ORAKUL AND MAKE ETHEREUM GREAT AGAIN
        //
        //
    }
    
    //receive transaction
    function transfer(uint8 currencyFrom, uint8 currencyTo, uint valueFrom, uint Block)
    {
        if(currencyFrom > 2 || currencyTo > 2) //check whether he send me money on token
            return;
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
                //как послать команду токену на перевод валюты с нашего кошелька на его кошелек
                //----------------------------------------------------------------------------
                //
                //
                //
                //
                Debts[transactions[transactions.length - 1].currencyTo].q[transactions[transactions.length - 1].indexQueue].arr[transactions[transactions.length - 1].indexArray].indexTransactions = 
                Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions;
                transactions[Debts[currencyFrom].q[1].arr[Debts[currencyFrom].q[1].arr.length - 1].indexTransactions] = 
                transactions[transactions.length - 1];
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
        checkCoef();
    }
    function deleteIndex(uint index)
    {
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = INF;
        transactions[index] = transactions[transactions.length - 1];
        delete transactions[transactions.length - 1];
        Debts[transactions[index].currencyTo].q[transactions[index].indexQueue].arr[transactions[index].indexArray].indexTransactions = index;
    }
}
