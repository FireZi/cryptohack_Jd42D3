from solc import compile_source
from web3 import Web3, HTTPProvider
from web3.contract import ConciseContract
from config import contract_address

contract_fs = open('Exchange.sol', 'r')
contract_source_code = ''.join(contract_fs.readlines())

compiled_sol = compile_source(contract_source_code)
contract_interface = compiled_sol['<stdin>:Exchange']

web3 = Web3(HTTPProvider('http://localhost:8545'))

contract_instance = web3.eth.contract(abi=contract_interface['abi'], address=contract_address,
                                      ContractFactoryClass=ConciseContract)
