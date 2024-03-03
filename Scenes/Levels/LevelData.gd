@tool
extends Node2D
class_name LevelData


@export var level_name: String = "filler_name":
	set(new_val):
		level_name = new_val
		name = level_name
@export var supplies_present: Array[Supply] #unused. This will represent the supplies that will spawn in this level
@export var supplies_spawned_at_once: int = 12

var enemy_feed_tape: Node2D: 
	get: return %"Enemy Feed Tape"
var storeroom_tile_map: Node2D:
	get: return %"Storeroom Tile Map"

var enemies_present: Array[Enemy]:
	get:
		var ep: Array[Enemy] = []
		for node: Node in enemy_feed_tape.get_children():
			if node is Enemy:
				var novel_enemy : bool = true
				for en: Enemy in ep:
					if en.enemy_name == node.enemy_name:
						novel_enemy = false
						break
				if novel_enemy:
					ep.append(node as Enemy)
		return ep
