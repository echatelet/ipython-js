"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

from tornado.httpserver import HTTPConnection 
import tornado.httpserver

class InterceptHTTPConnection(HTTPConnection):

    def __init__(self, stream, address, request_callback, no_keep_alive=False,
                 xheaders=False, protocol=None):
        self.stream = stream
        self.address = address
        # Save the socket's address family now so we know how to
        # interpret self.address even after the stream is closed
        # and its socket attribute replaced with None.
        self.address_family = stream.socket.family
        self.request_callback = request_callback
        self.no_keep_alive = no_keep_alive
        self.xheaders = xheaders
        self.protocol = protocol
        self._clear_request_state()
        # Save stack context here, outside of any request.  This keeps
        # contexts from one request from leaking into the next.
        # self._header_callback = stack_context.wrap(self._on_headers)
        self._header_callback = self._on_headers
        self.stream.set_close_callback(self._on_connection_close)
        self.stream.read_until(b"\r\n\r\n", self._header_callback)

