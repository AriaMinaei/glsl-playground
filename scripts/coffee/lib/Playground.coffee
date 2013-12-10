DefaultPainter = require './painter/DefaultPainter'
Gila = require 'gila'

module.exports = class Playground

	constructor: (@canvas, @pgName) ->

		@gila = new Gila @canvas, yes

		@painter = new DefaultPainter @gila



		@painter.play()