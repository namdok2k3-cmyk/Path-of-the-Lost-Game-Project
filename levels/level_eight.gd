extends Node2D
var fadeBlack = false
var alpha = 1
var alphaBlack = 1
var doAnim = false
var moveToFriend = false
var fadeOut = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$YSort/Player.activeBow = false
	$FadeIn/BGBlack.visible = true
	$FadeIn/DoorClose.start()
	$FadeIn/GlobalAudio.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fadeOut and alphaBlack<1.5:
		alphaBlack += delta
		$FadeIn/BGBlack.material.set_shader_parameter("alpha",alphaBlack)
	elif fadeOut:
		get_tree().change_scene_to_file("res://menu/main/main_menu.tscn")
	if doAnim and !Global.textLock and !fadeOut:
		$Deathbed/Deathbed.play("opening")
	if fadeBlack&&alphaBlack >0:
		alphaBlack -= delta
		$FadeIn/BGBlack.material.set_shader_parameter("alpha",alphaBlack)
	elif fadeBlack:
		fadeBlack = false
		
	## Move player to cutscene location when close
	if moveToFriend:
		Global.textLock = true
		$YSort/Player.position = lerp($YSort/Player.position, Vector2(362,70), 2 * delta)
		if ($YSort/Player.position - Vector2(362,70)).length() < 0.3:
			moveToFriend = false
			$YSort/Player/AnimatedSprite2D.animation = "Right"
			$YSort/Player/AnimatedSprite2D.stop()
			$TextBoxPlayer.start_text_write("Hello, old friend.",5,Vector2(263,-35))
			doAnim = true
		
func _on_door_close_timeout() -> void:
	fadeBlack = true

func _on_friend_interact_area_entered(area: Area2D) -> void:
	if area.name == "ArrowCollider":
		moveToFriend = true


func _on_deathbed_animation_finished() -> void:
	fadeOut=true
	doAnim=false
