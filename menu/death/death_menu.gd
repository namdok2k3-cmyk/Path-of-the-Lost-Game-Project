extends Control

#signal recieved from player, connected in main
func _player_died():
	Global.image = Global.MOUSEIMG
	Global.setMouse()
	visible=true

func _on_retry_button_pressed() -> void:
	Global.image = Global.ARROWIMG
	Global.setMouse()
	get_tree().reload_current_scene()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/main/main_menu.tscn")
