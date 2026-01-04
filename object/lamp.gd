extends Node2D

@export var light_scale = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$object/PointLight2D.texture_scale = light_scale 
	$object/PointLight2D.texture.width = light_scale * 64
	$object/PointLight2D.texture.height = light_scale * 64
