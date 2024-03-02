extends Resource
class_name Supply

@export var supply_name: String = "Default"
@export var icon: Texture2D

@export var starting_count: int = 10
@export var color: Color = Color(1,1,1)
@export var pickup_spawn_rate: float = 1
@export var pickup_count_min: int = 1
@export var pickup_count_max: int = 1


signal supply_count_changed(diff:int)
@export var supply_count: int = 0:
	set(new_val):
		var diff: int = new_val - supply_count
		supply_count = new_val
		supply_count_changed.emit(diff)
	

func use_supply(amnt: int = 1) -> bool:
	if supply_count - amnt >= 0:
		supply_count -= amnt
		return true
	else:
		print("Out of ammo!")
		return false

func add_supply(amnt: int = 1) -> void:
	supply_count += amnt

func on_pickup(amnt: int = 1) -> void:
	add_supply(amnt)
