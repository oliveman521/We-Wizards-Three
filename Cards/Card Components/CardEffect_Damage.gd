extends CardEffect
class_name CardEffect_Damage

@export var dmg_type: GameManager.Damage_Type 
@export var amnt: int

@export_enum("All", "First", "MostHP", "Random") var targets: String = "All"
@export var target_count:int = 1

func damage_x_targets(x: int):
	target_count = x
	use_effect()

func deal_x_damage(x: int):
	amnt = x
	use_effect()

func use_effect() -> void:
	#TODO impliment the other kinds of damage
	if targets == "All":
		for enemy: Enemy in enemy_manager.active_enemies:
			enemy.take_damage(dmg_type, amnt)
	elif targets == "First":
		var enemies: Array[Enemy] = enemy_manager.active_enemies.duplicate()
		enemies.sort_custom(func(a: Node2D,b: Node2D) -> bool: 
			if a.global_position.x > b.global_position.x: 
				return true
			else:
				return false
			)
		for i in range(target_count):
			if enemies.size() <= i: break #if there aren't enough enemies for indexing, break
			enemies[i].take_damage(dmg_type, amnt)
	elif targets == "Random":
		for i in range(target_count):
			if enemy_manager.active_enemies.size() == 0: 
				print("No enemies to target")
				break
			enemy_manager.active_enemies.pick_random().take_damage(dmg_type, amnt)
			await get_tree().create_timer(0.1).timeout
	else:
		print("Something Went Wrong in damage effect")
