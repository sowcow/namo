require 'rack-livereload'
 
use Rack::LiveReload
use Rack::Static,
  urls: [""],
  root: '.',
  index: 'output.html'
 
run proc { }
