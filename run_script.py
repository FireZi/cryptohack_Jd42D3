from connector import web3
from web3.contract import ConciseContract

token_addresses = [3]


def load_tokens(id):
    contract_fs = open('Token' + id + '.sol', 'r')
    contract_source_code = ''.join(contract_fs.readlines())
    compiled_sol = compile_source(contract_source_code)
    contract_interface = compiled_sol['<stdin>:Token' + id]
    tx_hash = contract.deploy(transaction={'from': exchange_wallet})
    tx_receipt = web3.eth.getTransactionReceipt(tx_hash)
    token_addresses[id] = tx_receipt['contractAddress']
    print('Token' + id + ' uploaded on ' + token_addresses[0])


wallet_pass = '123'
exchange_wallet = '0x1c7202902d04843280A0678DFE09653ad225BDA0'
client_wallet = '0xC63C28787599Dac33C6AE1C7957d92215CdeadFF'
web3.personal.unlockAccount(exchange_wallet, wallet_pass);
web3.personal.unlockAccount(client_wallet, wallet_pass);

load_tokens(0)
load_tokens(1)
load_tokens(2)

contract_fs = open('Exchange.sol', 'r')
contract_source_code = ''.join(contract_fs.readlines())
compiled_sol = compile_source(contract_source_code)
contract_interface = compiled_sol['<stdin>:Exchange']
tx_hash = contract.deploy(transaction={'from': exchange_wallet},
                          args={token_addresses[0], token_addresses[1], token_addresses[2]})
tx_receipt = web3.eth.getTransactionReceipt(tx_hash)

exchange_address = tx_receipt['contractAddress']
print('Exchange uploaded on ' + exchange_address)


contract_fs = open('backpack.sol', 'r')
contract_source_code = ''.join(contract_fs.readlines())
compiled_sol = compile_source(contract_source_code)
contract_interface = compiled_sol['<stdin>:backpack']
tx_hash = contract.deploy(transaction={'from': exchange_wallet},
                          args={exchange_address, token_addresses[0], token_addresses[1], token_addresses[2], client_wallet})
backpack_address = web3.eth.getTransactionReceipt(tx_hash)
print('Backpack uploaded on ' + backpack_address)

