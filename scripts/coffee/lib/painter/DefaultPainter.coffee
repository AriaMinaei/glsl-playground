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

		@_sharedUniforms =

			time:

				type: '1f'

				array: new Float32Array [0]

			mouse:

				type: '2f'

				array: new Float32Array 2

		do =>

			pos = @_sharedUniforms.mouse.array

			window.addEventListener 'mousemove', ->

				pos[0] = (event.x / window.innerHeight)
				pos[1] = (event.y / window.innerWidth)

			return



	addVertexShader: (name, source) ->

		@_shaders.vert[name] = @gila.getVertexShader '' + name + (++shadersCount),

			source

		@

	addFragmentShader: (name, source) ->

		@_shaders.frag[name] = @gila.getFragmentShader '' + name + (++shadersCount),

			source

		@

	resetShaders: ->

		@_shaders.frag =

			'default': @_shaders.frag['default']

		@_shaders.vert =

			'default': @_shaders.vert['default']

		@

	setConfig: (conf) ->

		@resetShaders()

		@_layers = {}

		for name, source of conf.fragShaders

			@addFragmentShader name, source

		for name, source of conf.vertShaders

			@addVertexShader name, source

		for name, layer of conf.layers

			if layer.frag?

				unless frag = @_shaders.frag[layer.frag]

					throw Error "Cannot find fragment shader '#{layer.frag}'"

			else

				frag = @_shaders.frag['default']

			if layer.vert?

				unless vert = @_shaders.vert[layer.vert]

					throw Error "Cannot find vertex shader '#{layer.vert}'"

			else

				vert = @_shaders.vert['default']

			@_layers[name] = new Layer @, vert, frag, @_sharedUniforms

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

		@_sharedUniforms.time.array[0] = @timing.time

		for name, layer of @_layers

			layer.render()

		return

shadersCount = 0