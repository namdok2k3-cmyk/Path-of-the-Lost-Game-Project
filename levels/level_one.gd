extends Node2D
var arrowScene = preload("res://arrow/arrow.tscn")
var arrows = []
var fadeIn = true
var alpha = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().content_scale_size = Vector2i(480, 270)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
	$YSort/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$YSort/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)
	
	$YSort/Player.activeBow = false
	$YSort/Player/AnimatedSprite2D.animation = "Left"
	$YSort/Player/AnimatedSprite2D.frame = 0

	
	for hidingZone in get_tree().get_nodes_in_group("HidingZones"):
		hidingZone.body_entered.connect(_on_hiding_zone_entered.bind(hidingZone))
		hidingZone.body_exited.connect(_on_hiding_zone_exited.bind(hidingZone))
		
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	Global.textLock=true

func _process(delta: float) -> void:
	if fadeIn&&alpha >0:
		alpha -=0.02
		$CanvasLayer/Black.material.set_shader_parameter("alpha",alpha)
	elif fadeIn:
		$TextBox.start_text_write("Looks like that group of rogues has my bow...", 1, Vector2(600,300))
		fadeIn = false
		$CanvasLayer/Black.visible = false
func _on_bow_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$YSort/Player.activeBow = true
		$bow.queue_free()
		$YSort/BowEnemy.aggro_override(true)
		
#signal recieved from player
func _on_new_arrow(unitVec, firePos,origin_collider):
	#spawn new arrow with direction and position
	var newArrow = arrowScene.instantiate()
	newArrow.init(unitVec,firePos,origin_collider)
	newArrow.connect("breakArrow", _on_arrow_break)
	
	#moving arrows are child of main scene
	$YSort.add_child(newArrow)
	arrows.append(newArrow)

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


#TODO: Add in mechanics here when enemies are more complete
func _on_hiding_zone_entered(body,zone):
	if body.name == "Player":
		zone.set_collision_layer_value(2,true)
		
func _on_hiding_zone_exited(body,zone):
	if body.name == "Player":
		zone.set_collision_layer_value(2,false)
	
#TODO: Add textbox that says "hmm I think I see a fortress up ahead" and then do more storytelling
func _on_level_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://levels/hub_level.tscn")

func _on_bow_block_body_entered(body: Node2D) -> void:
	if !$YSort/Player.activeBow:
		if body.name == "Player":
			$TextBox.start_text_write("I shouldn't leave without my bow...",1,Vector2($YSort/Player.position.x,$YSort/Player.position.y-30))
	else:
		$BowBlock/CollisionShape2D.set_deferred("disabled",true)
		$BowBlock/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)


func _on_fortress_view_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$TextBox.start_text_write("I should check out that fortress down there.", 1, Vector2($YSort/Player.position.x,$YSort/Player.position.y-30))
		

func _on_fortress_view_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$FortressView.queue_free()
