extends Camera2D


var panning: bool = false
var grab_point: Vector2
var camera_pos_at_start_of_grab: Vector2
@onready var target_pos: Vector2 = global_position
@onready var target_zoom: float = zoom.x
const camera_follow_multiplier: float  = 20
const camera_zoom_follow_multiplier: float  = 15
@onready var map_manager: MapManager = $"../Map Manager"
@onready var map_bounds: Control = $"../Map Manager/Map Bounds"


const zoom_factor: float = 1.10
const max_zoom: float = 4
const min_zoom: float = 1



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


func map_bound_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	event = event as InputEventMouseButton
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		target_zoom *= zoom_factor
	if  event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		target_zoom /= zoom_factor
	
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			panning = true
			grab_point = get_local_mouse_position()
			camera_pos_at_start_of_grab = global_position
		elif event.is_released():
			panning = false
	

func _process(delta: float) -> void:
	
	"""#TODO this scrolling triggers even if we're scrolling another object
	if Input.is_action_just_pressed("map_zoom_in"):
		target_zoom *= Vector2(zoom_factor,zoom_factor)
	if Input.is_action_just_pressed("map_zoom_out"):
		target_zoom /= Vector2(zoom_factor,zoom_factor)
	
	if Input.is_action_just_pressed("map_pan"):
		panning = true
		grab_point = get_local_mouse_position()
		camera_pos_at_start_of_grab = global_position
	if Input.is_action_just_released("map_pan"):
		panning = false"""
	
	
	

	
	if panning:
		target_pos = camera_pos_at_start_of_grab + grab_point - get_local_mouse_position()
		
	#TODO this should probably only trigger on mouse moves and clicks
	var bounds_rect: Rect2 = map_bounds.get_global_rect()
	var cam_dim: Vector2 = get_viewport_rect().size / zoom
	var half_cam_dim: Vector2 = cam_dim / 2
	target_pos.x = clamp(target_pos.x, bounds_rect.position.x + half_cam_dim.x, bounds_rect.end.x - half_cam_dim.x)
	target_pos.y = clamp(target_pos.y, bounds_rect.position.y + half_cam_dim.y, bounds_rect.end.y - half_cam_dim.y)
	
	global_position = global_position.slerp(target_pos,delta* camera_follow_multiplier)
	zoom = zoom.slerp(Vector2(target_zoom, target_zoom),delta* camera_zoom_follow_multiplier)
	
	
