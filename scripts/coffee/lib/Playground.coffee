DefaultPainter = require './painter/DefaultPainter'
request = require 'superagent'
Gila = require 'gila'

module.exports = class Playground

	constructor: (@canvas, @errorEl, @pgName) ->

		@gila = new Gila @canvas, yes

		@painter = new DefaultPainter @gila

		@_updateTime = 0

		do @_requestUpdate

	_requestUpdate: =>

		request
		.get('/?getPlaygroundConfig=' + @pgName)
		.end (res) =>

			config = JSON.parse res.text

			@_updateIfNecessary config

			return

		return

	_updateIfNecessary: (config) ->



		setTimeout @_requestUpdate, 1000

		return if config.updateTime is @_updateTime

		@_updateTime = config.updateTime

		@painter.stop()

		try

			@painter.setConfig config, '/playground/1/'

			@painter.play()

			@noError()

		catch e

			@error e

		return

	error: (e) ->

		@noError

		msg = (e.message + '<div class="stack">' + e.stack + '</div>')

		@errorEl.innerHTML = msg

		@errorEl.classList.add 'visible'

	noError: ->

		@errorEl.classList.remove 'visible'

		return