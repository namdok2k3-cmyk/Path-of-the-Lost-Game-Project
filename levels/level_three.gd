extends Node2D

var arrowScene = preload("res://arrow/arrow.tscn")
var arrows = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$YSort/Player.maxHealth = Global.player_max
	
	get_window().content_scale_size = Vector2i(480, 270)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
	$YSort/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$YSort/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)
	$YSort/Player/AnimatedSprite2D.animation = "Right"
	$YSort/Player/AnimatedSprite2D.frame = 0
	
	for wall in get_tree().get_nodes_in_group("Walls"):
		wall.body_entered.connect(_on_wall_zone_entered.bind(wall))
	
	if HubMechanics.level3HeartGrabbed:
		$HeartPickup.queue_free()
			
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	Global.textLock=true
	
	$TextBox.start_text_write("Looks like the path is blocked.. I wonder if I can use my gloves to break through?\n(right-click and hold to pick up certain objects.)", 1, Vector2(30,52))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	
func _on_heart_pickup_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$YSort/Player.maxHealth += 2
		$YSort/Player.curHealth = $YSort/Player.maxHealth
		Global.player_max = $YSort/Player.maxHealth
		$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
		
		$TextBox.start_text_write("Wow! I feel better and stronger!", 1, Vector2(186,2))
		
		if !HubMechanics.level3HeartGrabbed:
			$HeartPickup.queue_free()
			HubMechanics.level3HeartGrabbed = true
		
func _on_wall_zone_entered(body, wall):
	if body.get_parent().is_in_group("Rocks"):
		wall.queue_free()
		body.queue_free()


func _on_waystone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		HubMechanics.pink_waystone = true
		get_tree().change_scene_to_file("res://levels/hub_level.tscn")


func _on_stair_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		HubMechanics.fromLevel3 = !HubMechanics.fromLevel3
		get_tree().change_scene_to_file("res://levels/hub_level.tscn")
