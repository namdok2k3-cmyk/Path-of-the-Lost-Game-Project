extends Node2D
var arrowScene = preload("res://arrow/arrow.tscn")
var arrows = []
var fadeOut = false
var alpha = 0
var b1 = 0
var b2 = 0
var wallGone = false
var lightSpark = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$YSort/Player.maxHealth = Global.player_max
	Global.dashBoots = true
	$YSort/Player.dashBoots = true
	Global.liftGloves = true
	$YSort/Player.liftGloves = true
	
	get_window().content_scale_size = Vector2i(480, 270)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
	$YSort/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$YSort/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)
	
	get_viewport().set_snap_2d_transforms_to_pixel(true)

func _process(delta: float) -> void:
	if !lightSpark and $Light/object.stuck:
		lightSpark = true
		$Spark2.queue_free()
	if wallGone and !Global.textLock:
		wallGone = false
		$ExitCover.queue_free() 
		$Spark.queue_free()
		$exit.visible = true
		$Camera2D.wallGone=true
func _physics_process(delta: float) -> void:
	if fadeOut && alpha<1:
		alpha+=0.02
		$CanvasLayer/Black.material.set_shader_parameter("alpha",alpha)
	elif fadeOut:
		get_tree().change_scene_to_file("res://levels/trans4to5.tscn")

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

func checkButtons():
	if b1!=0 and b2!=0:
		$ArrowGate/Arrowgate.visible = false
		$ArrowGate/CollisionShape2D.set_deferred("disabled",true)
	else:
		$ArrowGate/Arrowgate.visible = true
		$ArrowGate/CollisionShape2D.set_deferred("disabled",false)

func _on_but_1_body_entered(body: Node2D) -> void:
	b1+=1
	$butdown.play()
	$But1/AnimatedSprite2D.play("down")
	checkButtons()


func _on_but_2_body_entered(body: Node2D) -> void:
	b2+=1
	$butdown.play()
	$But2/AnimatedSprite2D.play("down")
	checkButtons()


func _on_but_2_body_exited(body: Node2D) -> void:
	b2-=1
	$butup.play()
	$But2/AnimatedSprite2D.play("up")
	checkButtons()


func _on_but_1_body_exited(body: Node2D) -> void:
	b1-=1
	$butup.play()
	$But1/AnimatedSprite2D.play("up")
	checkButtons()


func _on_lever_hit(node):
	if (node.is_in_group("Arrow")):
		$butdown.play()
		$Lever/AnimatedSprite2D.play("on")
		$DoorSounds.play()
		$StaticBody2D/Puzzgate.visible = false
		$StaticBody2D/CollisionShape2D.set_deferred("disabled",true)


func _on_but_3_body_entered(body: Node2D) -> void:
	if($StaticBody2D2/EndGate.visible == true):
		$butdown.play()
		$DoorSounds.play()
		$But3/AnimatedSprite2D.play("down")
		$StaticBody2D2/EndGate.visible = false
		$StaticBody2D2/CollisionShape2D.set_deferred("disabled",true)


func _on_spark_interacted() -> void:
	if $Spark.global_position.distance_to($Light/object.global_position)<100:
		$CanvasLayer/TextBox.start_text_write("There's a switch hidden in the wall!",1,Vector2(100,0))
		wallGone = true
	else: 
		$CanvasLayer/TextBox.start_text_write("Looks like something's here but... It's too dark to see.",1,Vector2(100,0))
		


func _on_to_lvl_5_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		fadeOut = true
		$CanvasLayer/Black.visible = true
		


func _on_spark_2_interacted() -> void:
	$CanvasLayer/TextBox.start_text_write("I should be able to lift this with my glove.",1,Vector2(100,0))
	$Spark2.queue_free()
	lightSpark = true
