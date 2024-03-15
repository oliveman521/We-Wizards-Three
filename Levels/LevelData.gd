@tool
extends Node2D
class_name LevelData


@export var level_name: String:
	get:
		var file_name: String = scene_file_path.get_basename().split("/")[-1]
		name = file_name
		return file_name
@export var supplies_present: Array[Supply] #unused. This will represent the supplies that will spawn in this level
@export var supplies_spawned_at_once: int = 12

var enemy_feed_tape: Node2D: 
	get: return %"Enemy Feed Tape"
var storeroom_tile_map: Node2D:
	get: return %"Storeroom Tile Map"

var remaining_level_length_seconds: float:
	get:
		var last_en: Enemy = last_enemy as Enemy
		var time_to_activate: float = -last_en.global_position.x / 50
		var time_to_get_on_screen: float = time_to_activate + 100/last_en.move_speed
		return time_to_get_on_screen

var last_enemy: Enemy:
	get:
		var last_en: Enemy = all_enemies[0]
		for enemy: Enemy in all_enemies:
			if enemy.global_position.x < last_en.global_position.x:
				last_en = enemy
		return last_en

var all_enemies: Array[Enemy]:
	get:
		var enemies: Array[Enemy] = []
		for node: Node in enemy_feed_tape.get_children():
			if node is Enemy:
				enemies.append(node as Enemy)
		return enemies

var unique_enemies_present: Array[Enemy]:
	get:
		var unique_enemies: Array[Enemy] = []
		for enemy: Enemy in all_enemies:
			var unique_enemy : bool = true
			for en2: Enemy in unique_enemies:
				if en2.enemy_name == enemy.enemy_name:
					unique_enemy = false
					break
			if unique_enemy:
				unique_enemies.append(enemy)
		return unique_enemies
