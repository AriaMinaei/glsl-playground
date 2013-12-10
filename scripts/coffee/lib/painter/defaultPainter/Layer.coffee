{object} = require 'utila'

module.exports = class Layer

	self = @

	@_vertices: new Float32Array [
		-1, -1, 0,
		-1,  1, 0,
		 1, -1, 0,

		 1, -1, 0,
		-1,  1, 0,
		 1,  1, 0
	]

	constructor: (@painter, @vert, @frag, @sharedUniforms) ->

		@gila = @painter.gila

		@program = @gila.getProgram @vert, @frag

		@_vxBuffer = @gila.makeArrayBuffer().data self._vertices

		@_vxAttr = @program.attr('vx').enable().readAsFloat 3, no, 0, 0

		@uniforms = {}

		@_blendingEnabled = no

		@_blendingConfig =

			src: 'one'

			dst: 'zero'

	blend: (enable, src, dst) ->

		@_blendingEnabled = Boolean enable

		@_blendingConfig.src = src
		@_blendingConfig.dst = dst

		@

	render: ->

		@program.activate()

		if @_blendingEnabled

			@gila.blending.enable()

			@gila.blend.src[@_blendingConfig.src]()
			@gila.blend.dst[@_blendingConfig.dst]()

		else

			@gila.blending.disable()

		for name, u of @sharedUniforms

			@program.uniform(u.type, name).fromArray u.array

		for name, u of @uniforms

			@program.uniform(u.type, name).fromArray u.array

		@_vxBuffer.bind()

		@gila.drawTriangles 0, 6

		return