extends Node2D
class_name LevelData

@export var level_name: String = "filler_name"

var supplies_present: Array[Supply] #unused. This will represent the supplies that will spawn in this level
var enemy_feed_tape: Node2D: 
	get: return %"Enemy Feed Tape"
var storeroom_tile_map: Node2D:
	get: return %"Storeroom Tile Map"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

