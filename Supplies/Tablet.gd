extends Supply
class_name Tablet

func on_pickup(amnt: int = 1) -> void:
	for i in range(amnt):
		CardManager.instance.draw_random_card()
		

