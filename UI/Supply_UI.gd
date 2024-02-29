@tool
extends HBoxContainer

@export var supply: Supply
@onready var label: Label = $Count
@onready var icon: TextureRect = $Icon

func _ready() -> void:
	update()
	if not Engine.is_editor_hint():
		supply.supply_count_changed.connect(update)

func _draw() -> void:
	update()

func update(diff: int = 0) -> void:
	var centerPoint: Vector2 = get_global_rect().get_center()
	if diff > 0:
		GameManager.spawn_popup(centerPoint, "+"+str(diff), Color.LIGHT_GREEN)
	elif diff < 0:
		GameManager.spawn_popup(centerPoint, "-"+str(abs(diff)), Color.CRIMSON)
	icon.modulate = supply.color
	label.text = str(supply.supply_count)
	icon.texture = supply.icon
