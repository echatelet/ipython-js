#############################################################
#
# Build Python javascript, modules, packages, etc.
#
#############################################################

download_python_dependencies:
	apt-get install -y vim curl openjdk-7-jre python-dev git
	rm -f clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz Python-2.7.4.tgz
	rm -rf clang+llvm-3.2-x86-linux-ubuntu-12.04 Python-2.7.4 Python-2.7.4-js emscripten
	git clone https://github.com/kripken/emscripten.git
	cd emscripten ; git checkout -b old_shared_libs origin/old_shared_libs
	curl -O http://llvm.org/releases/3.2/clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz
	tar xzf clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz
	wget http://www.python.org/ftp/python/2.7.4/Python-2.7.4.tgz
	tar xzf Python-2.7.4.tgz
	cp -R Python-2.7.4 Python-2.7.4-js
	wget https://pypi.python.org/packages/source/s/setuptools/setuptools-5.3.tar.gz
	tar xvfz setuptools-5.3.tar.gz
	cd setuptools-5.3; python setup.py build; python setup.py install

download_python_modules:
	wget https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz
	wget https://pypi.python.org/packages/source/P/Pygments/Pygments-1.6.tar.gz
	wget https://pypi.python.org/packages/source/i/ipython/ipython-2.1.0.tar.gz
	wget https://pypi.python.org/packages/source/t/tornado/tornado-3.2.2.tar.gz

setup_paths:
	LLVM=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin
	PATH=`pwd`/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin:`pwd`/emscripten:$PATH
	cp build-files/dot-emscripten ~/.emscripten

patch_emscripten:
	cd emscripten; patch -p1 < ../build-files/emscripten-cxx-print.patch

test_emscripten:
	/vagrant/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin/clang /vagrant/emscripten/tests/hello_world.cpp
	/vagrant/emscripten/emcc /vagrant/emscripten/tests/hello_world.cpp
	node /vagrant/emscripten/tests/hello_world.js
	node a.out.js

build_python:
	cd Python-2.7.4; ./configure --without-threads --without-pymalloc --disable-ipv6
	cd Python-2.7.4; make
	cp Python-2.7.4/Parser/pgen Python-2.7.4-js/Parser/
	chmod +x Python-2.7.4-js/Parser/pgen
	cd Python-2.7.4-js ; ../emscripten/emconfigure ./configure --without-threads --without-pymalloc --enable-shared --disable-ipv6
	cd Python-2.7.4-js; patch -p1 < ../build-files/python-configuration.patch
	# Swallow the error
	-cd Python-2.7.4-js; make 
	cd Python-2.7.4-js; /vagrant/clang+llvm-3.2-x86-linux-ubuntu-12.04/bin/llvm-link libpython2.7.so python -o python.bc

build_python_modules:
	 cp build-files/build_modules Python-2.7.4-js
	 cd Python-2.7.4-js; EMCC_FORCE_STDLIBS=libcxxabi EMCC=/vagrant/emscripten/emcc bash ./build_modules

setup_modules_directory:
	mkdir -p Python-2.7.4-js/dist/lib/python2.7/config
	cp -r Python-2.7.4-js/Lib/* Python-2.7.4-js/dist/lib/python2.7
	rm -rf Python-2.7.4-js/dist/lib/python2.7/{idlelib,lib-tk,multiprocessing,curses,bsddb}
	rm -rf Python-2.7.4-js/dist/lib/python2.7/plat-{aix3,aix4,atheos,beos5,darwin,freebsd4,freebsd5,freebsd6}
	rm -rf Python-2.7.4-js/dist/lib/python2.7/plat-{freebsd7,freebsd8,generic,irix5,irix6,mac,netbsd1,next3,os2emx,riscos,sunos5,unixware7}
	rm -rf Python-2.7.4-js/dist/lib/python2.7/test
	rm -rf Python-2.7.4-js/dist/lib/python2.7/*/test{,s}
	rm -rf Python-2.7.4-js/dist/lib/python2.7/plat-*
	cp Python-2.7.4-js/Makefile Python-2.7.4-js/Modules/Setup* Python-2.7.4-js/dist/lib/python2.7/config
	cp Python-2.7.4-js/Makefile Python-2.7.4-js/Modules/config.c Python-2.7.4-js/dist/lib/python2.7/config
	mkdir -p Python-2.7.4-js/dist/include/python2.7
	cp Python-2.7.4-js/pyconfig.h Python-2.7.4-js/dist/include/python2.7/
	
