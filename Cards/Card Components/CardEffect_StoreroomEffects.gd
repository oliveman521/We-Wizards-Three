extends CardEffect
class_name CardEffect_StoreroomEffects


@export var spawn_in_storeroom: PackedScene
@export var count: int


func use_effect() -> void:
	if spawn_in_storeroom:
		for i in range(count):
			storeroom_manager.spawn_object(spawn_in_storeroom)
