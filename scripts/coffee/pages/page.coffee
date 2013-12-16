Playground = require '../lib/Playground'





loc = window.location.href.replace 'http://', ''

loc = loc.substr(loc.indexOf('/') + 1, loc.length)

unless matches =  loc.match /^playground\/([a-zA-Z0-9\-\_]+)\/$/

	throw Error "Invalid url. Url must be like: http://whatever/playground/name/"

else

	playgroundName = matches[1]

	theCanvas = document.getElementById('the-canvas')

	errorEl = document.getElementById('error')

	p = new Playground theCanvas, errorEl, playgroundName