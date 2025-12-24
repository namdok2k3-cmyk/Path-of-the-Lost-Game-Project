extends Camera2D
var targetPos
const moveThreshold = 120
var wallGone = false
func _physics_process(delta):
	targetPos = $"/root/level_four/YSort/Player".position
	
	var differenceVec = position - targetPos
	if wallGone:
		position = lerp(position,targetPos,0.01)
	elif differenceVec.length()>10:
		position = lerp(position,targetPos,0.05)
	position = Vector2i(position)
	if position.x<540 and !wallGone:
		position.x=540
