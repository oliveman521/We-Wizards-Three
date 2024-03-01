@tool
extends MapNode

@export var level: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
		is_explored = true #TODO idk why this isn't working. It shouldn't be her anyway, but still its concerning
		GameManager.start_level(level) #TODO this should instead pull up the level info menu and then let the user hit play on that
