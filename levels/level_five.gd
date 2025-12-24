extends Node2D
var arrowScene = preload("res://arrow/arrow.tscn")
var arrows = []
var fadeIn = true
var fadeOut = false
var alpha = 1
var b1 = 0
var b2 = 0
var wallGone = false
var enemies:Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Raft/Player.maxHealth = Global.player_max
	Global.dashBoots = true
	$Raft/Player.dashBoots = true
	Global.liftGloves = true
	$Raft/Player.liftGloves = true
	
	for i in $YSort/Enemies.get_children():
		enemies.append(i)
		i.connect("newArrow",_on_new_arrow)
	var j =0
	for i in $EnemyTriggers.get_children():
		i.body_entered.connect(triggerEnemy.bind(j))
		j+=1
	get_window().content_scale_size = Vector2i(480, 270)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	$CanvasLayer/HealthBar.updateHealth($Raft/Player.maxHealth,$Raft/Player.curHealth)
	$Raft/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$Raft/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)
	
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	$Raft/Player.lockMovement = true
	$Raft/Player.facing=Vector2(1,0)
	
func _physics_process(delta: float) -> void:
	if fadeIn&&alpha >0:
		alpha -=0.02
		$CanvasLayer/Black.material.set_shader_parameter("alpha",alpha)
	elif fadeIn:
		fadeIn = false
		$CanvasLayer/Black.visible = false
		
	if fadeOut&&alpha <1:
		alpha +=0.02
		$CanvasLayer/Black.material.set_shader_parameter("alpha",alpha)
	elif fadeOut:
		get_tree().change_scene_to_file("res://levels/level_seven.tscn")
		
func triggerEnemy(_a,num):
	enemies[num].moveToAttack()
# recieves signal from arrow when it is broken
func _on_arrow_break(aUnit,aPos,randBrown):
	#spawn front and back arrow halves with pos, rotation, and color of original
	var front = RigidBody2D.new()
	var script = load("res://arrow/broken_tip.gd")
	front.set_script(script)
	front.init(aUnit,aPos,randBrown)
	$YSort.add_child(front)
	
	var back = RigidBody2D.new()
	script = load("res://arrow/broken_back.gd")
	back.set_script(script)
	back.init(aUnit,aPos,randBrown)
	$YSort.add_child(back)

#signal recieved from player
func _on_new_arrow(unitVec, firePos,origin_collider):

	#spawn new arrow with direction and position
	var newArrow = arrowScene.instantiate()
	newArrow.init(unitVec,firePos,origin_collider)
	newArrow.connect("breakArrow", _on_arrow_break)
	
	#moving arrows are child of main scene
	$YSort.add_child(newArrow)
	arrows.append(newArrow)
	
#signal recieved from player
func _on_new_arrow_player(unitVec, firePos,origin_collider):
	firePos += $Raft.position
	#spawn new arrow with direction and position
	var newArrow = arrowScene.instantiate()
	newArrow.init(unitVec,firePos,origin_collider)
	newArrow.connect("breakArrow", _on_arrow_break)
	
	#moving arrows are child of main scene
	$YSort.add_child(newArrow)
	arrows.append(newArrow)


func _on_area_2d_body_entered(body: Node2D) -> void:
	fadeOut = true
	$CanvasLayer/Black.visible = true
