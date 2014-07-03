# Difficulties with V2 Configuration 

The shared folders fail to mount with the V2 configuration. The error
is probably trivial but many hours have already been invested
trying to fix it. 

Here are pointers to related issues:

https://github.com/mitchellh/vagrant/issues/3341
https://github.com/mitchellh/vagrant/issues/3341

Upgrading to VirtualBox 4.3.12 did not work for me. Nor did manually
installing the tools and Guest additions from that release. Reverted
to the old configuration and waiting for future releases.
