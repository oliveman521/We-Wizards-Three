extends Control
class_name LevelInfoPanel


const ICON_UI_PREFAB = preload("uid://b6l8omowp6g0m")

@onready var title_label: Label = %"Title Label"
@onready var supply_icons_container: HBoxContainer = %"Supply Icons Container"
@onready var enemy_icons_container: HBoxContainer = %"Enemy Icons Container"
@onready var start_button: Button = %"Confirm Button"
@onready var back_button: Button = %"Back Button"

@onready var level_select_menu: LevelSelectMenu = get_tree().get_first_node_in_group("Level Select Menu")
@onready var deck_building_menu: DeckBuildingMenu = get_tree().get_first_node_in_group("Deck Building Menu")

var warned_about_unplayable_cards: Array[PackedScene] = []

func populate(level_prefab: PackedScene) -> void:
	var level_data: LevelData = level_prefab.instantiate() as LevelData
	GameManager.level_about_to_begin = level_data
	

	title_label.text = level_data.level_name
	
	for c: Node in supply_icons_container.get_children():
		c.queue_free()
	
	for supply: Supply in level_data.supplies_present:
		var icon_UI: Node = ICON_UI_PREFAB.instantiate() as TextureRect
		icon_UI.texture = supply.icon
		icon_UI.modulate = supply.color
		supply_icons_container.add_child(icon_UI)
	
	for c: Node in enemy_icons_container.get_children():
		c.queue_free()
	
	for enemy: Enemy in level_data.enemies_present:
		var icon_UI: Node = ICON_UI_PREFAB.instantiate() as TextureRect
		icon_UI.texture = enemy.icon
		enemy_icons_container.add_child(icon_UI)
	
	start_button.button_down.connect(func()-> void:
		if not deck_building_menu.is_open:
			deck_building_menu.open_deck_builder_menu()
			start_button.text = "Confirm Deck?"
			return
		var x: int =  GameManager.DECK_MAX_SIZE - GameManager.current_save.cards_in_deck.size()
		if x > 0:
			GameManager.spawn_popup(get_global_mouse_position(), "Deck needs " + str(x) + " more cards!", Color.FIREBRICK)
			return
		

		#Check if their deck has unplayable cards
		for card_prefab: PackedScene in GameManager.current_save.cards_in_deck:
			var card: Card = card_prefab.instantiate() as Card
			get_tree().current_scene.add_child(card)
			card.global_position = Vector2(-1000,-1000)
			if card.can_card_be_played_on_level(level_data):
				if warned_about_unplayable_cards != GameManager.current_save.cards_in_deck: #if they haven't changed their deck
					warned_about_unplayable_cards = GameManager.current_save.cards_in_deck
					GameManager.spawn_popup(get_global_mouse_position(), "Warning: Your deck has costs that do not spawn in this level", Color.ORANGE,6)
					start_button.text = "Play anyway?"
					return
			card.queue_free()
		
		
		
		GameManager.start_level(level_prefab)
	)
	
	back_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)

