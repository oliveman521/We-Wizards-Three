@tool
extends Enemy

@export var amplitude: float = 150
@export var period: float = 500
@export var randomize_phase: bool = true
var starting_pos: Vector2
var phase_shift: float = 0
func activate() -> void:
	super.activate()
	starting_pos = global_position
	if randomize_phase:
		phase_shift = randf_range(0,period)

func move(delta: float) -> void:
	super.move(delta)
	position.y = starting_pos.y + amplitude*sin((position.x *2* PI /period) + phase_shift)

