var casper = require('casper').create();

casper.start('http://localhost:5000/?locale=en', function() {
    this.echo(this.getTitle());
});

casper.viewport(1024, 768).thenOpen('http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks,intensity_lvls_scenario&basemap=os&fishing=lot&count=6&wkt=POLYGON%28%28251399%20393996.5%2C253574%20388896.5%2C251224%20388896.5%2C249649%20390171.5%2C251399%20393996.5%29%29&dpm_0=0&dpm_1=0&dpm_2=0&dpm_3=0&dpm_4=0&dpm_5=2&dpm_6=3&dpm_7=0&dpm_8=0&dpm_9=0&dpm_10=0&dpm_11=0&gear_speed=2&gear_time=6&gear_width=8&vessels=9', function() {
    this.echo(this.getTitle());
    this.echo(this.exists('#activity_commercial_fishing_polygon'));
    this.capture('screenshot.png');
    casper.page.paperSize = {
    width: '11in',
    height: '8.5in',
    orientation: 'landscape',
    border: '0.4in'
  };
    this.capture('screenshot.pdf');
});

casper.run();
