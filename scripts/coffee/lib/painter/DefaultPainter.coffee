Layer = require './defaultPainter/Layer'
defaultShaders = require '../shaders/default'
Timing = require 'raf-timing'

module.exports = class DefaultPainter

	constructor: (@gila) ->

		@_layers = {}

		@_shaders = frag: {}, vert: {}

		@_addVertexShader 'default', defaultShaders.vert

		@_addFragmentShader 'default', defaultShaders.frag

		@paused = yes

		@_timing = new Timing

		@_timing.onEachFrame @_paint

		@_timing.start()

		@_textures = {}

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

	_addTexture: (name, addr) ->

		name = 'texture_' + name.replace(/[^a-zA-Z0-9\_]+/g, '_')

		return if @_textures[name]?

		slot = Object.keys(@_textures).length

		t = @gila.makeTexture addr

		t.wrapSClampToEdge()
		t.wrapTClampToEdge()

		if addr.substr(addr.length - 3, addr.length) is 'jpg'

			t.flipY()

		t.assignToSlot slot

		@_textures[name] = t

		@_sharedUniforms[name] =

			type: '1i'

			array: new Int32Array [slot]

		return

	_addVertexShader: (name, source) ->

		@_shaders.vert[name] = @gila.getVertexShader '' + name + (++shadersCount),

			source

		@

	_addFragmentShader: (name, source) ->

		@_shaders.frag[name] = @gila.getFragmentShader '' + name + (++shadersCount),

			source

		@

	_resetShaders: ->

		@_shaders.frag =

			'default': @_shaders.frag['default']

		@_shaders.vert =

			'default': @_shaders.vert['default']

		@

	setConfig: (conf, uri) ->

		@_resetShaders()

		@_layers = {}

		for name, filename of conf.textures

			@_addTexture name, uri + 'textures/' + filename

		for name, source of conf.fragShaders

			@_addFragmentShader name, source

		for name, source of conf.vertShaders

			@_addVertexShader name, source

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

		@_sharedUniforms.time.array[0] = @_timing.time

		for name, layer of @_layers

			layer.render()

		return

shadersCount = 0