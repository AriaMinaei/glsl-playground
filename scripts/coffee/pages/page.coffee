DefaultPainter = require '../lib/painter/DefaultPainter'
Gila = require 'gila'

gila = new Gila document.getElementById('the-canvas'), yes

painter = new DefaultPainter gila

painter.setConfig

	layers:

		layer1: {}

		layer2: {}

painter.play()