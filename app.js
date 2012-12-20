/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes');

var app = module.exports = express();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.set('view options', {layout: false});
  app.use(express.bodyParser());
  app.use(express.cookieParser());
  app.use(express.session({ secret: 'PolymixForever2012' }));
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes

app.get('/', routes.index);

app.post('/job/start', routes.startJob);

app.listen(3000, function(){
  console.log("Plan management application running on http://localhost:3000");
  //console.log("Environment is " + app.get('env'));  // this works too
    console.log("Environment is " + app.settings.env);
});
