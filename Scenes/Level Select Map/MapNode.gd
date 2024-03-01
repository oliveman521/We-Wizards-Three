@tool
extends Control
class_name MapNode

@export var start_unlocked: bool = false

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

		map_manager.redraw_all_map_nodes()

@export var level: PackedScene
@export var card: PackedScene

var map_manager: MapManager:
	get: return $".."

var button: Button:
	get: return $Button


var is_completed: bool:
	get:
		if not Engine.is_editor_hint():
			return GameManager.current_save.completed_map_nodes.has(self)
		return true
	set(new_val):
		if new_val == true:
			if not GameManager.current_save.completed_map_nodes.has(self):
				GameManager.current_save.completed_map_nodes.append(self)
		else:
			GameManager.current_save.completed_map_nodes.erase(self)
		

var locked: bool:
	get:
		if start_unlocked:
			return false
		if is_completed:
			return false
		for neighbor: MapNode in connected_map_nodes: 
			if neighbor.is_completed:
				return false
		return true


func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		#queue_redraw() #TODO probably wasteful. Too bad!
		pass

func _draw() -> void:
	if level:
		var level_data: LevelData = level.instantiate() as LevelData
		button.text = level_data.level_name
		self.name = level_data.level_name
		level_data.queue_free()
	
	
	var complete_icon: TextureRect = %"Complete Icon"
	var locked_icon: TextureRect = %"Locked Icon"
	#Icon switching for completion and locked
	if is_completed:
		complete_icon.visible = true
		locked_icon.visible = false
	elif locked:
		complete_icon.visible = false
		locked_icon.visible = true
	else: #if we're neither complete
		complete_icon.visible = false
		locked_icon.visible = false
	
	#TODO get these to render behind
	#Lines that connect nodes
	var line_width: int = 4
	var line_color: Color = Color.INDIAN_RED
	
	#TODO. Doesn't doulbe draw because it only draws halfway. This helps with laying. Long term probalby best to have the map manager handle this
	for neighbor: MapNode in connected_map_nodes:
		if neighbor == null: continue
		
		var center: Vector2 = get_rect().get_center() - global_position
		var destination = neighbor.get_global_rect().get_center() - global_position
		destination = (destination - center)/2 + center #half the length
		draw_line(center,destination,line_color,line_width)


func _on_button_down() -> void:
	if level:
		if locked:
			GameManager.spawn_popup(global_position,"Level is locked",Color.RED,)
			return
		
		is_completed = true
		GameManager.start_level(level) #TODO this should instead pull up the level info menu and then let the user hit play on that
