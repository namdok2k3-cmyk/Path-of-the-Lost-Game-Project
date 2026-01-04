
extends CharacterBody2D

const MAX_HEALTH = 30
var cur_health = MAX_HEALTH
var state = "hidden"
var timesUnseen = 0
var aggroOverride = false
signal newProj
@export var target_node: CharacterBody2D

var textureArray:Array


func _ready():
	var t  = load("res://Characters/WaterEnemy/0.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/1.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/2thru7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/2thru7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/2thru7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/2thru7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/2thru7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/7.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/8.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/9.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/10.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/11.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/12.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/13.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/14.png")
	textureArray.append(t)
	t  = load("res://Characters/WaterEnemy/15.png")
	textureArray.append(t)
	
	
	$AttackTimer.wait_time+=randf_range(0,0.2)

func _physics_process(delta: float) -> void:
	$AtkSprite.texture= textureArray[floor((fmod(360-rad_to_deg(global_position.direction_to(target_node.global_position).angle()),360)/22.5))]
	
func aggro_override(val):
	aggroOverride=val
	if val:
		timesUnseen=0
		$Emote.play("notice")
		state = "attack"

#Struck by arrow
func _on_arrow_collider_child_entered_tree(node: Node) -> void:
	if (node.is_in_group("Arrow")):
		node.connect("breakArrow", _on_arrow_break)
		takeDamage(10)

func _on_arrow_break(a, b, c):
	takeDamage(5)
	
func takeDamage(amount):
	cur_health-=amount
	if cur_health <=0:
		queue_free()
		
func _on_attack_timer_timeout() -> void:
	if Global.textLock:
		return
	if (state == "attack"):
		#$Fire.play()
		emit_signal("newProj",global_position.direction_to(target_node.global_position), position)

# Check sightline every 1/4 secs
# specifically, if any sight-blocking objects (phys layer 2) between self and player
func _on_sight_check_timeout() -> void:
	if !aggroOverride:
		# raycast to player
		$SightLine.target_position=target_node.global_position-global_position
		$SightLine.force_raycast_update()
		#will return to idle if 5 seconds (20 checks) occur with no sightline
		if state!="hidden":
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
				state = "hidden"
				$AtkSprite.visible = false
				$HideSprite.visible = true

		else:
			# player spotted, exit idle state
			if (!$SightLine.is_colliding() and target_node.global_position.distance_to(global_position) < 200):
				$Emote.play("notice")
				$AtkSprite.visible = true
				$HideSprite.visible = false
				state = "attack"
