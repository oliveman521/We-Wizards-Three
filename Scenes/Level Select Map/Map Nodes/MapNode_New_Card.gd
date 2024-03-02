@tool
extends MapNode

@export var cards: Array[PackedScene]

func _draw() -> void:
	#TODO make the grapic reflect the card on offer. Perhaps this should come with a toggle? maybe just show the card type? Rarity?
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
	GameManager.current_save.unlocked_cards.append_array(cards)
	
	is_explored = true