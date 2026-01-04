extends Camera2D
var targetPos
const moveThreshold = 120

@export var target : Node2D
	
func _physics_process(delta):
	targetPos = target.position
	
	var differenceVec = position - targetPos
	
	if differenceVec.length()>10:
		position = lerp(position,targetPos,0.05)
	position = Vector2i(position)
