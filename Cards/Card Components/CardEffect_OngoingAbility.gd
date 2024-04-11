extends CardEffect
class_name CardEffect_OngoingAbility

@export var ongoing_ability_prefab: PackedScene
@export var amnt: float = 1


func use_effect() -> void:
	card_manager.add_ongoing_ability(ongoing_ability_prefab, amnt)
