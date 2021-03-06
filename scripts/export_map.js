var casper = require('casper').create();

// casper.on('remote.message', function(message) {
//     console.log(message);
// });

var out_dir = 'static/tmp/';
var key = casper.cli.get(0);
var url = casper.cli.get(1);

var filepath = out_dir + key + '.png';

casper.start();

casper.viewport(1024, 650).thenOpen(url, function() {
    casper.then(function() {
        this.wait(2000, (function() {
            return function() {
                casper.capture(filepath);
                casper.echo(filepath);
            }
        })())
    });
});

casper.run();
