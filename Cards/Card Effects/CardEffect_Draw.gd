extends CardEffect
class_name CardEffect_Draw

@export var count: int = 1

func use_effect() -> void:
	for i in range(count):
		card_manager.draw_random_card()
	
