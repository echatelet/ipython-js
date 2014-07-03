#!/bin/bash

# Globals
VERBOSE=false

get_packages() {
    if [ "$verbose" != true ]; then
        echo "Retrieving and installing dependencies ..."
    fi
    apt-get install -y vim curl openjdk-7-jre python-dev git
    rm -f clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz Python-2.7.4.tgz
    rm -rf clang+llvm-3.2-x86-linux-ubuntu-12.04 Python-2.7.4 Python-2.7.4-js emscripten
    git clone https://github.com/kripken/emscripten.git
    pushd .; cd emscripten ; git checkout -b old_shared_libs origin/old_shared_libs; popd
    curl -O http://llvm.org/releases/3.2/clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz
    tar xzf clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz
    wget http://www.python.org/ftp/python/2.7.4/Python-2.7.4.tgz
    tar xzf Python-2.7.4.tgz
    cp -R Python-2.7.4 Python-2.7.4-js
}

setup_paths() {
    if [ "$verbose" != true ]; then
        echo "Setting environment paths ..."
        echo "export LLVM=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin" >> ~/.bashrc
        echo "export PATH=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin:/vagrant/python-sandbox/emscripten:\$PATH" >> ~/.bashrc
    fi
    LLVM=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin
    PATH=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin:`pwd`/emscripten:$PATH
    cp build-files/dot-emscripten ~/.emscripten
}

test_emscripten() {
    clang /vagrant/emscripten/tests/hello_world.cpp
    ./a.out
    emcc /vagrant/emscripten/tests/hello_world.cpp
    node /vagrant/emscripten/tests/hello_world.js
    which clang++
    node a.out.js
}

build_python() {
    pushd .; cd Python-2.7.4; ./configure --without-threads --without-pymalloc --disable-ipv6; popd
    pushd .; cd Python-2.7.4; make; popd
    cp Python-2.7.4/Parser/pgen Python-2.7.4-js/Parser/
    chmod +x Python-2.7.4-js/Parser/pgen
    pushd .; cd Python-2.7.4-js ; ../emscripten/emconfigure ./configure --without-threads --without-pymalloc --enable-shared --disable-ipv6; popd
    pushd .; cd Python-2.7.4-js; patch -p1 < ../build-files/python-configuration.patch; popd
    # Swallow the error
    pushd .; cd Python-2.7.4-js; make ||
    popd
    pushd .; cd Python-2.7.4-js; llvm-link libpython2.7.so python -o python.bc; popd;
}

build_python_modules() {
     cp build-files/build_modules Python-2.7.4-js
     pushd .; cd Python-2.7.4-js; EMCC=/vagrant/emscripten/emcc source ./build_modules; popd
}

setup_modules_directory() {
    mkdir -p Python-2.7.4-js/dist/lib/python2.7/config
    cp -r Python-2.7.4-js/Lib/* Python-2.7.4-js/dist/lib/python2.7
    rm -rf Python-2.7.4-js/dist/lib/python2.7/{idlelib,lib-tk,multiprocessing,curses,bsddb}
    rm -rf Python-2.7.4-js/dist/lib/python2.7/plat-{aix3,aix4,atheos,beos5,darwin,freebsd4,freebsd5,freebsd6,freebsd7,freebsd8,generic,irix5,irix6,mac,netbsd1,next3,os2emx,riscos,sunos5,unixware7}
    rm -rf Python-2.7.4-js/dist/lib/python2.7/test
    rm -rf Python-2.7.4-js/dist/lib/python2.7/*/test{,s}

    cp Python-2.7.4-js/Makefile Python-2.7.4-js/Modules/{Setup*,config.c} Python-2.7.4-js/dist/lib/python2.7/config
    mkdir -p Python-2.7.4-js/dist/include/python2.7
    cp Python-2.7.4-js/pyconfig.h Python-2.7.4-js/dist/include/python2.7/
}

create_javascript_filesystem() {
    cp build-files/pre_fs.js Python-2.7.4-js
    cp build-files/post_fs.js Python-2.7.4-js
    cp build-files/map_filesystem.py Python-2.7.4-js
    cat Python-2.7.4-js/pre_fs.js > Python-2.7.4-js/fs.js
    pushd .; cd Python-2.7.4-js;python map_filesystem.py dist >> fs.js
    popd
    cat Python-2.7.4-js/post_fs.js >> Python-2.7.4-js/fs.js
}

emscripten_python_js() {
    # Don't use O2 since it currently errors out
    pushd .; cd Python-2.7.4-js; /vagrant/emscripten/emcc python.bc -s NAMED_GLOBALS=1 -s INVOKE_RUN=0 --pre-js fs.js  -s EXPORTED_FUNCTIONS="['_Py_Initialize', '_PySys_SetArgv', '_PyErr_Clear', '_PyEval_EvalCode', '_PyString_AsString', '_Py_DecRef', '_PyErr_Print', '_PyErr_Fetch']" -s ASM_JS=0 -o python.js; popd
}

create_web_directory() {
    mkdir -p web
    cp -R Python-2.7.4-js/dist/lib web
    cp -R Python-2.7.4-js/dist/include web
    cp build-files/index.html web
    cp build-files/worker.js web
    cp Python-2.7.4-js/python.js web
}

# Parse the arguments
args=`getopt v:: $*`
set -- $args
for i; do
    if [ "$1" = "-v" ]; then
        VERBOSE=true
    fi
done

# Change to our build directory
cd /vagrant

# Build Javascript Python
get_packages
setup_paths
test_emscripten
build_python
build_python_modules
setup_modules_directory
create_javascript_filesystem
emscripten_python_js
create_web_directory

