extends Node2D

var path_points = [Vector2(100, 300), Vector2(400, 300), Vector2(400, 500), Vector2(100, 500)]
var current_index = 0
var speed = 100.0

func _process(delta):
	#if path_points.empty():
		#return
	#var target = path_points[current_index]
	#var direction = (target - global_position).normalized()
	#global_position += direction * speed * delta
	#if global_position.distance_to(target) < 5:
		#current_index = (current_index + 1) % path_points.size()
	pass
func _physics_process(delta: float) -> void:
	position.x+=0.3
