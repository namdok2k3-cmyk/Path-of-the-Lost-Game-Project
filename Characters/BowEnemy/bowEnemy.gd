extends CharacterBody2D

var moveSpeed = 150
@export
var MAX_HEALTH = 30
var cur_health
var state = "idle"
var failedAtks = 0
var circDir = 1
var timesUnseen = 0
var aggroOverride = false
signal newArrow
@export var idlePos:Vector2

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
	movement_target_position = idlePos
	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
	$Bow/Timer.timeout.connect(bowTimeout)
	#Enemy bow charge longer than player's
	$Bow/Timer.wait_time=1.5
	$Bow.visible = false
	$AttackTimer.wait_time+=randf_range(0,0.2)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _process(delta: float) -> void:

	#Recalc path if player moves too far from target
	if state=="towards" and target_node.global_position.distance_to(movement_target_position)>20:
		movement_target_position = target_node.global_position
		set_movement_target(movement_target_position)
	#Calc path and move toward if player is too far from self
	if state=="circling" and target_node.global_position.distance_to(global_position)>105:
		moveSpeed = 150
		state = "towards"
		movement_target_position = target_node.global_position
		set_movement_target(movement_target_position)


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
	if state =="idle":
		if global_position.distance_to(movement_target_position)>20:
			moveSpeed = 100
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * moveSpeed
	else:
		#Distance to target
		var curdist = target_node.global_position.distance_to(global_position)
		#If player gets too close, back away.
		if curdist<90:
			state = "back"
		#if needs to move toward player
		if state == "towards" and !navigation_agent.is_navigation_finished():
			moveSpeed = 150
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()
			#Stops when firing arrow
			if !$Bow.visible:
				#Velocity toward slows when gets close, for smooth transition to circling. uses sigmoid-like function. 
				velocity = current_agent_position.direction_to(next_path_position) * (moveSpeed*1/(1+1.1**(-curdist+150)))
		
		#Stops when firing arrow
		if !$Bow.visible:
			#Circle at least 100 units from player
			var circDist = max(curdist,100)
			#Angle from target to self
			var curangle = target_node.global_position.direction_to(global_position).angle()
			#Angle to target pos around circle
			var newangle = fmod(curangle+circDir*PI/8, 2*PI)
			#Direction to move in
			var moveDir = (-global_position + target_node.global_position+Vector2(circDist * cos(newangle),circDist * sin(newangle))).normalized()
			#if player aims toward self, and not already dodging, dodge.
			if state!="dodge" and $DodgeDelay.is_stopped() and((target_node.pullArrow && abs((get_global_mouse_position()-target_node.global_position).angle()-(global_position-target_node.global_position).angle())<40/curdist)):
				$DodgeDelay.start()
			#Back away until past threshold
			if state=="back" and curdist<120:
				moveSpeed = 200
				moveDir = (global_position - target_node.global_position).normalized()
			#Threshold has been passed
			elif state=="back":
				state="circling"
			#Normal circle behaviour
			elif state!="dodge" and state!="back":
				moveSpeed = 50
			#Add circular velocity
			velocity += moveDir*moveSpeed
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
	
func aggro_override(val):
	aggroOverride=val
	if val:
		timesUnseen=0
		$Emote.play("notice")
		moveSpeed = 150
		state = "towards"
		movement_target_position = target_node.global_position
		set_movement_target(movement_target_position)

#Struck by arrow
func _on_arrow_collider_child_entered_tree(node: Node) -> void:
	if (node.is_in_group("Arrow")):
		node.connect("breakArrow", _on_arrow_break)
		takeDamage(10)

func _on_arrow_break(a, b, c):
	takeDamage(5)
	
func takeDamage(amount):
	$hit.play()
	cur_health-=amount
	if cur_health <=0:
		queue_free()
		
#75% chance to fire bow every 2 secs IF not backing or dodging
func _on_attack_timer_timeout() -> void:
	if Global.textLock:
		return
	if (state == "towards"  or state == "circling") and timesUnseen==0 and randi_range(0,4)!=0:
		$Bow.visible=true
		$Bow/Timer.start()
		$Draw.play()
		$AttackTimer.stop()
	
#Bow finishes charging, signal from bow scene
func bowTimeout():
	$Bow.visible=false
	$AttackTimer.start()
	#recieved by main
	$Release.play()
	emit_signal("newArrow",global_position.direction_to(target_node.global_position), position, $ArrowCollider)

#When enemy reaches player
func _on_navigation_agent_2d_navigation_finished() -> void:
	if state != "idle":
		state= "circling"
		moveSpeed=50

#When circling player, switch direction every so often
func _on_circ_timer_timeout() -> void:
	if (state != "dodge"):
		#random int of either -1 or 1
		circDir = randi_range(0,1) * -2 + 1

#Dash timer determines dodge length before rechecking player aim direction
func _on_dash_timer_timeout() -> void:
	#random int of either -1 or 1
	#Without this, enemy will keep dodging in same direction if player follows them with mouse
	circDir = randi_range(0,1) * -2 + 1
	
	moveSpeed=50
	state = "circling"

# Check sightline every 1/4 secs
# specifically, if any sight-blocking objects (phys layer 2) between self and player
func _on_sight_check_timeout() -> void:
	if !aggroOverride:
		# raycast to player
		$SightLine.target_position=target_node.global_position-global_position
		$SightLine.force_raycast_update()
		#will return to idle if 5 seconds (20 checks) occur with no sightline
		if state!="idle":
			#detect sight-block on physics layer 2
			if ($SightLine.is_colliding()):
				timesUnseen+=1
			else:
				timesUnseen = 0
			# 20/4 = 5 seconds
			if timesUnseen >= 20:
				#return to idle state and go to idle position
				$Emote.play("confuse")
				timesUnseen = 0
				state = "idle"
				movement_target_position = idlePos
				set_movement_target(movement_target_position)
		else:
			# player spotted, exit idle state
			if (!$SightLine.is_colliding() and target_node.global_position.distance_to(global_position) < 200):
				$Emote.play("notice")
				moveSpeed = 150
				state = "towards"
				movement_target_position = target_node.global_position
				set_movement_target(movement_target_position)


func _on_dodge_delay_timeout() -> void:
	moveSpeed = 300
	$DashTimer.start()
	state = "dodge"
