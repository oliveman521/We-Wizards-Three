extends Resource
class_name GameSave


@export var unlocked_cards: Array[PackedScene] = []
var cards_in_deck: Array[PackedScene] = []

var completed_levels: Array[PackedScene]
var explored_map_nodes: Array[String]
