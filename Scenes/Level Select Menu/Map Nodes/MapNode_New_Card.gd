@tool
extends MapNode

@export var cards: Array[PackedScene]

func _draw() -> void:
	
	if cards.size() > 0 && Engine.is_editor_hint():
		var card: Card = cards[0].instantiate() as Card
		self.name = "Cards - " + card.card_name
		if cards.size() > 1:
			self.name += " (+" + str(cards.size() - 1) + " others)"
		card.queue_free()
		#TODO make the grapic reflect the card(s) on offer. Perhaps this should come with a toggle? maybe just show the card type? Rarity?
	
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(get_global_mouse_position(),"Card is locked",Color.RED,1)
		return
	
	if is_explored:
		GameManager.spawn_popup(get_global_mouse_position(),"Card already claimed",Color.RED,)
		return
	
	level_select.open_card_unlock_panel(cards)
	
	#add all the cards to the unlocked selection
	GameManager.current_save.unlocked_cards.append_array(cards)
	
	is_explored = true
	GameManager.save_game()
