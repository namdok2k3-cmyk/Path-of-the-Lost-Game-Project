extends CharacterBody2D

var moveSpeed = 150
@export
var MAX_HEALTH = 1
var cur_health
var state = "wait"
var failedAtks = 0
var circDir = 1
var timesUnseen = 0
var aggroOverride = false
@export
var dir = 1
signal newArrow
@export var atkPos:Vector2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var target_node: CharacterBody2D
var movement_target_position: Vector2

#TODO: fix? enemy dodges after bowshot
#TODO: enemy tries not to dodge into walls?
#TODO: enemy tries to dodge away from player aim, rather than randomly?
	 # Player could then "Push" enemy into wall, breaking the arrows stuck in it
func _ready():
	cur_health = MAX_HEALTH
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 10.0
	movement_target_position = Vector2(position.x,position.y+100*dir)
	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
	$Bow/Timer.timeout.connect(bowTimeout)
	#Enemy bow charge longer than player's
	$Bow/Timer.wait_time=1.5
	$Bow.visible = false

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
func moveToAttack():
	state = "toward"

func _physics_process(delta: float) -> void:
	if Global.textLock:
		return
	#Velocity summed to by towards and circle movement, so it must start at 0
	velocity = Vector2.ZERO
	
	#NAVIGATION DEBUG
	#$TargerMarker.global_position = movement_target_position
	
	#Point bow toward player, with lerp for smooth movement/realism
	$Bow.rotation=lerp_angle($Bow.rotation, global_position.direction_to(target_node.global_position).angle(), 0.1)
	if $Bow.visible:
		var facing = Vector2(0,0)
		var lookat = global_position.direction_to(target_node.global_position)
		if (abs(lookat.x)>abs(lookat.y)):
			facing.x=lookat.x/abs(lookat.x)
		else:
			facing.y=lookat.y/abs(lookat.y)
		if (facing.x==-1):
			$AnimatedSprite2D.play("leftStill")
		if (facing.x==1):
			$AnimatedSprite2D.play("rightStill")
		if (facing.y==-1):
			$AnimatedSprite2D.play("upStill")
		if (facing.y==1):
			$AnimatedSprite2D.play("downStill")
	
	#If idle, just go to idle position
	if state =="toward":
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * moveSpeed
	
	if !$Bow.visible:
		var facing = Vector2(0,0)
		if (abs(velocity.x)>abs(velocity.y)):
			facing.x=velocity.x/abs(velocity.x)
		else:
			facing.y=velocity.y/abs(velocity.y)
		if (facing.x==-1):
			$AnimatedSprite2D.play("left")
		if (facing.x==1):
			$AnimatedSprite2D.play("right")
		if (facing.y==-1):
			$AnimatedSprite2D.play("up")
		if (facing.y==1):
			$AnimatedSprite2D.play("down")
	move_and_slide()

#Struck by arrow
func _on_arrow_collider_child_entered_tree(node: Node) -> void:
	if (node.is_in_group("Arrow")):
		node.connect("breakArrow", _on_arrow_break)
		takeDamage(10)

func _on_arrow_break(a, b, c):
	takeDamage(5)
	
func takeDamage(amount):
	if state == "attack":
		$hit.play()
		cur_health-=amount
		if cur_health <=0:
			queue_free()
		
#75% chance to fire bow every 2 secs IF not backing or dodging
func _on_attack_timer_timeout() -> void:
	if Global.textLock:
		return
	$Bow.visible=true
	$Bow/Timer.start()
	$Draw.play()
	
#Bow finishes charging, signal from bow scene
func bowTimeout():
	$Bow.visible=false
	$AttackTimer.start()
	#recieved by main
	$Release.play()
	emit_signal("newArrow",global_position.direction_to(target_node.global_position), position, $ArrowCollider)

#When enemy reaches player
func _on_navigation_agent_2d_navigation_finished() -> void:
	state="attack"
	$AttackTimer.start()
