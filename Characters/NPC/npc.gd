extends CharacterBody2D
@export var player:CharacterBody2D
signal trigger_dialogue
var dialogue = "Greetings traveller"
func _ready() -> void:
	$Spark.player = player


func _on_spark_interacted() -> void:
	emit_signal("trigger_dialogue", dialogue,global_position)
