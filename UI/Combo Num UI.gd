extends Label

func _process(_delta: float) -> void:
	text = str(GameManager.apprentice_character.combo)
