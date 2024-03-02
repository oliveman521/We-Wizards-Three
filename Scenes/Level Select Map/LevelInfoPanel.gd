extends Control
class_name LevelInfoPanel


const ICON_UI_PREFAB = preload("uid://b6l8omowp6g0m")

@onready var level_name_label: Label = %"Level Name Label"
@onready var supply_icons_container: HBoxContainer = %"Supply Icons Container"
@onready var enemy_icons_container: HBoxContainer = %"Enemy Icons Container"
@onready var start_button: Button = %"Start Button"
@onready var back_button: Button = %"Back Button"

@onready var level_select_menu: LevelSelectMenu = get_tree().get_first_node_in_group("Level Select Menu")
@onready var deck_building_menu: DeckBuildingMenu = get_tree().get_first_node_in_group("Deck Building Menu")

func populate(level_prefab: PackedScene) -> void:
	var level_data: LevelData = level_prefab.instantiate() as LevelData
	
	level_name_label.text = level_data.level_name
	
	for c: Node in supply_icons_container.get_children():
		c.queue_free()
	
	for supply: Supply in level_data.supplies_present:
		var icon_UI: Node = ICON_UI_PREFAB.instantiate() as TextureRect
		icon_UI.texture = supply.icon
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
		
		GameManager.start_level(level_prefab)
	)
	
	back_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)
	
	
	level_data.queue_free()

