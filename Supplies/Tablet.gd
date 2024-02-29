extends Supply
class_name Tablet

func on_pickup(amnt: int = 1) -> void:
	var card_man: CardManager = GameManager.card_manager as CardManager
	for i in range(amnt):
		card_man.draw_random_card()
		

