@tool
extends Control
class_name CardSupplyIcon

@export var supply: Supply:
	set(new_val):
		supply = new_val
		queue_redraw()

@export var count: int = 1:
	set(new_val):
		count = new_val
		queue_redraw()

@export var visual_only: bool = false

func _draw() -> void:
	lay_out()

func lay_out() -> void:
	var multiples_indicator: Control = %"Multiples Indicator" as Control
	var number_label: Label = %Number as Label
	var icon_rect: TextureRect = %Icon as TextureRect

	number_label.text = str(count)
	multiples_indicator.visible = (count != 1 and count != 0)
	icon_rect.texture = supply.icon
	
	name = supply.supply_name + " x" + str(count)

func check_cost() -> bool:
	if visual_only: return true
	return supply.supply_count >= count

func spend_cost() -> void:
	if visual_only: return
	supply.use_supply(count)

func use_effect() -> void:
	if visual_only: return
	supply.add_supply(count)
