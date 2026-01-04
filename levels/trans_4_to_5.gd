extends Node2D

var movespeed = 50
var step=0
var alpha = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().content_scale_size = Vector2i(480, 270)


func _physics_process(delta: float) -> void:
	if step == 0:
		alpha -=0.02
		$Black.material.set_shader_parameter("alpha",alpha)
		if alpha <0.8:
			step=1
	elif step == 1:
		$AnimatedSprite2D.play("up")
		$AnimatedSprite2D.position.y-=movespeed*delta
		if alpha>0:
			alpha -=0.02
			$Black.material.set_shader_parameter("alpha",alpha)
		if $AnimatedSprite2D.position.y<160:
			step=2
	elif step==2:
		$AnimatedSprite2D.play("right")
		$AnimatedSprite2D.position.x+=movespeed*delta
		if $AnimatedSprite2D.position.x>340:
			step=3
	elif step==3:
		$AnimatedSprite2D.play("up")
		$AnimatedSprite2D.position.y-=movespeed*delta
		if $AnimatedSprite2D.position.y<90:
			step=4
			$AnimatedSprite2D.stop()
			$TextBox.start_text_write("Seems long abandoned...", 1 , Vector2(150,100))
	elif step==4 and !Global.textLock:
		alpha +=0.02
		$Black.material.set_shader_parameter("alpha",alpha)
		if alpha >1:
			get_tree().change_scene_to_file("res://levels/level_five.tscn")
