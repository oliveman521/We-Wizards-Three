class_name GameCamera
extends Camera2D


static var instance: GameCamera = null


@export var perlin_noise: FastNoiseLite = FastNoiseLite.new()
var trauma: float = 0
@onready var start_rotation: float = rotation


func _ready() -> void:
	instance = self
	#Camera shake is a blend of this tutoprial: https://www.youtube.com/watch?v=AobjNjzZhmo
	#The noise stuff from this tutorial/presentation https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/
	#plus adapting it to what seems like the new version of Godot's noise engine: https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html
	
	perlin_noise.noise_type = FastNoiseLite.TYPE_PERLIN 
	perlin_noise.frequency = 0.0045 #Higher number means faster shakes
	

func _process(delta: float) -> void:
	const decay_time_seconds: float = 1.5 #time it takes for a max hit to decay to 0
	
	trauma -= delta / decay_time_seconds
	trauma = clamp(trauma,0,1)
	
	const max_translation: Vector2 = Vector2(400,275)
	const max_rotation: float = deg_to_rad(3)
	var damping: float = trauma * trauma
	
	offset = Vector2(
		perlin_noise.get_noise_1d(Time.get_ticks_msec()) * max_translation.x * damping,
		perlin_noise.get_noise_1d(Time.get_ticks_msec()+1) * max_translation.y * damping,
	)
	
	rotation = start_rotation + perlin_noise.get_noise_1d(Time.get_ticks_msec() + 2) * max_rotation * damping

var screen_flash_tween: Tween

func flash(magnitude: float) -> void:
	trauma += magnitude
	if trauma > 1:
		print("warning! Trauma was set too high: ", trauma)
		trauma = 1

func shake(magnitude: float) -> void:
	trauma += (1 - trauma) * magnitude #this makes added trauma work on percentages. I.E a .5 will always take us another 50% of the way to max.
	# Eg. A .5 trauma, followed by antoher .5 trauma, puts us at .75 trauma
	if trauma > 1:
		print("warning! Trauma was set too high: ", trauma)
		trauma = 1
