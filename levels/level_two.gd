extends Node2D
var projScene = preload("res://projectile/proj.tscn")
var arrowScene = preload("res://arrow/arrow.tscn")
var arrows = []
var START = Vector2(904, 234)

var first_dunk = true

func _ready() -> void:
	get_window().content_scale_size = Vector2i(480, 270)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	
	$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
	$YSort/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$YSort/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)
	$YSort/Player/AnimatedSprite2D.animation = "Left"
	$YSort/Player/AnimatedSprite2D.frame = 0
	
	for waterZone in get_tree().get_nodes_in_group("WaterZones"):
		waterZone.body_entered.connect(_on_water_zone_entered.bind(waterZone))
	for dashZone in get_tree().get_nodes_in_group("DashZones"):
		dashZone.body_entered.connect(_on_dash_zone_entered.bind(dashZone))
	for dashZone in get_tree().get_nodes_in_group("DashZones"):
		dashZone.body_exited.connect(_on_dash_zone_exited.bind(dashZone))
		
	if HubMechanics.level2HeartGrabbed:
		$HeartPickup.queue_free()
	
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	Global.textLock=true
	$TextBox.start_text_write("Those bridges don't look very safe. I should move quickly... (use shift to dash)", 1, Vector2(670, 137))
	
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
	
#signal recieved from player or enemy
func _on_new_proj(unitVec, firePos):
	
	#spawn new arrow with direction and position
	var newProj = projScene.instantiate()
	newProj.init(unitVec,firePos)
	
	#moving arrows are child of main scene
	add_child(newProj)

func _on_waystone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		HubMechanics.green_waystone = true
		get_tree().change_scene_to_file("res://levels/hub_level.tscn")
		
func _on_dash_zone_entered(body,zone):
	if body.name == "Player":
		$DashZones/bridge_timer.start()
		
func _on_dash_zone_exited(body,zone):
	if body.name == "Player":
		$DashZones/bridge_timer.stop()
		zone.visible = false

func _on_water_zone_entered(body,zone):
	if body.name == "Player":
		$YSort/Player.position = START

func _on_stair_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		HubMechanics.fromLevel2 = !HubMechanics.fromLevel2
		get_tree().change_scene_to_file("res://levels/hub_level.tscn")

func _on_bridge_timer_timeout() -> void:
	$DashZones/bridge_timer.stop()
	$YSort/Player.position = START
	
	if first_dunk == true:
		$TextBox.start_text_write("The bridge is broken, but I think I can still make it...", 1, Vector2(670, 137))
		first_dunk = false
		
func _on_heart_pickup_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$YSort/Player.maxHealth += 2
		$YSort/Player.curHealth = $YSort/Player.maxHealth
		Global.player_max = $YSort/Player.maxHealth
		$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
		
		$TextBox.start_text_write("Wow! I feel better and stronger!", 1, Vector2(33, 8))
		if !HubMechanics.level2HeartGrabbed:
			$HeartPickup.queue_free()
			HubMechanics.level2HeartGrabbed = true
		
