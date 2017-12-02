from time import sleep
from interactions import get_end_blocks, check_to_end
from connector import web3


class Server:

    def __init__(self):
        self.current_block = web3.eth.blockNumber

    def request_blocks_data(self):
        return get_end_blocks()

    def send_response(self, overdue_blocks):
        check_to_end(overdue_blocks)

    def get_overdue_data(self, data):
        return [i for i in range(len(data)) if data[i] <= self.current_block]

    def run(self):
        while True:
            self.current_block = web3.eth.blockNumber
            blocks_data = self.request_blocks_data()
            overdue_blocks = self.get_overdue_data(blocks_data)
            self.send_response(overdue_blocks)
            sleep(1)


if __name__ == '__main__':
    print('run server...')
    server = Server()
    server.run()
