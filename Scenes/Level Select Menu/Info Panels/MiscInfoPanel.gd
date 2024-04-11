extends MarginContainer
class_name  MiscInfoPanel


@onready var title_label: Label = %"Title Label"
@onready var text_1_label: Label = %"Text 1 Label"
@onready var image_rect: TextureRect = %"Image Rect"
@onready var text_2_label: Label = %"Text 2 Label"
@onready var confirm_button: Button = %"Confirm Button"
@onready var confirm_button_label: Label = %"Confirm Button Label"
@onready var back_button: Button = %"Back Button"

@onready var background: Control = %Background

@onready var level_select_menu: LevelSelectMenu = get_tree().get_first_node_in_group("Level Select Menu")

func populate(title: String, text1: String, image: Texture, text2: String, button_text: String) -> void:
	title_label.text = title
	if text1:
		text_1_label.text = text1
	else:
		text_1_label.visible = false
	
	if image:
		image_rect.texture = image
	else:
		image_rect.visible = false
	
	if text2:
		text_2_label.text = text2
	else:
		text_2_label.visible = false
	
	confirm_button_label.text = button_text
	
	
	confirm_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)
	
	back_button.button_down.connect(func()-> void:
		level_select_menu.close_current_info_panel()
	)