install_setuptools:
	export PYTHONPATH=/vagrant/Python-2.7.4-js/dist/lib/python2.7/site-packages;cd setuptools-5.3; python setup.py build; python setup.py install --prefix=/vagrant/Python-2.7.4-js/dist

build_jinja2:
	tar xvfz Jinja2-2.7.3.tar.gz
	cd Jinja2-2.7.3; python setup.py build

install_jinja2:
	export PYTHONPATH=/vagrant/Python-2.7.4-js/dist/lib/python2.7/site-packages;cd Jinja2-2.7.3; python setup.py install --prefix=/vagrant/Python-2.7.4-js/dist

build_pygments:
	tar xvfz Pygments-1.6.tar.gz -C .
	cd Pygments-1.6; python setup.py build

install_pygments:
	export PYTHONPATH=/vagrant/Python-2.7.4-js/dist/lib/python2.7/site-packages;cd Pygments-1.6; python setup.py install --prefix=/vagrant/Python-2.7.4-js/dist

build_numpy:
	echo "Building numpy"

install_numpy:
	echo "Installing numpy"

build_scipy:
	echo "Building scipy"

install_scipy:
	echo "Installing scipy"

build_ipython:
	tar xvfz ipython-2.1.0.tar.gz -C .
	cd ipython-2.1.0; python setup.py build

install_ipython:
	export PYTHONPATH=/vagrant/Python-2.7.4-js/dist/lib/python2.7/site-packages;cd ipython-2.1.0; python setup.py install --prefix=/vagrant/Python-2.7.4-js/dist

build_tornados:
	tar xvfz tornado-3.2.2.tar.gz -C .
	cd tornado-3.2.2; export TORNADO_EXTENSION=0; python setup.py build

install_tornados:
	export PYTHONPATH=/vagrant/Python-2.7.4-js/dist/lib/python2.7/site-packages;cd tornado-3.2.2; export TORNADO_EXTENSION=0; python setup.py install --prefix=/vagrant/Python-2.7.4-js/dist

install_simple_module:
	cp -R simple_module ./Python-2.7.4-js/dist/lib/python2.7/site-packages

install_tornados_js:
	cp -R tornado_js ./Python-2.7.4-js/dist/lib/python2.7/site-packages

install_python_modules: install_simple_module build_ipython install_ipython build_tornados install_tornados install_tornados_js build_jinja2 install_jinja2 build_pygments install_pygments 

create_javascript_filesystem:
	cp build-files/pre_fs.js Python-2.7.4-js
	cp build-files/post_fs.js Python-2.7.4-js
	cp build-files/map_filesystem.py Python-2.7.4-js
	cat Python-2.7.4-js/pre_fs.js > Python-2.7.4-js/fs.js
	cd Python-2.7.4-js;python map_filesystem.py dist >> fs.js
	cat Python-2.7.4-js/post_fs.js >> Python-2.7.4-js/fs.js

emscripten_python_js:
	# Don't use O2 since it currently errors out
	cd Python-2.7.4-js; /vagrant/emscripten/emcc python.bc -s INCLUDE_FULL_LIBRARY=1 -s NAMED_GLOBALS=1 -s INVOKE_RUN=0 --pre-js fs.js  -s EXPORTED_FUNCTIONS="['_Py_Initialize', '_PySys_SetArgv', '_PyErr_Clear', '_PyEval_EvalCode', '_PyString_AsString', '_Py_DecRef', '_PyErr_Print', '_PyErr_Fetch']" -s ASM_JS=0 -o python.js

create_web_directory:
	mkdir -p web
	cp -R Python-2.7.4-js/dist/lib web
	cp -R Python-2.7.4-js/dist/include web
	chmod -R 777 web/lib
	cp build-files/index.html web
	cp build-files/worker.js web
	cp Python-2.7.4-js/python.js web

deploy_modules: setup_modules_directory install_setuptools create_javascript_filesystem emscripten_python_js create_web_directory

clean:
	rm -rf Python-2.7.4*
	rm -rf web 
	rm -rf clang* 
	rm -rf emscripten 

# Build Javascript Python
all: download_python_dependencies download_python_modules setup_paths patch_emscripten test_emscripten build_python build_python_modules setup_modules_directory install_setuptools create_javascript_filesystem emscripten_python_js create_web_directory

all_with_modules: download_python_dependencies download_python_modules setup_paths patch_emscripten test_emscripten build_python build_python_modules setup_modules_directory install_setuptools install_python_modules create_javascript_filesystem emscripten_python_js create_web_directory  

