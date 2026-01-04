extends Node

var ARROWIMG = Image.load_from_file("res://Cursor/aimCursor.png")
var MOUSEIMG = Image.load_from_file("res://Cursor/mouseCursor.png")
var image = MOUSEIMG
var textLock = false
@onready var window : Window = get_window()
var sizePrev

var player_max
var dashBoots
var liftGloves

func _ready():
	Global.setMouse()
	player_max = 10
	dashBoots = false
	liftGloves = false
	
func _process(delta):
	#detect if window size changes
	if (window.size!= sizePrev):
		Global.setMouse()
		sizePrev = window.size

#responsible for both scale (upon window resize) and image change
func setMouse():
	var scalable = image.duplicate()
	var currentTransform = get_viewport().get_screen_transform().x[0]
	scalable.resize(32*currentTransform, 32*currentTransform, 0)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(scalable), Input.CURSOR_ARROW, Vector2(32*currentTransform,32*currentTransform) / 2)
