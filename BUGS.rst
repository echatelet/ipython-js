HISTORY AND BUGS FIXED
======================

(1) Python compiles to Javascript via Emscripten (optimization turned off). Optimizatoin
    was too aggressive and resulted in non-runnable Javascript code. Minification was
    turned off to make debugging easier. 

(2) Python modules compile (shell script). Reorganized to make module building more
    atomic so that additional modules can be added easily.

(3) Imports don't work. Fixed. Linux Chrome bug only. 

(4) Dynamic loading of libraries don't work. Patched emscripten
    to have CXX stubs for the missing CXX references.

(5) Switched to Makefile for fast edit-debug-compile cycle

(6) Turned on Javascript debugging when using Javascript workers

(7) Javascript filesystem failing with overwrite error. The problem
    is that .so and .so.js files were being included but the
    filesystem maps both .so and .so.js to the .so path leading
    to a collision. Turning off the error led to an attempt
    to run the .so file instead of the .js file. 

