extends Control


func load_level_select_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://bpfb1n271ove4"))

func load_deck_builder_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://bhm5xireormeb"))

func load_main_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://dpdlppetxwu3m"))
	

func quit() -> void:
	get_tree().quit()
