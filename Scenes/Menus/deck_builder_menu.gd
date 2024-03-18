extends Control
class_name DeckBuildingMenu

@onready var unlocked_cards_container: Control = %"Card Pool Container"
@onready var cards_in_deck_container: HFlowContainer = %"Deck Contents Container"

@onready var deck_label: Label = %"Deck Label"
const card_multiples_indicator_prefab = preload("uid://dm5dny7e4dwb3")


const PANEL_MOVE_TIME: float = 0.2

#TODO should grow and shrink depending on if the info panel is in use

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrange_UI()

func _draw() -> void:
	arrange_UI()


func arrange_UI() -> void:
	#wipe out cards already there
	for node: Node in unlocked_cards_container.get_children():
		if node is Card:
			node.queue_free()
	for node: Node in cards_in_deck_container.get_children():
		if node is Card:
			node.queue_free()
	await get_tree().process_frame #this helps make sure there is no flicker while the old cards are clearing
	
	var all_unlocked_cards: Dictionary = card_prefabs_to_duplicate_dict(GameManager.current_save.unlocked_cards)
	var cards_in_deck: Dictionary = card_prefabs_to_duplicate_dict(GameManager.current_save.cards_in_deck)
	
	#build list of only the cards that unlocked but not in the deck
	var unlocked_cards_not_in_deck: Dictionary = all_unlocked_cards
	for card_prefab: PackedScene in cards_in_deck.keys():
		if unlocked_cards_not_in_deck.keys().has(card_prefab):
			var num_in_deck: int = cards_in_deck[card_prefab]
			if unlocked_cards_not_in_deck[card_prefab] > num_in_deck:
				unlocked_cards_not_in_deck[card_prefab] -= num_in_deck
			else:
				unlocked_cards_not_in_deck.erase(card_prefab)
	
	
	#spawning in the unlocked cards
	for card_prefab: PackedScene in unlocked_cards_not_in_deck.keys():
		var count: int = unlocked_cards_not_in_deck[card_prefab]
		var card: Card = card_prefab.instantiate() as Card
		unlocked_cards_container.add_child(card)
		card.enter_deck_building_mode(count)
		card.card_pressed.connect(func()->void:
			var deck_is_full: bool = GameManager.current_save.cards_in_deck.size() >= GameManager.DECK_MAX_SIZE
			if deck_is_full:
				GameManager.spawn_popup(get_global_mouse_position(), "Deck is full!", Color.FIREBRICK, 1.5, get_parent())
				#TODO this shows up in the wrong place. Needs to somehow interact with the canvas
				SoundManager.play_sound(card.cannot_be_played_sound)
				return
			
			#add the card to the deck
			GameManager.current_save.cards_in_deck.append(card_prefab)
			SoundManager.play_sound(card.discard_sound, 0.2)
			#TODO make cards stack and move smoothly between positions
			#await card.slide_card_away(Vector2.RIGHT, Color(0,0,1,0), 0.1)
			arrange_UI()
			)
	
	for card_prefab: PackedScene in cards_in_deck.keys():
		var card: Card = card_prefab.instantiate() as Card
		var count: int = cards_in_deck[card_prefab]
		cards_in_deck_container.add_child(card)
		card.enter_deck_building_mode(count)
		card.card_pressed.connect(func()->void:
			GameManager.current_save.cards_in_deck.erase(card_prefab)
			SoundManager.play_sound(card.discard_sound, 0.2)
			#await card.slide_card_away(Vector2.LEFT, Color(0,0,1,0), 0.1)
			arrange_UI()
			)
	
	#Update header to include deck size
	deck_label.text = "Deck (" + str(GameManager.current_save.cards_in_deck.size()) + "/" + str(GameManager.DECK_MAX_SIZE) + ")"

func card_prefabs_to_duplicate_dict(card_prefabs: Array[PackedScene]) -> Dictionary:
	#start by sorting the card alphabetically
	card_prefabs.sort_custom(func(a: PackedScene,b: PackedScene) -> bool: 
		if a.resource_path < b.resource_path: 
			return true
		else:
			return false
		)
	
	var card_dict: Dictionary = {}
	for card_prefab: PackedScene in card_prefabs:
		if not card_dict.keys().has(card_prefab):
			card_dict[card_prefab] = 1
		else:
			card_dict[card_prefab] += 1
	return card_dict

var is_open: bool = false

func open_deck_builder_menu() -> void:
	if is_open:
		return
	
	is_open = true
	arrange_UI()
	var destination: Vector2 = Vector2(0,self.global_position.y)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", destination, PANEL_MOVE_TIME)
	await tween.finished

func close_deck_builder_menu() -> void:
	if not is_open:
		return
		
	is_open = false
	arrange_UI()
	var destination: Vector2 = Vector2(-self.get_global_rect().size.x,self.global_position.y)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", destination, PANEL_MOVE_TIME)
	await tween.finished
