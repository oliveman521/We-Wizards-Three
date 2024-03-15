extends Camera2D


var panning: bool = false
var grab_point: Vector2
var camera_pos_at_start_of_grab: Vector2
@onready var target_pos: Vector2 = global_position
@onready var target_zoom: Vector2 = zoom
const camera_follow_multiplier: float  = 20
const camera_zoom_follow_multiplier: float  = 15
@onready var map_manager: MapManager = $"../Map Manager"


const zoom_factor: float = 1.15

func _ready() -> void:
	move_to_starting_point()
	enabled = true

func move_to(g_position: Vector2) -> void:
	global_position = g_position
	target_pos = g_position

func move_to_starting_point() -> void:
	var cur_save: GameSave = GameManager.current_save as GameSave
	if cur_save.explored_map_nodes.size() > 0:
		move_to(map_manager.get_map_node_by_id(cur_save.explored_map_nodes.back()).get_global_rect().get_center())

func _process(delta: float) -> void:
	
	#TODO this scrolling triggers even if we're scrolling another object
	if Input.is_action_just_pressed("map_zoom_in"):
		target_zoom *= Vector2(zoom_factor,zoom_factor)
	if Input.is_action_just_pressed("map_zoom_out"):
		target_zoom /= Vector2(zoom_factor,zoom_factor)
	
	if Input.is_action_just_pressed("map_pan"):
		panning = true
		grab_point = get_local_mouse_position()
		camera_pos_at_start_of_grab = global_position
	if Input.is_action_just_released("map_pan"):
		panning = false

	if panning:
		target_pos = camera_pos_at_start_of_grab + grab_point - get_local_mouse_position()
	
	global_position = global_position.slerp(target_pos,delta* camera_follow_multiplier)
	zoom = zoom.slerp(target_zoom,delta* camera_zoom_follow_multiplier)
	
	
