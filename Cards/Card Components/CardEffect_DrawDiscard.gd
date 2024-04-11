extends CardEffect
class_name CardEffect_DrawDiscard

@export var count: int = 1

@export_enum("Draw", "Discard") var effect_type: String = "Draw"

func use_effect() -> void:
	if effect_type == "Draw":
		for i in range(count):
			card_manager.draw_random_card()
	
	elif effect_type == "Discard":
		
		var cards_to_discard: Array[Card] = card_manager.cards_in_hand
		for i in range(min(cards_to_discard.size(),count)):
			var card: Card = card_manager.cards_in_hand.pop_front() as Card
			if card:
				card.discard()
			else: 
				print("this should never happen! Tried to discard card that doesnt exist")
				return
		x_callback.emit(cards_to_discard.size() - 1)
