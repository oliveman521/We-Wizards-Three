extends Label

var time_to_show: float = 10

@onready var time_since_map_moved_timer: Timer = $"Time Since Map Moved"

var fade_time: float = 0.5
var last_frame_camera_pos: Vector2
var alpha: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	modulate = Color(1,1,1,alpha)
	time_since_map_moved_timer.wait_time = time_to_show
	time_since_map_moved_timer.start()


func _process(delta: float) -> void:
	if time_since_map_moved_timer.is_stopped():
		alpha += delta / fade_time
	else:
		alpha -= delta / fade_time
	
	if get_viewport().get_camera_2d().global_position != last_frame_camera_pos:
		time_since_map_moved_timer.start()
	last_frame_camera_pos = get_viewport().get_camera_2d().global_position
	
	alpha = clamp(alpha,0,1)
	modulate = Color(1,1,1,alpha)
