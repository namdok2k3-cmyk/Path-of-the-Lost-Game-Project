extends CharacterBody2D

@export var target: Node2D
@export var camera: Camera2D
var rockScene = preload("res://Characters/Beast/thrown_rock.tscn")

var chase = false
const SPEED = 4000
const SPRING = 10
const DAMP = 2.0 * sqrt(SPRING)
const rockSpeed = 30000

func _ready() -> void:
	$PlayerDeath/CollisionShape2D.set_deferred("disabled",true)
	$PlayerDamage/CollisionShape2D.set_deferred("disabled",true)
	$ThrowTimer.wait_time = 3
	
func startChase():
	$PlayerDeath/CollisionShape2D.set_deferred("disabled",false)
	$PlayerDamage/CollisionShape2D.set_deferred("disabled",false)
	chase = true;
	visible = true
	$ThrowTimer.start()

func endChase():
	chase = false
	$ThrowTimer.stop()

func _process(delta: float) -> void:	
	var screenSize = get_window().content_scale_size
	
	if chase:
		camera.limit_left = position.x - 100
		if position.x > 1800:
			velocity = Vector2.ZERO
			endChase()
		elif position.x < camera.position.x - screenSize.x / 2:
			var idealPos = camera.position.x - screenSize.x / 2 + 50
			var displacement = position.x - idealPos
			var springAccel = (-SPRING * displacement) - (DAMP * velocity.x)
			velocity.x += springAccel * delta
		
		else:
			velocity = SPEED * delta * Vector2.RIGHT
	move_and_slide()

func _on_throw_timer_timeout() -> void:
	var spawns = [$SpawnLocation1.position, $SpawnLocation2.position]
	var spawnLocation = spawns[randi_range(0,1)] 
	var rockDirection = (spawnLocation+position).direction_to(target.position)	
	$ThrowTimer.wait_time = randf_range(0.75,1.25)
	var rock = rockScene.instantiate()
	rock.position = spawnLocation
	rock.direction = rockDirection
	rock.speed = rockSpeed
	add_child(rock)

func _on_player_death_area_entered(area: Area2D) -> void:
	if area.name == "ArrowCollider":
		target.takeDamage(9999)
