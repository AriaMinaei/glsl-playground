Layer = require './defaultPainter/Layer'
defaultShaders = require '../shaders/default'
Timing = require 'raf-timing'

module.exports = class DefaultPainter

	constructor: (@gila) ->

		@_layers = {}

		@_shaders = frag: {}, vert: {}

		@addVertexShader 'default', defaultShaders.vert

		@addFragmentShader 'default', defaultShaders.frag

		@paused = yes

		@timing = new Timing

		@timing.onEachFrame @_paint

		@timing.start()

	addVertexShader: (name, source) ->

		@_shaders.vert[name] = @gila.getVertexShader name + (++shadersCount),

			source

		@

	addFragmentShader: (name, source) ->

		@_shaders.frag[name] = @gila.getFragmentShader name + (++shadersCount),

			source

		@

	resetShaders: ->

		@_shaders.frag =

			'default': @_shaders.frag['default']

		@_shaders.vert =

			'default': @_shaders.vert['default']

		@

	setConfig: (conf) ->

		@_layers = {}

		for name, layer of conf.layers

			if layer.frag?

				frag = 'do something!'

			else

				frag = @_shaders.frag['default']

			if layer.vert?

				vert = 'do something!'

			else

				vert = @_shaders.vert['default']

			@_layers[name] = new Layer @, vert, frag

		@

	play: ->

		return @ unless @paused

		@paused = no

		@

	stop: ->

		return @ if @paused

		@paused = yes

		@

	_paint: =>

		return if @paused

		@gila.clear()

		for name, layer of @_layers

			layer.render()

		return

shadersCount = 0