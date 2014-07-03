"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

import errno
import os

from tornado_js.transport.pipeioloop import InterceptPipeIOLoop
from tornado.iostream import BaseIOStream
from tornado import stack_context
import tornado.iostream
import collections

class fake_socket(object):

    def __init__(self):
        self.family = 4

class InterceptPipeIOStream(BaseIOStream):

    def __init__(self, read_fd, write_fd, io_loop, *args, **kwargs):
        
        self.socket = fake_socket()
        self.read_socket = read_fd
        self.write_socket = write_fd
        super(BaseIOStream, self).__init__(*args, **kwargs)
        self._pending_callbacks = 0
        self.io_loop = io_loop or InterceptPipeIOLoop.current()
        self._closed = False
        self._read_until_close = False
        self._state = None
        self._read_buffer = collections.deque() 
        self._write_buffer = collections.deque()

    def fileno(self):
        return self.read_socket # self.socket.fileno()

    def close_fd(self):
        os.close(self.read_socket) 
        os.close(self.write_socket)
        self.read_socket = None

    def get_fd_error(self):
        return -1 # this might trigger a button

    def safe_read(self, fd, size=1024):
        try:
            return os.read(fd, size)
        except OSError, exc:
            print(str(exc))
            if exc.errno == errno.EAGAIN:
                return None
            raise

    def read_request(self):
        print("Inside read_request function.")
        read_char = ""
        data = ""
        data_list = []
        finished_reading = False
        while not finished_reading:
            try:
                # return os.read(fd, size)
                data_list.append(os.read(self.read_socket, 1))

                # Very inefficient, but simple
                start_position = len(data_list) - len(self._read_delimiter)
                last_chunk = data_list[start_position:]
                last_bytes_read = "".join(last_chunk)
                if last_bytes_read == self._read_delimiter:
                    finished_reading = True
            except OSError, exc:
                if exc.errno == errno.EAGAIN:
                    return None
                raise
        data = "".join(data_list)

        # We apparently need to lstrip the data because an extra newline
        # sneaks in. This is necessary for our pipe tests but we should delete
        # it once we do Javascript
        data = data.lstrip()
        print("Read request:" +str(data))

        return data

    def _run_callback(self, callback, *args):
        callback(*args)

    def read_until(self, delimiter, callback):
        """Run ``callback`` when we read the given delimiter.

        The callback will get the data read (including the delimiter)
        as an argument.
        """
        self._set_read_callback(callback)
        self._read_delimiter = delimiter
        self._try_inline_read()
        data = self._read_buffer.pop()
        self._run_callback(callback, data)

    def _read_from_buffer(self):
        """Attempts to complete the currently-pending read from the buffer.

        Returns True if the read was completed.
        """
        data = self.read_request() 
        self._read_buffer.append(data)
        return True

    def _set_read_callback(self, callback):
        self._read_callback = stack_context.wrap(callback)

    def write(self, data, throwaway):
        self.write_to_fd(data)

    def write_to_fd(self, data):
        return os.write(self.write_socket,data)

    def _check_closed(self): pass
    def connect(self, address, callback=None, server_hostname=None): pass
    def _handle_connect(self): pass
    def set_nodelay(self, value): pass

