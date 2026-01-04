extends Node2D

signal interacted
@export var player:CharacterBody2D
var big = false

func _ready() -> void:
	#idle animation when player in mid-range, loops automatically
	$AnimationPlayer.play("sparkle")

func _process(delta: float) -> void:
	#dissapears when text is open, reappears when its closed.
	if !Global.textLock:
		visible = true

	# this is a positive number if the player is facing the spark regardless of their position on the non-facing axis
	var isFacing = player.facing.dot(global_position)-player.facing.dot(player.global_position)
	# vector for math purposes, perpendicular to facing
	var notFacing=Vector2.ONE-abs(player.facing)
	# distance from the player to the spaark in the direction they are NOT facing
	var otherAxisDist = abs(notFacing.dot(global_position)-notFacing.dot(player.global_position))
	
	# if player is facing and actually close to spark
	#this controlls interactible distance (big = player can currently interact)
	if isFacing>0 && isFacing<35 && otherAxisDist<15 && !big:
		big = true
		$AnimationPlayer.play("getBig")
		$AnimationPlayer.queue("idle")
		$AnimationPlayer.queue("spin")
		
	elif (isFacing <0 || isFacing>=35 || otherAxisDist>=15) && big:
		big = false
		$AnimationPlayer.play("sparkle")
	
func _input(event: InputEvent) -> void:
	# player can currently interact
	if big and !Global.textLock and Input.is_action_just_released("interact"):
		emit_signal("interacted")
		visible = false
		
func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	#loop animation sequence
	if new_name == "spin":
		$AnimationPlayer.queue("idle")
		$AnimationPlayer.queue("spin")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	#outer visible radius for small spark
	if body.name=="Player":
		$Spark.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	#outer visible radius for small spark
	if body.name=="Player":
		$Spark.visible = false
		
