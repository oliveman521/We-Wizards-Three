extends Control

@onready var unlocked_cards_container: Control = %"Card Pool Container"
@onready var cards_in_deck_container: HFlowContainer = %"Deck Contents Container"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrange_UI()

func arrange_UI() -> void:
	
	#wipe out cards already there
	for node: Node in unlocked_cards_container.get_children():
		if node is Card:
			node.queue_free()
	for node: Node in cards_in_deck_container.get_children():
		if node is Card:
			node.queue_free()
	
	var all_unlocked_cards: Dictionary = card_prefabs_to_duplicate_dict(GameManager.current_save.unlocked_cards)
	var cards_in_deck: Dictionary = card_prefabs_to_duplicate_dict(GameManager.current_save.cards_in_deck)
	
	#Fill up deck by default if it's empty
	
	var unlocked_cards_not_in_deck: Dictionary = all_unlocked_cards
	for card_prefab: PackedScene in cards_in_deck.keys():
		if unlocked_cards_not_in_deck.keys().has(card_prefab):
			var num_in_deck: int = cards_in_deck[card_prefab]
			if unlocked_cards_not_in_deck[card_prefab] > num_in_deck:
				unlocked_cards_not_in_deck[card_prefab] -= num_in_deck
			else:
				unlocked_cards_not_in_deck.erase(card_prefab)
	
	for card_prefab: PackedScene in unlocked_cards_not_in_deck.keys():
		var card: Card = card_prefab.instantiate() as Card
		unlocked_cards_container.add_child(card)
		card.enter_deck_building_mode(unlocked_cards_not_in_deck[card_prefab], false)
		card.card_pressed.connect(func()->void:
			#add the card to the deck
			if GameManager.current_save.cards_in_deck.size() >= GameManager.DECK_MAX_SIZE:
				GameManager.spawn_popup(get_global_mouse_position(), "Deck is full!", Color.FIREBRICK)
				arrange_UI()
				return
			GameManager.current_save.cards_in_deck.append(card_prefab)
			arrange_UI()
			)
	#TODO figure out how to get these to not move around on you while you're deck building
	for card_prefab: PackedScene in cards_in_deck.keys():
		var card: Card = card_prefab.instantiate() as Card
		cards_in_deck_container.add_child(card)
		card.enter_deck_building_mode(cards_in_deck[card_prefab], true)
		card.card_pressed.connect(func()->void:
			GameManager.current_save.cards_in_deck.erase(card_prefab)
			arrange_UI()
			)
func card_prefabs_to_duplicate_dict(card_prefabs: Array[PackedScene]) -> Dictionary:
	var card_dict: Dictionary = {}
	for card_prefab: PackedScene in card_prefabs:
		if not card_dict.keys().has(card_prefab):
			card_dict[card_prefab] = 1
		else:
			card_dict[card_prefab] += 1
	return card_dict

func confirm_deck() -> void:
	var x: int =  GameManager.DECK_MAX_SIZE - GameManager.current_save.cards_in_deck.size()
	if x > 0:
		GameManager.spawn_popup(get_global_mouse_position(), "Deck needs " + str(x) + " more cards!", Color.FIREBRICK)
		return
	GameManager.deck_confirmed.emit()
