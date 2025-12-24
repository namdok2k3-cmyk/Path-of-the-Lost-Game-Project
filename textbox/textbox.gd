extends Control
enum {PLAY, STOP, PAUSE}
var state = STOP
var writeSpeed = 0
var writeIndex = 0
var writeCtUp = 0
#TODO: incorporate in-text modifiers to dynamically change speed, color?, paragraphs during write also add "press space to continue" to textbox
func _physics_process(delta):
	if (state == PLAY):
		writeCtUp += 1
		if (writeCtUp >= writeSpeed):
			writeCtUp = 0
			writeIndex += 1

			$RichTextLabel.visible_characters = writeIndex
			#All text is written
			if (writeIndex >= $RichTextLabel.text.length()):
				state = STOP
			#Writing reaches bottom of box
			elif ($RichTextLabel.get_character_line(writeIndex) == 3):
				state = PAUSE
	
func _input(event: InputEvent) -> void:
	#Await player input to continue text
	if (state == PAUSE):
		if(Input.is_action_just_released("interact")):
			$RichTextLabel.text=$RichTextLabel.text.erase(0,writeIndex)
			writeIndex=0
			$RichTextLabel.visible_characters = 0 
			state = PLAY
	#Await player input to close text box
	elif (state == STOP && Global.textLock):
		if(Input.is_action_just_released("interact")):
			get_viewport().set_input_as_handled()
			visible = false
			Global.textLock = false
			
#speed is in 60ths of a second. pos is world pos.
func start_text_write(text, speed, pos):
	#anything adhering to textLock shouldn't move while textbox is open. see player physics process
	Global.textLock = true
	visible = true
	position = pos
	$RichTextLabel.text = text
	writeIndex = 0
	writeSpeed = speed
	state = PLAY
