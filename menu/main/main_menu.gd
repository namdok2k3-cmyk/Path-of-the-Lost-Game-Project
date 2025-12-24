extends Control
var fade = false
var fadeBlack = false
var alpha = 1
var alphaBlack = 1
func _ready() -> void:
	get_window().content_scale_size = Vector2i(800, 450)
	Global.image = Global.MOUSEIMG
	Global.setMouse()
func _physics_process(delta: float) -> void:
	
	if fade&&alpha >0:
		alpha -=0.02
		$BG.material.set_shader_parameter("alpha",alpha)
	elif fade:
		fade = false
		$TextBox.start_text_write("Your life of relative peace near the city was suddenly uprooted by the arrival of a terrible message: \n                     (Press Space to continue)\nYour dear friend who long ago moved into the wilds has been struck with a terrible illness, and their days are nearing an end.\n\nYou set out on a quest to see them one last time. On the way you encountered a beast which nearly got the best of you. \n\nYou escaped, but all your gear was scattered and scavenged by malicious creatures.",2,Vector2(112,200))
	if fadeBlack&&alphaBlack >0:
		alphaBlack -=0.02
		$BgNoTitle.material.set_shader_parameter("alpha",alphaBlack)
	elif fadeBlack:
		fadeBlack = false
		get_tree().change_scene_to_file("res://levels/level_one.tscn")
		
func _on_play_button_pressed() -> void:
	fade=true
	$VBoxContainer/playButton.visible = false
	$VBoxContainer/quitButton.visible = false
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_text_box_done() -> void:
	fadeBlack = true
