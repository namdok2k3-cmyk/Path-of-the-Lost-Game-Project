extends Control
#PauseMenu is not affected by pause. See inspector/Process/Mode
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause")):
		
		get_tree().paused=!get_tree().paused
		if (get_tree().paused):
			Global.image = Global.MOUSEIMG
		else:
			Global.image = Global.ARROWIMG
		Global.setMouse()
		visible=get_tree().paused

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	Global.image = Global.ARROWIMG
	Global.setMouse()


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu/main/main_menu.tscn")
