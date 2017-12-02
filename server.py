from time import sleep


class Server:

    def __init__(self):
        self.current_block = 0

    def request_blocks_data(self):
        tmp_blocks_arr = [12, 13, 12, 11, 14, 13]
        return tmp_blocks_arr

    def send_response(self, overdue_blocks):
        pass

    def get_overdue_data(self, data):
        return [i for i in range(len(data)) if data[i] <= self.current_block]

    def run(self):
        while True:
            blocks_data = self.request_blocks_data()
            overdue_blocks = self.get_overdue_data(blocks_data)
            self.send_response(overdue_blocks)
            self.current_block += 1
            sleep(1)


if __name__ == '__main__':
    print('run server...')
    server = Server()
    server.run()
