@tool
extends Enemy

@export var amplitude: float = 150
@export var period: float = 500
@export var randomize_phase: bool = true
var starting_pos: Vector2
var phase_shift: float = 0
var x: float = 0
func activate() -> void:
	super.activate()
	
	#print("max",EnemyManager.max_y,"min",EnemyManager.min_y)
	#print("Upper",position.y + amplitude/2,"Lower",position.y - amplitude/2)
	
	if position.y + amplitude/2 > EnemyManager.max_y:
		position.y = EnemyManager.max_y - amplitude/2
		#print("Clamping" + name + "down")
	if position.y - amplitude/2 < EnemyManager.min_y:
		position.y = EnemyManager.min_y + amplitude/2
		#print("Clamping" + name + "up")
		
	starting_pos = global_position
	if randomize_phase:
		phase_shift += randf_range(0,period)

func move(delta: float) -> void:
	super.move(delta) #move forward
	x += delta * max_speed #step forward our wave
	if !is_being_knocked_back:
		position.y = starting_pos.y + amplitude*sin((x *2* PI /period) + phase_shift)

func realign_sin_wave() -> void:
	#by recalculating the phase shift we realign the sine wave to ourselves in case we've fallen out of sync with the wave. IE by getting knocked back
	phase_shift = asin((position.y - starting_pos.y)/amplitude) - (position.x *2* PI /period)

func knockback(dist: float) -> void:
	await super.knockback(dist)
