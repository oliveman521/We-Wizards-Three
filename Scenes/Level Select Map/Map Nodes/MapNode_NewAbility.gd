@tool
extends MapNode

@export var ability_name: String = "Insert Name"
@export var ability_image: Texture
@export_multiline var ability_description: String = "Insert Description"
var color: Color = Color("00482bb4")
 
func _draw() -> void:
	self.name = ability_name
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(global_position,"Ability is locked",Color.RED,)
		return
	
	level_select.open_misc_info_panel("New Ability!",ability_name, ability_image, ability_description, "Cool!", color)
	
	if is_explored:
		GameManager.spawn_popup(global_position,"Ability already claimed",Color.RED,)
	else:
		GameManager.current_save.misc_unlocks.append(ability_name)
		is_explored = true
	
