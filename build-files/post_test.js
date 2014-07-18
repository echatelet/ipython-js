
// Start Python and run unit tests
this["Python"].initialize(null, null, null);
var pythonInterpreter = this["Python"];
fs = require('fs')
fs.readFile('tests/basic_python.py', 'utf8', function (err,data) {
    if (err) {
        return console.log(err);
    }
    var localPython = pythonInterpreter;
    var result = localPython.eval(data);
});
