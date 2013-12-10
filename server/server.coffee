mime = require 'mime'
http = require 'http'
path = require 'path'
fs = require 'fs'

http.createServer( (req, res) ->

	serve req.url, res
	res.end()

).listen 9001

header = (res, ext = 'txt') ->

	res.writeHead 200,

		'Content-Type': mime.lookup(ext)

	return

getPlaygroundsList = ->

	list = []

	for name in fs.readdirSync '../playground'

		p = path.join('../playground', name, 'config.cson')

		list.push name if fs.existsSync(p)

	list

printPlaygroundList = ->

	list = getPlaygroundsList()

	ret = ''

	for name in list

		ret += "<a href='/playground/#{name}/'>#{name}</a><br>"

	ret

serve = (uri, res) ->

	uri = uri.substr 1, uri.length

	if uri is ''

		header res, 'html'

		res.write printPlaygroundList()

	else if uri.match /^playground\/[a-zA-Z0-9\_\-\.\s]\/$/

		res.write fs.readFileSync '../html/index.html'

	else

		serveFile res, uri

	return

serveFile = (res, uri) ->

	uri = uri.replace /\.\./g, ''

	p = path.join '..', uri

	if fs.existsSync p

		header res, p

		res.write fs.readFileSync p

	else

		res.writeHead 404

	return