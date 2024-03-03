@tool
extends MapNode

@export var cards: Array[PackedScene]

func _draw() -> void:
	if cards.size() > 0:
		var card: Card = cards[0].instantiate() as Card
		self.name = "Cards - " + card.card_name
		if cards.size() > 1:
			self.name += " (+" + str(cards.size() - 1) + " others)"
		card.queue_free()
		#TODO make the grapic reflect the card(s) on offer. Perhaps this should come with a toggle? maybe just show the card type? Rarity?
		
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(global_position,"Card is locked",Color.RED,)
		return
	
	if is_explored:
		GameManager.spawn_popup(global_position,"Card already claimed",Color.RED,)
		return
	
	level_select.open_card_unlock_panel(cards)
	
	#add all the cards to the unlocked selection
	print(GameManager.current_save.unlocked_cards)	
	GameManager.current_save.unlocked_cards.append_array(cards)
	print(GameManager.current_save.unlocked_cards)
	is_explored = true
