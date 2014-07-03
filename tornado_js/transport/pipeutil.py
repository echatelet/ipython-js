"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

from tornado.ioloop import IOLoop
from tornado_js.transport.pipeioloop import InterceptPipeIOLoop
import tornado.netutil

def intercept_add_accept_handler(sock, callback, io_loop=None):

    print("Inside remap_add_accept_handler")
    if io_loop is None:
        io_loop = InterceptPipeIOLoop.current()

    def accept_handler(fd, events):
        while True:
            callback(sock)
    io_loop.add_handler(sock, accept_handler, IOLoop.READ)

