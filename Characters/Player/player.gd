extends CharacterBody2D

signal newArrow
signal damageTaken
signal dead

const WALK_SPEED = 100.0
const BOW_WALKSPEED = 80.0

var direction = 0
var facing = Vector2(1,0)
var pullArrow = false

var lockMovement = false

var activeBow = true; 

var dashBoots
var liftGloves

# 2 hp is one heart
@export var maxHealth:int
var curHealth

func _ready() -> void:
	maxHealth = Global.player_max
	curHealth = maxHealth

	if facing[1]<0:
		$AnimatedSprite2D.play("Up")
	if facing[1]>0:
		$AnimatedSprite2D.play("Down")
	if facing[0]>0:
		$AnimatedSprite2D.play("Right")
	if facing[0]<0:
		$AnimatedSprite2D.play("Left")

	dashBoots = Global.dashBoots
	liftGloves = Global.liftGloves


func _physics_process(delta):
	if curHealth<=0 or Global.textLock:
		return
	process_inputs()
	if pullArrow:
		#rotate bow to face mouse
		$Bow.rotation=Vector2.ZERO.direction_to(get_local_mouse_position()).angle()
		
		#bow z is relative to player. 
		#this makes it so bow is behind player when pointed up
		if $Bow.rotation_degrees>0:
			$Bow.z_index=1
		else:
			$Bow.z_index=-1
	
		
	move_and_slide()
	
func process_inputs():
	if activeBow:
		if(Input.is_action_just_pressed("shoot")):
			pullArrow = true
			$Bow.visible=true
			
			#arrow charge timer
			$Bow/Timer.start()
			$Draw.play()
			
		elif(Input.is_action_just_released("shoot")):
			$Draw.stop()
			#if arrow fully charged
			if ($Bow/Timer.is_stopped()&&pullArrow):
				$Release.play()
				var arrowDir=Vector2.ZERO.direction_to(get_local_mouse_position())
				emit_signal("newArrow",arrowDir, position,$ArrowCollider)
				
			pullArrow = false
			$Bow.visible=false
			
	direction = Input.get_vector("left","right","up","down",)
		
	if direction:
		facing = direction
	else:
		if facing[0] and facing[1]:
			facing[0]=0
	if _check_player_moving():
		if facing[1]<0:
			if dashBoots && !liftGloves:
				$AnimatedSprite2D.play("up_boots")
			elif !dashBoots && liftGloves:
				$AnimatedSprite2D.play("up_gloves")
			elif dashBoots && liftGloves:
				$AnimatedSprite2D.play("up_BaG")
			else:
				$AnimatedSprite2D.play("Up")
		if facing[1]>0:
			if dashBoots && !liftGloves:
				$AnimatedSprite2D.play("down_boots")
			elif !dashBoots && liftGloves:
				$AnimatedSprite2D.play("down_gloves")
			elif dashBoots && liftGloves:
				$AnimatedSprite2D.play("down_BaG")								
			else:
				$AnimatedSprite2D.play("Down")
		if facing[0]>0:
			if dashBoots && !liftGloves:
				$AnimatedSprite2D.play("right_boots")
			elif !dashBoots && liftGloves:
				$AnimatedSprite2D.play("right_gloves")
			elif dashBoots && liftGloves:
				$AnimatedSprite2D.play("right_BaG")				
			else:
				$AnimatedSprite2D.play("Right")
		if facing[0]<0:
			if dashBoots && !liftGloves:
				$AnimatedSprite2D.play("left_boots")
			elif !dashBoots && liftGloves:
				$AnimatedSprite2D.play("left_gloves")
			elif dashBoots && liftGloves:
				$AnimatedSprite2D.play("left_BaG")								
			else:
				$AnimatedSprite2D.play("Left")
	else:
		$AnimatedSprite2D.stop()

	if !lockMovement:
		
		
		#player can only dash again after brief cooldown
		if Input.is_action_just_pressed("dash") && $DashCooldown.is_stopped() && dashBoots:
			$Dash.play()
			#dictates length of dash
			$DashTimer.start()
			
			$DashCooldown.start()
			velocity = 1000.00 * facing
		var walkSpeed
		if pullArrow:
			walkSpeed = BOW_WALKSPEED
		else:
			walkSpeed = WALK_SPEED
		
		#only perform regular movement if not in a dash
		if $DashTimer.is_stopped():
			if direction:
				velocity = lerp(velocity, direction*walkSpeed, 0.3)
			else:
				velocity = Vector2(move_toward(velocity.x, 0, WALK_SPEED), move_toward(velocity.y, 0, WALK_SPEED))
		else:
			#if dashing, velocity approaches walk speed
			velocity = lerp(velocity, WALK_SPEED*facing, 0.2)
		
	

# Player struck by arrow. 1 heart damage
func _on_arrow_collider_child_entered_tree(node: Node) -> void:
	if (node.is_in_group("Arrow")):
		node.connect("breakArrow", _on_arrow_break)
		takeDamage(2)
	elif(node.is_in_group("proj")):
		takeDamage(1)

# damageTaken signal recieved by healthbar, connected in main
func takeDamage(amount):
	if curHealth >0:
		if randi_range(0,1)==0:
			$hit1.play()
		else:
			$hit2.play()
		curHealth-=amount
		emit_signal("damageTaken",maxHealth,curHealth)
	if curHealth <=0:
		emit_signal("dead")

# If arrow stuck in player breaks, take 1/2 heart damage
func _on_arrow_break(a, b, c):
	takeDamage(1)
	
func _check_player_moving():
	return Input.is_action_pressed("up") || Input.is_action_pressed("down") || Input.is_action_pressed("left") || Input.is_action_pressed("right")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	takeDamage(1)
	
