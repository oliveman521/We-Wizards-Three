@tool
extends MapNode

@export var pages: Array[TutorialInfoPage]
 

func _draw() -> void:
	if pages.size() > 0:
		self.name = "info - " + pages[0].title
		if pages.size() > 1:
			self.name += " (" + str(pages.size()) +" pages)"
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(get_global_mouse_position(),"Info is locked",Color.RED,)
		return
	
	await level_select.open_tutorial_panel(pages)
	
	is_explored = true
