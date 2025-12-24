extends Node2D

var fadeBlack = false
var alpha = 0
var alphaBlack = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$YSort/Player.maxHealth = Global.player_max
	Global.dashBoots = true
	$YSort/Player.dashBoots = true
	Global.liftGloves = true
	$YSort/Player.liftGloves = true
	 
	$YSort/Player/AnimatedSprite2D.animation = "Right"
	get_window().content_scale_size = Vector2i(800, 450)
	Global.image = Global.ARROWIMG
	Global.setMouse()
	$CanvasLayer/HealthBar.updateHealth($YSort/Player.maxHealth,$YSort/Player.curHealth)
	$YSort/Player.connect("damageTaken", $CanvasLayer/HealthBar.updateHealth)
	$YSort/Player.connect("dead", $CanvasLayer/DeathMenu._player_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fadeBlack&&alphaBlack < 1:
		alphaBlack += delta
		$BGBlack.material.set_shader_parameter("alpha",alphaBlack)
	elif fadeBlack:
		get_tree().change_scene_to_file("res://levels/level_eight.tscn")

func _on_spawn_beast_area_entered(area: Area2D) -> void:
	if area.name == "ArrowCollider":
		$Beast.startChase()
		remove_child($SpawnBeast)

func _on_lvl_eight_area_entered(area: Area2D) -> void:
		fadeBlack = true
