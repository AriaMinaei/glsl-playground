Playground = require '../lib/Playground'





loc = window.location.href.replace 'http://', ''

loc = loc.substr(loc.indexOf('/') + 1, loc.length)

unless matches =  loc.match /^playground\/([0-9]+)\/$/

	throw Error "Invalid url. Url must be like: http://whatever/playground/name/"

else

	playgroundName = matches[1]

	p = new Playground document.getElementById('the-canvas'), playgroundName