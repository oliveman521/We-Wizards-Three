extends Control
class_name CardUnlockPanel

@onready var confirm_button: Button = %"Confirm Button"
@onready var back_button: Button = %"Back Button"
@onready var card_container: HBoxContainer = %"Card Container"

@onready var level_select_menu: LevelSelectMenu = get_tree().get_first_node_in_group("Level Select Menu")


func populate(card_prefabs: Array[PackedScene]) -> void:

	for c: Node in card_container.get_children():
		c.queue_free()
	
	for card_prefab: PackedScene in card_prefabs:
		var card: Card = card_prefab.instantiate() as Card
		card_container.add_child(card)
		card.enter_preview_mode()
	
	confirm_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)
	
	back_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)


