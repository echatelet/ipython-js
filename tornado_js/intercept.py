"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

def redirect_to_pipe():

    ##################################################################
    ##
    ## Import matters in the following, do not rearrange since we
    ## are remapping dependencies.
    ##
    ##################################################################
    # Remap the TCP server which depends upon sockets to use
    # pipes instead
    import tornado_js.transport.pipeserver
    import tornado.tcpserver
    import tornado.platform.epoll
    import tornado.netutil
    tornado.tcpserver.TCPServer = tornado_js.transport.pipeserver.InterceptPipeServer
    import tornado.httpserver

    # Remap the IOLoop, accept handlers, and HTTP connection to
    # redirect to pipes
    import tornado_js.transport.pipeioloop
    tornado.ioloop.IOLoop = tornado_js.transport.pipeioloop.InterceptPipeIOLoop
    tornado.platform.epoll.EPollIOLoop = tornado_js.transport.pipeioloop.InterceptPipeIOLoop
    import tornado_js.transport.pipeutil
    tornado.netutil.add_accept_handler = tornado_js.transport.pipeutil.intercept_add_accept_handler
    import tornado_js.httpserver
    tornado.httpserver.HTTPConnection = tornado_js.httpserver.InterceptHTTPConnection
