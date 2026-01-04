extends Node

var pink_waystone
var green_waystone

var level2HeartGrabbed
var level3HeartGrabbed

var fromLevel2
var fromLevel3

var unlockedLevels
var finalNpcDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pink_waystone = false
	green_waystone = false
	
	level2HeartGrabbed = false
	level3HeartGrabbed = false
	
	fromLevel2 = false
	fromLevel3 = false
	
	unlockedLevels = false
	finalNpcDialog = false
