@tool
extends MapNode

@export var ability_name: String = "Insert Name"
@export var override_name: String = ""
@export var ability_image: Texture
@export_multiline var ability_description: String = "Insert Description"
var color: Color = Color("00482bb4")
 
func _draw() -> void:
	self.name = "Ability - " + ability_name
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(global_position,"Ability is locked",Color.RED,)
		return
	
	var display_name := ability_name
	if override_name:
		display_name = override_name
	
	var sub_header: String = " == " + display_name + " == "
	level_select.open_misc_info_panel("New Ability! - " + display_name,sub_header, ability_image, ability_description, "Cool!", color)
	
	if is_explored:
		GameManager.spawn_popup(global_position,"Ability already claimed",Color.RED,)
	else:
		GameManager.current_save.misc_unlocks.append(ability_name)
		is_explored = true
	
