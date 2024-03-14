extends CardEffect
class_name CardEffect_SpawnEnemies

@export var enemy_prefab: PackedScene 
@export var count: int = 1


func use_effect() -> void:
	for i in range(count):
		enemy_manager.spawn_enemy(enemy_prefab)
