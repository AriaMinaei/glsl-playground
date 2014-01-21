#13333333333333333333333333333333333333333

macro read (node) ->

	macro.valToNode String macro.require('fs').readFileSync macro.nodeToVal node

module.exports.vert = read 'coffee/lib/shaders/default.vert'

module.exports.frag = read 'coffee/lib/shaders/default.frag'