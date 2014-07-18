=======================
IPython Javascript Port
=======================

This is an in-progress port of IPython to Javascript via Emscripten. It is 
not currently working but in the spirit of a great talk by Brian Fitzpatrick
and Ben Collins-Sussman from Google (bit.ly/1osLeO3) has been released
early instead of released perfectly. Collaboration is very welcome but 
not expected. 

**Please don't announce anything until IPython is working.**

With that said, Python and external submodules are working. If you are
working on a similar project, this might be a good starting point since
it currently builds and is more up-to-date than the empythoned 
repository. 

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
install the latest version of Vagrant and VirtualBox. *These are the
only dependencies that you have to fetch since all of the other - quite
complex - dependencies will be fetched and built within your vagrant
box.* Nothing will be installed on your machine.

========
Building 
========

Provision the vagrant machine

   $ vagrant up

Logon to the machine

   $ vagrant ssh

Build the package
   
   $ cd /vagrant; sudo make all 

====
NEWS
====

07/18/2014 - Very basic unit testing has been added. The tests are ran automatically from
the commandline using node.js.

==========
NEXT STEPS
==========

Here are the next steps to be tackled:

* Verify that imports work from node (for unit tests)
* Fix the unittest file and exit on error
* Determine what modules are required for IPython (presumably by intercepting import calls)
* Load modules iteratively, not recursively which reaches the recursive limits for Javascript

These will result in reliable, build-breaking unit tests and a list of modules that have to work for IPython to work.

 
