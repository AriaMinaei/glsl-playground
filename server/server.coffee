mime = require 'mime'
http = require 'http'
path = require 'path'
cson = require 'cson'
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

	else if m = uri.match /^\?getPlaygroundConfig\=([a-zA-Z0-9\_\s\-\.]+)/

		getPlaygroundConfig res, m[1]

	else

		serveFile res, uri

	return

getFileListReq = (dir) ->

	list = []

	for file in fs.readdirSync dir

		p = path.resolve dir, file

		if fs.statSync(p).isDirectory()

			for item in getFileListReq p

				list.push item

		else

			list.push p

	list

getUpdateTimeForFiles = (files) ->

	biggest = 0

	for file in files

		stat = fs.statSync file

		t = stat.mtime.getTime()

		if t > biggest then biggest = t

	biggest

rep = /\\/g
addResourcesListToJson = (json, dir, files) ->

	json.textures = textures = {}
	json.fragShaders = fragShaders = {}
	json.vertShaders = vertShaders = {}

	for file in files

		p = file.substr(dir.length + 1, file.length).replace(rep, '/')

		if p.substr(0, 8) is 'shaders/'

			filename =  p.substr(8, p.length)
			ext =  path.extname filename

			if ext is '.frag'

				fragShaders[filename.substr(0, filename.length - ext.length)] = fs.readFileSync file, encoding: 'utf-8'

			else if ext is '.vert'

				vertShaders[filename.substr(0, filename.length - ext.length)] = fs.readFileSync file, encoding: 'utf-8'

		else if p.substr(0, 9) is 'textures/'

			filename =  p.substr(9, p.length)
			ext =  path.extname filename

			if ext in ['.jpg', '.gif', '.png']

				textures[filename] = filename

	return

getPlaygroundConfig = (res, name) ->

	dir = path.resolve '../playground', name

	file = path.resolve dir, 'config.cson'

	if fs.existsSync file

		content = fs.readFileSync file, encoding: 'utf-8'

		json = cson.parseSync content

		files = getFileListReq dir

		json.updateTime = getUpdateTimeForFiles files

		addResourcesListToJson json, dir, files

		header res, 'json'

		res.write JSON.stringify json

	else

		res.writeHead 404

		console.log "playground #{name} doesn't exist"

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