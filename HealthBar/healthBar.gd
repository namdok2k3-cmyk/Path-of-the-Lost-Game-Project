extends Control

var imgs = []
var sprites
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprites = load("res://HealthBar/hearts.png")

# DamageTaken signal from player, connected via main script
func updateHealth(max, current):
	# could just alter existing objects in future, easier to just delete and reinstantiate rn
	for i in imgs:
		i.queue_free()
		
	imgs = []
	var hearts = max/2
	#Texture2D
	var txr
	#AtlasTexture
	var atl
	#column of spritesheet
	var col
	for i in range(0,hearts):
		#First and last heart have different texture cause of overlaps
		if i == 0: col=0
		elif i==hearts-1: col=1
		else: col=2
		
		txr = TextureRect.new()
		atl = AtlasTexture.new()
		atl.atlas= sprites
		
		#Determine texture depending on value of current heart and next heart
		if current-i*2 <=0:
			atl.region = Rect2(16*col,48,16,16)
		elif current-i*2 == 1:
			atl.region = Rect2(16*col,32,16,16)
		elif current-i*2 >=2 and current-i*2 <4:
			atl.region = Rect2(16*col,0,16,16)
		else:
			atl.region = Rect2(16*col,16,16,16)
			
		txr.texture = atl
		imgs.append(txr)
		txr.size = Vector2(16,16)
		txr.position.x = i*13
		#first heart is 2 pixels wider
		if i!=0:
			txr.position.x+=2
			
		add_child(txr)
		
