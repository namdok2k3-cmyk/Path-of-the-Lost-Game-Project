extends CharacterBody2D

#variable determines if object should stick to mouse
var stuck = false

var grabOffset=0
var liftOffset=0
const LIFT_MAX=6
var lowering = false
var targetVel
var lastMousePos

@export var posShape:Array[CollisionShape2D]
@export var physicsShape:Array[CollisionShape2D]

func _ready():
	#Shadow is copy of main sprite altered by shader
	$Shadow.texture = $"Main sprite".texture
	
	#this can almost definitely be done better...
	for shape in posShape:
		shape.get_parent().remove_child(shape)
		add_child(shape)
	for shape in physicsShape:
		shape.get_parent().remove_child(shape)
		$PhysicsArea.add_child(shape)
		
func _physics_process(delta):
	
	#drop object
	if(Input.is_action_just_released("grab") and stuck):
		z_index=5
		stuck = false
		lowering=true
	
	#if object on mouse
	if stuck:
		#push object toward mouse
		velocity=(get_global_mouse_position()-grabOffset-global_position)
		velocity = (velocity.length()/4)*velocity
		
		#limit velocity
		if velocity.length()>3000:
			velocity = 3000*velocity/velocity.length()
		
		move_and_slide()
		
		#raise object when grabbed
		if liftOffset<LIFT_MAX:
			liftOffset+=1
			$"Main sprite".position.y=-liftOffset
			$PhysicsArea.position.y=-liftOffset
			
	#putting object down
	elif lowering:
		if liftOffset>0:
			liftOffset-=3
			$"Main sprite".position.y=-liftOffset
			$PhysicsArea.position.y=-liftOffset
			
		elif liftOffset<=0:
			$Shadow.visible = false
			liftOffset=0

#grab object
func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("grab"):
		z_index=6
		if !stuck:
			stuck = true
			#keep consistent position relative to mouse. otherrwise it would snap to mouse (bad)
			grabOffset = get_local_mouse_position()
			$Shadow.visible = true
			
func _on_physics_area_child_entered_tree(node: Node) -> void:
	pass#add_child(node)
