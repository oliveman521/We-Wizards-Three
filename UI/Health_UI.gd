extends Control

var life_object := preload("res://UI/heart_UI.tscn")

func _process(_delta: float) -> void:
	if get_children().size() > GameManager.lives and get_children().size() > 0:
		get_children()[0].queue_free()
	if get_children().size() < GameManager.lives:
		var new_life_object: Node = life_object.instantiate()
		add_child(new_life_object)

