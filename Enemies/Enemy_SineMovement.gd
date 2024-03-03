@tool
extends Enemy

@export var amplitude: float = 150
@export var period: float = 500
var starting_pos: Vector2

func activate() -> void:
	super.activate()
	starting_pos = global_position

func move(delta: float) -> void:
	super.move(delta)
	position.y = starting_pos.y + amplitude*sin(position.x *2* PI /period)

