extends Node2D

var arrowScene = preload("res://arrow/arrow.tscn")
var projScene = preload("res://projectile/proj.tscn")
var arrows = []

func _ready():
	Global.image = Global.ARROWIMG
	Global.setMouse()
	#Initial health update to display full player health
	$Camera2D/HealthBar.updateHealth($Player.maxHealth,$Player.curHealth)
	$Player.connect("damageTaken", $Camera2D/HealthBar.updateHealth)
	$Player.connect("dead", $Camera2D/DeathMenu._player_died)
	#$TextBox.start_text_write("A long, drawn out piece of inconsequential text which can be used to test the functionality of a textbox with more than 3 lines", 1, Vector2(10,10))
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	

# recieves signal from arrow when it is broken
func _on_arrow_break(aUnit,aPos,randBrown):
	#spawn front and back arrow halves with pos, rotation, and color of original
	var front = RigidBody2D.new()
	var script = load("res://arrow/broken_tip.gd")
	front.set_script(script)
	front.init(aUnit,aPos,randBrown)
	add_child(front)
	
	var back = RigidBody2D.new()
	script = load("res://arrow/broken_back.gd")
	back.set_script(script)
	back.init(aUnit,aPos,randBrown)
	add_child(back)

#signal recieved from player or enemy
func _on_new_arrow(unitVec, firePos, origin_collider):
	
	#spawn new arrow with direction and position
	var newArrow = arrowScene.instantiate()
	newArrow.init(unitVec,firePos, origin_collider)
	newArrow.connect("breakArrow", _on_arrow_break)
	
	#moving arrows are child of main scene
	add_child(newArrow)
	arrows.append(newArrow)

#signal recieved from player or enemy
func _on_new_proj(unitVec, firePos):
	
	#spawn new arrow with direction and position
	var newProj = projScene.instantiate()
	newProj.init(unitVec,firePos)
	newProj.connect("breakArrow", _on_arrow_break)
	
	#moving arrows are child of main scene
	add_child(newProj)

	
# Recieved by interactible objects
func _on_trigger_dialogue(dialogue,pos) -> void:
	$TextBox.start_text_write(dialogue, 1, pos)
