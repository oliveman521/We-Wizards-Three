@tool
extends HBoxContainer

@export var supply: Supply
@export var always_on: bool = false
@onready var label: Label = %Count
@onready var icon: TextureRect = $Icon


func _ready() -> void:
	update()
	if not Engine.is_editor_hint():
		supply.supply_count_changed.connect(update)

func _draw() -> void:
	update()

	
func update(diff: int = 0) -> void:
	if not Engine.is_editor_hint():
		var cur_level: LevelData = GameManager.in_progress_level
		if supply.supply_count > 0 or cur_level.supplies_present.has(supply) or always_on:
			visible = true
		else:
			if !get_tree().current_scene.is_node_ready():
				visible = false #only turn it off at the beginning of the game. Once it's on it stays on
	
	
	var centerPoint: Vector2 = get_global_rect().get_center()
	if diff > 0:
		GameManager.spawn_popup(centerPoint, "+"+str(diff), Color.LIGHT_GREEN)
	elif diff < 0:
		GameManager.spawn_popup(centerPoint, "-"+str(abs(diff)), Color.CRIMSON)
	label.text = str(supply.supply_count)
	icon.texture = supply.icon
