extends RayCast2D

#direction vector
var unitVec

#is arrow moving?
var fire = false

const ARROW_SPEED = 11

func _physics_process(delta):
	if fire:
		#detect if moving arrow hits object
		if is_colliding():
			
			#set collider as arrow's parent
			var collider = get_collider()
			if "softhit" in collider.get_groups():
				$SoftHit.play()
			else:
				$Hit.play()
			get_parent().remove_child(self)
			collider.add_child(self)
			
			queue_free()
			
		else:
			#move arrow along direction vector
			position = position + unitVec*ARROW_SPEED
			

#ready can't be called with params
#so init function must be called after instantiation
func init(unit, pos):
	unitVec = unit
	position=pos
	
	#arrow only fires once init is called
	fire = true
	
	#target_position relative to position.
	#arrow length + amnt moved per frame
	target_position = unitVec + unitVec*ARROW_SPEED

	z_index=3
	y_sort_enabled = true

	#Initialize arrow break collider
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(2,12)
	var shape = CollisionShape2D.new()
	shape.shape = rect
