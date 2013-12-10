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

	render: ->

		@program.activate()

		for name, u of @sharedUniforms

			@program.uniform(u.type, name).fromArray u.array

		for name, u of @uniforms

			@program.uniform(u.type, name).fromArray u.array

		@_vxBuffer.bind()

		@gila.drawTriangles 0, 6

		return