extends Node2D


const popup_prefab:= preload("uid://14rg16g7dhgq")

func spawn_popup():
	var new_popup_text: Node2D = popup_prefab.instantiate()
	new_popup_text
