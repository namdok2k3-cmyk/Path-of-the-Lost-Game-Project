extends Node2D

var onlyLevel2Done
var onlyLevel3Done
var bothLevelsDone
var noLevelsDone
var firstEntrance

func _ready():	
	get_window().content_scale_size = Vector2i(480, 270)
	onlyLevel2Done = !HubMechanics.pink_waystone && HubMechanics.green_waystone
	onlyLevel3Done = HubMechanics.pink_waystone && !HubMechanics.green_waystone
	bothLevelsDone = HubMechanics.pink_waystone && HubMechanics.green_waystone
	noLevelsDone = !HubMechanics.pink_waystone && !HubMechanics.green_waystone
	firstEntrance = noLevelsDone && !HubMechanics.unlockedLevels
	
	$Player/AnimatedSprite2D.animation = "Up"
	$Player/AnimatedSprite2D.frame = 0	
	
	get_viewport().set_snap_2d_transforms_to_pixel(true)
	
	$NPC.get_node("Spark").connect("interacted", npcInteracted)
	
	if HubMechanics.unlockedLevels:
		$Gates/level_gates.queue_free()
		
		
	if onlyLevel2Done || onlyLevel3Done && !bothLevelsDone:
		if onlyLevel2Done:
			$waystones/lit_green.visible = true
		if onlyLevel3Done:
			$waystones/lit_pink.visible = true
		$Player.position = Vector2(392, 86)
		$TextBox.start_text_write("The waystone lit up; one down one to go!", 1, Vector2(146,-2))
	
	if HubMechanics.fromLevel2:
		$Player.position = Vector2(21, 285)
		HubMechanics.fromLevel2 = !HubMechanics.fromLevel2
		$Player/AnimatedSprite2D.animation = "Right"
		$Player/AnimatedSprite2D.frame = 0
		
	if HubMechanics.fromLevel3:
		$Player.position = Vector2(773,285)
		HubMechanics.fromLevel3 = !HubMechanics.fromLevel3
		$Player/AnimatedSprite2D.animation = "Left"
		$Player/AnimatedSprite2D.frame = 0
		
	if bothLevelsDone:
			$Player.position = Vector2(392, 86)
			$TextBox.start_text_write("I did it! Both waystones are lit and the gate is open.", 1, Vector2(146,-2))
			
			$Gates/level_four/locked_door.queue_free()
			$waystones/lit_green.visible = true
			$waystones/lit_pink.visible = true
		
	if Global.dashBoots:
		$AbilityObjects/Boots.queue_free()
	if Global.liftGloves:
		$AbilityObjects/Gloves.queue_free()
			
	if firstEntrance:
		$TextBox.start_text_write("I wonder if my gear is around here anywhere...", 1, Vector2(384, 337))
	

func _process(delta: float) -> void:
	pass

func _on_bridge_level_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Global.dashBoots:
			get_tree().change_scene_to_file("res://levels/level_two.tscn")
		else:
			$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(1, 1, 1))
			$TextBox.start_text_write("NPC said I would need my boots for this area. I should grab them first.", 1, Vector2(-22, 194))

func _on_maze_level_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Global.liftGloves:
			get_tree().change_scene_to_file("res://levels/level_three.tscn")
		else:
			$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(1, 1, 1))
			$TextBox.start_text_write("NPC said I would need my gloves for this area. I should grab them first.", 1, Vector2(563, 188))


func npcInteracted():
	if bothLevelsDone:
		HubMechanics.finalNpcDialog = true
		$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(74/255.0, 237/255.0, 123/255.0, 255))
		$TextBox.start_text_write("Well done! You have freed us both and earned your items back. Where are you off to next?\n To find your friend who lives deep in the forest? Why, I think I know that fellow! You had better hurry to find him; he looked quite ill last our paths crossed.\n\n Where can you find him? Hmm... you will have to go through the crypt you just unlocked and out down the river... After that I am afraid I don't know.\n\n Best of luck on your quest, my friend!", 1, Vector2(392, 81))
	else:
		#Change text color to indicate NPC speaking
		$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(74/255.0, 237/255.0, 123/255.0, 255))
		$TextBox.start_text_write("Hello there! My name is Norman Perseus Cartwell, but you can call me NPC!\n...have I seen some stolen items? Well yes, I wrangled a couple goodies from some fiends just this morning.\nOh, they're yours, are they? Well you can have them back on one condition. Use them to reach the keystones to the east and west of here to get this door open for me. If you succeed you can keep them; I'll have no more use for them anyway.\n Be warned, you'll need the boots for the area at the end of the green path and you'll need your gloves for the area at the end of the brown path.", 1, Vector2(392, 81))
		
		if !HubMechanics.unlockedLevels:
			$Gates/level_gates.queue_free()
			HubMechanics.unlockedLevels = true

func _on_boots_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#check to see if player has either already done lvl 3 or doesn't have the gloves on
		if onlyLevel3Done || !Global.liftGloves:
			$Player.dashBoots = true
			Global.dashBoots = true

			$AbilityObjects/Boots.queue_free()
			$Exits/bridge_level/StaticBody2D.queue_free()
		else:
			$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(1, 1, 1))
			$TextBox.start_text_write("I think I'd better try these gloves out first.", 1, Vector2(27, -14))


func _on_gloves_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#check to see if player has either already done lvl 2 or doesn't have the boots on
		if onlyLevel2Done || !Global.dashBoots:
			$Player.liftGloves = true
			Global.liftGloves = true
			
			$AbilityObjects/Gloves.queue_free()
			$Exits/maze_level/StaticBody2D.queue_free()
		else:
			$TextBox/RichTextLabel.add_theme_color_override("default_color", Color(1, 1, 1))
			$TextBox.start_text_write("I think I'd better try these boots out first.", 1, Vector2(502, -14))


func _on_level_four_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if bothLevelsDone:
			if !HubMechanics.finalNpcDialog:
				$TextBox.start_text_write("I should probably say goodbye to NPC first.", 1, Vector2(384, -32))
			else:
				get_tree().change_scene_to_file("res://levels/level_four.tscn")
