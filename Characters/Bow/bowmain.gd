extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Timer.is_stopped():
		$Bow.arrowAdvance = (10*$Timer.time_left/$Timer.wait_time) - 5
		$Bow.define_parts()
