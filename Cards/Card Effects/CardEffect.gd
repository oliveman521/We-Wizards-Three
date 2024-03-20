extends Node
class_name CardEffect

var card_manager: CardManager:
	get: return GameManager.card_manager as CardManager
		
var enemy_manager: EnemyManager:
	get:
		return GameManager.enemy_manager as EnemyManager

var storeroom_manager: StoreroomManager:
	get:
		return GameManager.storeroom_Manager as StoreroomManager

signal x_callback(count: int)

func card_effect() -> void:
	pass

