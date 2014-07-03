=======================
IPython Javascript Port
=======================

This is an in-progress port of IPython to Javascript via Emscripten. 

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

