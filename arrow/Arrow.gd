extends RayCast2D

#direction vector
var unitVec

var origin_collider

#is arrow moving?
var fire = false

#color is slightly randomized
var randBrown = randf_range(-0.2, 0.1)

#see draw_multiline_colors in docs
var arrowColors =  PackedColorArray([
	Color(0.8, 0.8, 0.8), 
	Color(0.8, 0.8, 0.8),
	Color(0.6+randBrown, 0.2+randBrown, 0.1+randBrown),
	Color(0, 0, 0)
])
var arrowParts

var area = Area2D.new()
const ARROW_SPEED = 22

signal breakArrow

func _physics_process(delta):
	if fire:
		#detect if moving arrow hits object
		if is_colliding():
			
			#set collider as arrow's parent
			var collider = get_collider()
			if collider!=origin_collider:
				if "softhit" in collider.get_groups():
					$SoftHit.play()
				else:
					$Hit.play()
				get_parent().remove_child(self)
				collider.add_child(self)
				fire=false
				
				#ensures tip of arrow stuck to collider
				position = (get_collision_point()-unitVec*22)-get_parent().global_position
				
				#start despawn timer
				$Timer.start()
				
				#make arrow breakable
				area.connect("area_entered",_on_area_entered)
				area.connect("body_entered",_on_area_entered)
			else:
				position = position + unitVec*ARROW_SPEED
		else:
			#move arrow along direction vector
			position = position + unitVec*ARROW_SPEED
			
	queue_redraw()

func _draw():
	draw_multiline_colors(arrowParts, arrowColors)

#ready can't be called with params
#so init function must be called after instantiation
func init(unit, pos, o_c):
	origin_collider=o_c
	unitVec = unit
	position=pos
	
	#arrow only fires once init is called
	fire = true
	
	#target_position relative to position.
	#arrow length + amnt moved per frame
	target_position = unitVec*22 + unitVec*ARROW_SPEED
	
	#see draw_multiline_colors in docs
	#parts calculated based on unit vec. in order: 
	#	right feather
	#	left feather
	#	stick
	#	head
	arrowParts = PackedVector2Array([
		#0.5*unitVec.orthogonal() pushes feathers are a bit to the side
		0.5*unitVec.orthogonal(), 6 * unitVec + 0.5 * unitVec.orthogonal(), 
		-0.5*unitVec.orthogonal(), 6 * unitVec - 0.5 * unitVec.orthogonal(),
		unitVec*4,  unitVec*20, 
		unitVec*(20), unitVec*22
	])

	z_index=3
	y_sort_enabled = true

	#Initialize arrow break collider
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(2,12)
	var shape = CollisionShape2D.new()
	shape.shape = rect
	area.add_child(shape)
	area.rotate(unitVec.angle()+PI/2)
	area.position=unitVec*10
	area.monitoring=true
	area.monitorable=true
	area.set_collision_layer_value(1,false)
	add_child(area)

#detect collision with object for break
func _on_area_entered(obj):
	if obj != get_parent():
		emit_signal("breakArrow", unitVec, global_position,randBrown)
		queue_free()

#arrows despawn after timeout
func _on_timer_timeout():
	queue_free()
