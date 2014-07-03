"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

import errno
import select
import threading
import time
import traceback,sys
 
from tornado import stack_context
from tornado.ioloop import IOLoop
import tornado.ioloop
import tornado.platform.epoll

class InterceptPipeIOLoop(IOLoop):

    def __init__(self,impl=select.epoll(), time_func=None):

        print("Remapping IOLoop!")
        self._impl=impl
        self.time_func = time_func or time.time
        self._handlers = {}
        self._events = {}
        self._callbacks = []
        self._callback_lock = threading.Lock()
        self._timeouts = []
        self._cancellations = 0
        self._running = False
        self._stopped = False
        self._blocking_signal_threshold = None

    def install(self):
        assert not InterceptPipeIOLoop.initialized()
        InterceptPipeIOLoop._instance = self

    @staticmethod
    def initialized():
        """Returns true if the singleton instance has been created."""
        return hasattr(InterceptPipeIOLoop, "_instance")

    def add_callback(self, callback, *args, **kwargs):
        raise NotImplementedError()

    def start(self):
        self._running = True
        while True:
            poll_timeout = 3600.0

            # Prevent IO event starvation by delaying new callbacks
            # to the next iteration of the event loop.
            with self._callback_lock:
                callbacks = self._callbacks
                self._callbacks = []
            for callback in callbacks:
                self._run_callback(callback)

            if self._callbacks:
                # If any callbacks or timeouts called add_callback,
                # we don't want to wait in poll() before we run them.
                poll_timeout = 0.0

            if not self._running:
                break

            if self._blocking_signal_threshold is not None:
                # clear alarm so it doesn't fire while poll is waiting for
                # events.
                signal.setitimer(signal.ITIMER_REAL, 0, 0)

            try:
                print("Polling!")
                event_pairs = self._impl.poll(poll_timeout)
            except Exception as e:
                # Depending on python version and IOLoop implementation,
                # different exception types may be thrown and there are
                # two ways EINTR might be signaled:
                # * e.errno == errno.EINTR
                # * e.args is like (errno.EINTR, 'Interrupted system call')
                if (getattr(e, 'errno', None) == errno.EINTR or
                    (isinstance(getattr(e, 'args', None), tuple) and
                     len(e.args) == 2 and e.args[0] == errno.EINTR)):
                    continue
                else:
                    raise

            if self._blocking_signal_threshold is not None:
                signal.setitimer(signal.ITIMER_REAL,
                                 self._blocking_signal_threshold, 0)

            # Pop one fd at a time from the set of pending fds and run
            # its handler. Since that handler may perform actions on
            # other file descriptors, there may be reentrant calls to
            # this IOLoop that update self._events
            self._events.update(event_pairs)
            while self._events:
                fd, events = self._events.popitem()
                try:
                    self._handlers[fd](fd, events)
                except (OSError, IOError) as e:
                    if e.args[0] == errno.EPIPE:
                        # Happens when the client closes the connection
                        pass
                    else:
                        raise
 
    def stop(self):
        self._running = False
        self._stopped = True
 
    def add_handler(self, fd, handler, events):
        self._handlers[fd] = stack_context.wrap(handler)
        self._impl.register(fd, events | self.ERROR)

    def remove_handler(self, fd):
        self._handlers.pop(fd, None)
        self._events.pop(fd, None)

    @staticmethod
    def instance():
        if not hasattr(InterceptPipeIOLoop, "_instance"):
            with InterceptPipeIOLoop._instance_lock:
                if not hasattr(InterceptPipeIOLoop, "_instance"):
                    # New instance after double check
                    InterceptPipeIOLoop._instance = InterceptPipeIOLoop()
        return InterceptPipeIOLoop._instance

