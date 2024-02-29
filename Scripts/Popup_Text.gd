extends Label

class_name Popup_Text

var rise_dist: float = 15
const POSITION_NOISE = 8

@export var fade_curve: Curve
@export var rise_curve: Curve

@onready var lifetime_timer: Timer = get_node("Timer")

@onready var start_pos: Vector2 = position

func initialize(location: Vector2, message: String, color: Color, lifetime:float = 1) -> void:
	text = message
	modulate = color
	lifetime_timer.wait_time = lifetime
	global_position = location + Vector2(randf_range(-POSITION_NOISE,POSITION_NOISE),randf_range(-POSITION_NOISE,POSITION_NOISE))
	start_pos = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var percent_finished: float = (lifetime_timer.wait_time - lifetime_timer.time_left) /lifetime_timer.wait_time
	modulate.a = fade_curve.sample(percent_finished)
	global_position.y = start_pos.y - rise_curve.sample(percent_finished) *rise_dist


func _on_timer_timeout() -> void:
	queue_free()
