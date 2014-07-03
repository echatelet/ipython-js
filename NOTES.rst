Gotchas
=======

(1) Have a testing browser due to XHR and aggressive cachiing
(2) Chrome on Linux does not work due to a known bug

Debugging
=========

Javascript code is intentionally **not** optimized to make debugging
easier. Emscripten outputs the C file and line number as an appended
comment. This means that when a Javascript error occurs, you can
jump back to the Python code for context. 

The filesystem and other resources are "Javascript" equivalents to
their UNIX equivalents. Emscripten hooks up calls to the C and
C++ libraries to these resources. For example, there is a Javascript
filesystem and files that are opened and closed are opened and
closed in this filesystem.

So, for example, when Python modules aren't loading, I first
tracked down where in the Javscript code the library was
failing to load. Then, it was possible to have Javascript
output the explicit failure it was encountering. In this case,
it was undefined symbols from the C++ library which is not
linked but were being included. Stubbing out these
functions - which were not used - eliminated the errors.

Fast Edit-Debug-Compile cycle
=============================
Use the Makefile target to have a (relatively) quick edit-debug-compile cycle. It
should take less than a minute when debugging Python modules or libraries if you
only build a subset of the targets

