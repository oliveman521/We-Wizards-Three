extends Control


const LEVEL_BUTTON = preload("uid://ckiehv40levdx")
@onready var level_button_contatiner: Container = %"LevelsVBox"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level: LevelData in GameManager.levels:
		add_level_button(level)

func add_level_button(level: LevelData) -> void:
	var new_button: Button = LEVEL_BUTTON.instantiate() as Button
	level_button_contatiner.add_child(new_button)
	new_button.text = level.level_name
	new_button.button_down.connect(func() -> void:
		GameManager.start_level(level)
	)
