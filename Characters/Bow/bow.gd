extends Node2D
var unitVec = Vector2(1,0)
var arrowAdvance = 5
var arrowParts
var arrowColors =  PackedColorArray([
	Color(0.8, 0.8, 0.8), 
	Color(0.8, 0.8, 0.8),
	Color(0.6, 0.2, 0.1),
	Color(0, 0, 0)
])

var bowParts
var bowColors =  PackedColorArray([
	Color(0, 0, 0),
	Color(0.6, 0.2, 0.1),
	Color(0.6, 0.2, 0.1)
])
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	define_parts()

func _draw():
	draw_multiline_colors(arrowParts, arrowColors)
	draw_multiline_colors(bowParts,bowColors)

func define_parts():
	arrowParts = PackedVector2Array([
		arrowAdvance*unitVec + 0.5*unitVec.orthogonal(), arrowAdvance*unitVec + 6 * unitVec + 0.5 * unitVec.orthogonal(), 
		arrowAdvance*unitVec - 0.5*unitVec.orthogonal(), arrowAdvance*unitVec + 6 * unitVec - 0.5 * unitVec.orthogonal(),
		arrowAdvance*unitVec + unitVec*4,  arrowAdvance*unitVec + unitVec*20, 
		arrowAdvance*unitVec + unitVec*(20), arrowAdvance*unitVec + unitVec*22
	])
	
	bowParts = PackedVector2Array([
		15*unitVec + 2*unitVec.orthogonal(), 15 * unitVec - 2*unitVec.orthogonal(),
		15*unitVec + 2*unitVec.orthogonal(), 11 * unitVec + 10*unitVec.orthogonal(),
		15*unitVec - 2*unitVec.orthogonal(), 11 * unitVec - 10*unitVec.orthogonal()
	])
	queue_redraw()
