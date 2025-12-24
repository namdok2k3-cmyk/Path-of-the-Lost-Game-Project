extends CharacterBody2D

var moveSpeed = 50
const MAX_HEALTH = 30
var cur_health = MAX_HEALTH
var state = "idle"

var timesUnseen = 0
var aggroOverride = false
var facing = Vector2(1,0)
var facingLast = facing
var prevpos = position
signal newArrow
@export var idlePos:Vector2

@export var target_node: CharacterBody2D


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Global.textLock:
		return
		
	prevpos = position
	move_and_slide()
	if (prevpos.distance_squared_to(position)<1):
		state="idle"
		$AttackCooldown.start
		moveSpeed = 50
		
	
func aggro_override(val):
	aggroOverride=val
	if val:
		timesUnseen=0
		$Emote.play("notice")
		moveSpeed = 150
		state = "towards"

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

# Check sightline every 1/4 secs 
# specifically, if any sight-blocking objects (phys layer 2) between self and player
func _on_sight_check_timeout() -> void:
	
		
	if !aggroOverride:
		
		# raycast to player
		$SightLine.target_position=target_node.global_position-global_position
		$SightLine.force_raycast_update()

		if ($AttackCooldown.is_stopped() and !$SightLine.is_colliding() and target_node.global_position.distance_to(global_position) < 200):
			
			if abs(facing.angle_to(global_position.direction_to(target_node.global_position)))<0.2:
				$Emote.play("notice")
				moveSpeed = 150
				state = "towards"
				velocity=moveSpeed*facing

func _on_move_timer_timeout() -> void:
	if state=="idle":
		var rm = randi_range(0,2)
		if rm == 0:
			var rd = randi_range(-1,1)
			var newVec = Vector2(facing.y,facing.x)
			if rd!=0:
				newVec*=rd
			facing = newVec
			velocity = facing * moveSpeed
			
			if (facing.x==-1):
				$AnimatedSprite2D.play("left")
			elif (facing.x==1):
				$AnimatedSprite2D.play("right")
			elif (facing.y==-1):
				$AnimatedSprite2D.play("up")
			elif (facing.y==1):
				$AnimatedSprite2D.play("down")
			
		else:
			velocity = Vector2.ZERO
			if (facing.x==-1):
				$AnimatedSprite2D.play("leftStill")
			elif (facing.x==1):
				$AnimatedSprite2D.play("rightStill")
			elif (facing.y==-1):
				$AnimatedSprite2D.play("upStill")
			elif (facing.y==1):
				$AnimatedSprite2D.play("downStill")

func _on_hitbox_area_entered(area: Area2D) -> void:
	state="back"
	$BackTime.start()
	$AttackCooldown.start()
	moveSpeed = 50
	velocity=150*-facing


func _on_back_time_timeout() -> void:
	state="idle"
	velocity = Vector2.ZERO
