extends RigidBody2D
var randBrown

#see draw_multiline_colors in docs
#this initialization is just to prevent a crash if draw is called before init
var arrowColors =  PackedColorArray([
	Color(0.8, 0.8, 0.8), 
	Color(0.8, 0.8, 0.8),
	Color(0.6, 0.2, 0.1),
])

#see draw_multiline_colors in docs
#this initialization is just to prevent a crash if draw is called before init
var arrowParts = PackedVector2Array([
	Vector2.ZERO, Vector2.ZERO, 
	Vector2.ZERO, Vector2.ZERO,
	Vector2.ZERO,  Vector2.ZERO
])

#direction vec
var unitVec

#see _integrate_forces below. move needs to be done only once
var do_move = false

#values for _integrate_forces
var set_angle = 0
var set_pos=null

func _draw():
	draw_multiline_colors(arrowParts, arrowColors)

#have to do this to manually control RigidBody2D forces
func _integrate_forces(state):
	if do_move:
		do_move = false
		var xform = state.get_transform().rotated(set_angle)
		xform = xform.translated(set_pos)
		state.set_transform(xform)
		init_post_move()

#ready can't be called with params
#so init function must be called after instantiation
#initialization split into 2 functions cause _integrate_forces has gotta happen in it's own time
func init(unit, pos, randBrown):
	
	#see draw_multiline_colors in docs
	arrowColors =  PackedColorArray([
		Color(0.8, 0.8, 0.8), 
		Color(0.8, 0.8, 0.8),
		Color(0.6+randBrown, 0.2+randBrown, 0.1+randBrown),
	])
	set_angle = unit.angle()
	set_pos=pos+6*unit
	do_move = true
	
#i left init to do just the stuff necessary for _integrate_forces. all the other init stuff goes here
func init_post_move():
	z_index = 2
	unitVec = Vector2(0,1)
	
	#see draw_multiline_colors in docs
	arrowParts = PackedVector2Array([
		0.5*unitVec.orthogonal()-6 * unitVec, Vector2.ZERO + 0.5 * unitVec.orthogonal(), 
		-0.5*unitVec.orthogonal()-6 * unitVec, Vector2.ZERO - 0.5 * unitVec.orthogonal(),
		-unitVec*4,  unitVec*6
	])
	
	angular_damp = 9
	linear_damp = 5
	set_angular_velocity(randf_range(-10, 10))
	apply_central_impulse(Vector2(randf_range(-30, 30),randf_range(-30, 30)))
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(2,7)
	var shape = CollisionShape2D.new()
	shape.shape = rect
	set_collision_layer_value(1,false)
	add_child(shape)
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot=true
	timer.wait_time=200
	timer.connect("timeout",_on_timer_timeout)
	timer.start()
	
	queue_redraw()
	
func _on_timer_timeout():
	queue_free()
