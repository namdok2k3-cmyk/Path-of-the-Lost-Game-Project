extends CharacterBody2D

var speed = 300.0
var direction
var thrown = true

func _process(delta: float) -> void:
	if self.global_position.x > 1900:
		get_parent().remove_child(self)
	if thrown:
		velocity = direction * speed * delta
	move_and_slide()
	


func _on_despawn_timer_timeout() -> void:
	get_parent().remove_child(self)
