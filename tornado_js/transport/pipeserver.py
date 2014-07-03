"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

import os
import socket

from tornado_js.transport.pipeioloop import InterceptPipeIOLoop
from tornado_js.transport.pipeiostream import InterceptPipeIOStream
from tornado_js.transport.pipeutil import intercept_add_accept_handler
from tornado import stack_context
import tornado.tcpserver

class InterceptPipeServer(object):

    def __init__(self,io_loop=None, ssl_options=None, max_buffer_size=None):
        print("Running __init__ in replacement server.")
        self.io_loop = None 
        self._sockets = {}  
        self._started = False
        self._address = ""
        self._port = None
 
    def initialize(self, io_loop=None, ssl_options=None, max_buffer_size=None):
        self.io_loop = io_loop

    def listen(self, port, address=""):
        self.bind(port, address)

    def add_sockets(self, sockets):
        if self.io_loop is None:
            self.io_loop = InterceptPipeIOLoop.current()
        for sock in sockets:
            self._sockets[sock] = sock
            intercept_add_accept_handler(sock, self._handle_connection,io_loop=self.io_loop)

    def add_socket(self, socket):
        self.add_sockets([socket])

    def bind(self, port, address=None, family=socket.AF_UNSPEC, backlog=128):
        self._port = port
        self._address = address
        server_file_path = "/tmp/server_" + str(port) + ".pipe"
        client_file_path = "/tmp/client_" + str(port) + ".pipe"
        if not os.path.exists(server_file_path): os.mkfifo(server_file_path)
        if not os.path.exists(client_file_path): os.mkfifo(client_file_path)
        server_pipe_fd = os.open(server_file_path, os.O_RDONLY) 
        self.add_socket(server_pipe_fd)

        return server_pipe_fd
 
    def start(self, num_processes=1):
        self._started = True

    def stop(self):
        for socket,extra in self._sockets:
            os.close(socket)

    def handle_stream(self, stream, address):
        # We have to import this locally, otherwise it will bring in the httpserver
        # definition before we remap the TCPServer class
        from tornado_js.httpserver import InterceptHTTPConnection
        InterceptHTTPConnection(stream, address, self.request_callback,
                       self.no_keep_alive, self.xheaders, self.protocol)

    def _handle_connection(self, fd):
        try:
            client_fd = os.open("/tmp/client_" + str(self._port) + ".pipe", os.O_WRONLY)
        except (Exception,EnvironmentError) as e:
            raise
        stream = InterceptPipeIOStream(fd, client_fd,self.io_loop)
        try:
            self.handle_stream(stream, self._address)
        except(OSError, IOError) as e:
            raise
 

