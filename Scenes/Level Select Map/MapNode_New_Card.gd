@tool
extends MapNode

@export var card: PackedScene

func _draw() -> void:
	#TODO make the grapic reflect the card on offer. Perhaps this should come with a toggle? maybe just show the card type? Rarity?
	super._draw()

func _on_button_down() -> void:
	if locked:
		GameManager.spawn_popup(global_position,"Card is locked",Color.RED,)
		return
	
	is_explored = true
