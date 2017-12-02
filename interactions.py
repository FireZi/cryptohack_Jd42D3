from config import wallet_address, wallet_password
from connector import contract_instance, web3

def get_end_blocks():
	result = contract_instance.getEndBlocks()
	return result

def check_to_end(index):
	web3.personal.unlockAccount(wallet_address, wallet_password)
	contract_instance.checkToEnd(index, transact={'from': wallet_address})


