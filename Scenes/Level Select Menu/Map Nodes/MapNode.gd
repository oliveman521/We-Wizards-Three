@tool
extends Control
class_name MapNode

#memes :)
@export var connected_map_nodes: Array[MapNode]:
	set(new_connections):
		var old_connections := connected_map_nodes.duplicate()
		connected_map_nodes = new_connections
		
		#verifying that all connections make sense. 
		for neighbor: MapNode in old_connections: #remove any removed connections
			if neighbor == null: continue
			if not connected_map_nodes.has(neighbor):
				neighbor.connected_map_nodes.erase(self)
		
		for neighbor: MapNode in connected_map_nodes: #connect any new ones at the other side
			if neighbor == null: continue
			if not neighbor.connected_map_nodes.has(self):
				neighbor.connected_map_nodes.append(self)
		
		if map_manager:
			map_manager.redraw_all_map_nodes()

@export var always_unlocked: bool = false

@onready var map_manager: MapManager = $".."
@onready var level_select: LevelSelectMenu = get_tree().get_first_node_in_group("Level Select Menu")

var label: Label:
	get: return %Label

var button: Button:
	get: return $Button

var icon: TextureRect:
	get: return $Icon

var id: String:
	get: return get_path()

var is_explored: bool:
	get:
		if not Engine.is_editor_hint():
			return GameManager.current_save.explored_map_nodes.has(id)
		return true
	set(new_val):
		if new_val == true:
			if not GameManager.current_save.explored_map_nodes.has(id):
				GameManager.current_save.explored_map_nodes.append(id)
		else:
			GameManager.current_save.explored_map_nodes.erase(id)
		if map_manager:
			map_manager.redraw_all_map_nodes()

var locked: bool:
	get:
		if GameManager.debug_mode:
			return false
		if always_unlocked:
			return false
		if is_explored:
			return false
		for neighbor: MapNode in connected_map_nodes: 
			if neighbor:
				if neighbor.is_explored:
					return false
		return true


func _ready() -> void:
	if not Engine.is_editor_hint():
		GameManager.debug_mode_changed.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var explored_icon: TextureRect = %"Explored Icon"
	var locked_icon: TextureRect = %"Locked Icon"
	#Icon switching for completion and locked
	if is_explored:
		explored_icon.visible = true
		locked_icon.visible = false
	elif locked:
		explored_icon.visible = false
		locked_icon.visible = true
	else: #if we're incomplete, but unlocked
		explored_icon.visible = false
		locked_icon.visible = false
	
	#TODO get these to render behind
	#Lines that connect nodes
	var line_width: int = 4
	var line_color: Color = map_manager.line_color
	
	#TODO kinda big issue. lines are cut off when the other node is off screen
	#TODO. Doesn't doulbe draw because it only draws halfway. This helps with laying. Long term probalby best to have the map manager handle this
	for neighbor: MapNode in connected_map_nodes:
		if neighbor == null: continue
		
		var center: Vector2 = get_rect().get_center() - global_position
		var destination: Vector2 = neighbor.get_global_rect().get_center() - global_position
		destination = (destination - center)/2 + center #half the length
		draw_line(center,destination,line_color,line_width)

func _on_button_down() -> void:
	pass
