extends Button




var confirmation_asked: bool = false

func _on_button_down() -> void:
	if not confirmation_asked:
		confirmation_asked = true
		text = "r u sure?"
	else:
		GameManager.setup_new_save()
		text = "Reset Save"
