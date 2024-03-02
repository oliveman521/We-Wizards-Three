@tool
extends MapNode

@export var level: PackedScene

func _ready() -> void:
	super._ready()
	if GameManager.current_save.completed_levels.has(level):
		is_explored = true

func _draw() -> void:
	if level:
		var level_data: LevelData = level.instantiate() as LevelData
		self.name = level_data.level_name
		level_data.queue_free()
	
	button.text = self.name
	super._draw()


func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(global_position,"Level is locked",Color.RED,)
		return
	if level:
		level_select.open_level_info_panel(level)