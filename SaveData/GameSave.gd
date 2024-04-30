extends Resource
class_name GameSave

@export var misc_unlocks: Array[String]
@export var unlocked_cards: Array[PackedScene] = []

@export var cards_in_deck: Array[PackedScene] = []

@export var completed_levels: Array[PackedScene]
@export var explored_map_nodes: Array[String]



func check_unlock(unlock_name: String) -> int:
	var count: = 0
	for unlock: String in misc_unlocks:
		if unlock.begins_with(unlock_name):
			count += 1
	return count
