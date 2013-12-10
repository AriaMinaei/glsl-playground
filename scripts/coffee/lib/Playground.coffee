DefaultPainter = require './painter/DefaultPainter'
request = require 'superagent'
Gila = require 'gila'

module.exports = class Playground

	constructor: (@canvas, @pgName) ->

		@gila = new Gila @canvas, yes

		@painter = new DefaultPainter @gila

		request
		.get('/?getPlaygroundConfig=' + @pgName)
		.end (res) ->

			console.log res

		@painter.play()