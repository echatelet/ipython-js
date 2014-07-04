===========
IPython App 
===========

The IPython application has tornado and pyzmq as dependencies. These applications
have dependencies on socket. Unfortunately, WebSocket does not seem appropriate
since tornado and zeromq are *server applications*. The clearest path forward
is to run the tornado and zeromq services in seperate web workers and simulate
their server message passing with messages between the web workers. 

Now, a key goal of this project is to port IPython *without* changing the core
IPython project. This can be accomplished by remapping the socket layer in
tornados to the message passing of web workers. The library tornados_js remaps
sockets to UNIX pipes as research in what APIs have to be remapped. The 
__init__.py file in this directory remaps tornado from within IPython so that
notebook messages are passed through UNIX pipes.

Currently, this code must be placed directly in IPython. It should be factored
out to be independent of the IPython project.

