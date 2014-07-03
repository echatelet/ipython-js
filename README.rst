=======================
IPython Javascript Port
=======================

This is an in-progress port of IPython to Javascript via Emscripten. It is 
not currently working but in the spirit of a great talk by Brian Fitzpatrick
and Ben Collins-Sussman from Google (bit.ly/1osLeO3). Collaboration is
very welcome but not expected. 

**Please don't announce anything until IPython is working.**

What's working, what's not
==========================

Working

* Compiling Python with Emscripten (up-to-date)
* Python modules (up-to-date)
* C Python modules (working with patch to Emscripten)
* External submodules (first run import sys and then sys.path.append("/lib/python2.7/site-packages"))

Not working (yet)

* Complex submodules (fails because dependencies are loaded recursively and we reach maximum recursion level)
* Pygments (depends on socket, fails)
* Jinja2 (hits maximum recursion level)
* Tornados and zeromq (depend on sockets, must replace with Web worker messages)
* IPython (depends upon all of the above)

============
Dependencies
============

To make the management of dependencies easy, Vagrant is used. Please
install the latest version of Vagrant and VirtualBox.

========
Building 
========

Provision the vagrant machine

   $ vagrant up

Logon to the machine

   $ vagrant ssh

Build the package
   
   $ cd /vagrant; sudo make all 

