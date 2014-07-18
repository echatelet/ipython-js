# Many imports - including unittest - are not working yet, so we're
# going to test without unittest until that works.

class RunBasicPython(object):

    def run_simplest_test(self):
        if (3 * 3 != 9):
            raise Exception("Something is very wrong: 3 * 3 != 9")
        import sys
        print(sys.version_info)

if __name__ == '__main__':

    print("Running very basic unit tests")
    print("*****************************")
    runBasicPython = RunBasicPython()
    runBasicPython.run_simplest_test()


