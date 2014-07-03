"""A non-blocking, single-threaded TCP server."""
from __future__ import absolute_import, division, print_function, with_statement

import tornado.util

if type('') is not type(b''):
    def u(s):
        return s
    bytes_type = bytes
    unicode_type = str
    basestring_type = str
else:
    def u(s):
        return s.decode('unicode_escape')
    bytes_type = str
    unicode_type = unicode
    basestring_type = basestring

@classmethod
def intercept_configure(cls, impl, **kwargs):
    print("Using remapped Configurable class and configure method.")
    base = cls.configurable_base()
    if isinstance(impl, (unicode_type, bytes_type)):
        impl = import_object(impl)
    ############################################################
    # Disabling this check since we are remapping classes
    # for Javascript tornado
    # if impl is not None and not issubclass(impl, cls):
    #    raise ValueError("Invalid subclass of %s" % cls)
    ############################################################
    base.__impl_class = impl
    base.__impl_kwargs = kwargs

