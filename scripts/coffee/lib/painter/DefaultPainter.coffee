Layer = require './defaultPainter/Layer'
defaultShaders = require '../shaders/default'
Timing = require 'raf-timing'

module.exports = class DefaultPainter

	constructor: (@gila) ->

		@gila.depthTesting.disable()

		@_layers = {}

		@_usesFrameBuffers = no

		@_frameBufferInstructions = {}

		@_frameBuffers = []

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

				pos[0] = (event.x / window.innerWidth)
				pos[1] = (event.y / window.innerHeight)

			return

	_addTexture: (name, addr) ->

		name = 'texture_' + name.replace(/[^a-zA-Z0-9\_]+/g, '_')

		return if @_textures[name]?

		slot = Object.keys(@_textures).length

		t = @gila.makeImageTexture addr

		t.wrapSClampToEdge()
		t.wrapTClampToEdge()

		if addr.substr(addr.length - 3, addr.length) is 'jpg'

			t.flipY()

		t.assignToUnit slot

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

		layerNumber = -1

		needFb = no

		for name, layer of conf.layers

			layerNumber++

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

			if layer.useFb

				if layerNumber is 0

					throw Error "Layer 0 cannot read any frame buffers"

				haveFbs = yes

			useFb = Boolean layer.useFb

			@_layers[name] = new Layer @, vert, frag, @_sharedUniforms, useFb

			unless layer.blend?

				@_layers[name].blend yes, 'srcAlpha', 'oneMinusSrcAlpha'

			else

				@_layers[name].blend yes, layer.blend.src, layer.blend.dst

		@_frameBufferInstructions = {}
		@_usesFrameBuffers = no

		if haveFbs

			@_usesFrameBuffers = yes

			do @_updateFrameBufferInstructions

		@

	_updateFrameBufferInstructions: ->

		fbi = @_frameBufferInstructions

		# let's make sure framebuffer instructions are in order
		for name, layer of @_layers

			fbi[name] = null

		# let's find the last layer that uses fb and put an 'end'
		# instruction on it
		for name, i in Object.keys(@_layers).reverse()

			layer = @_layers[name]

			if layer.usesFb

				fbi[name] = 'end'

				lastLayer = Object.keys(@_layers).length - i

				break

		# the first layer will have a 'start' instruction on it
		fbi[Object.keys(@_layers)[0]] = 'start'

		layersInBetween = Object.keys(@_layers)[1...lastLayer - 1]

		# for all the layers in between...
		for name in layersInBetween

			layer = @_layers[name]

			# we instruct to swas the frame buffers
			if layer.usesFb

				fbi[name] = 'swap'

		if @_frameBuffers.length is 0

			for i in [0..1]

				@_frameBuffers.push @gila.makeFrameBuffer()
				.bind()
				.useRenderBufferForDepth()
				.useTextureForColor()
				.unbind()

		return

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

		@gila.blending.enable()

		@gila.clear()

		@_sharedUniforms.time.array[0] = @_timing.time

		# if we don't use frame buffers, just render all layers
		unless @_usesFrameBuffers

			delete @_sharedUniforms['fb']

			for name, layer of @_layers

				layer.render()

			return

		currentFb = @_frameBuffers[0]

		unless @_sharedUniforms['fb']?

			@_sharedUniforms['fb'] =

				type: '1i'

				array: new Int32Array [0]

		for name, layer of @_layers

			instruction = @_frameBufferInstructions[name]

			if instruction is 'start'

				currentFb.bind()

			else if instruction in ['end', 'swap']

				currentFb.unbind()
				@_sharedUniforms.fb.array[0] = currentFb.getColorTexture().assignToAUnit()

				if instruction is 'swap'

					if currentFb is @_frameBuffers[0]

						currentFb = @_frameBuffers[1]

					else

						currentFb = @_frameBuffers[0]

					currentFb.bind()

			layer.render()

		return

shadersCount = 0