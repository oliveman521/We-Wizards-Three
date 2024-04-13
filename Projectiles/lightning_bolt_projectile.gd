extends Projectile

const lightning_lifetime: float = .5
@onready var line_renderer: Line2D = $"Line Renderer"


func _ready() -> void:
	var point_interval: float = 100
	var point_noise: float = 50
	
	var perlin_noise: FastNoiseLite = FastNoiseLite.new()
	perlin_noise.noise_type = FastNoiseLite.TYPE_PERLIN 
	perlin_noise.frequency = 0.0045 #Higher number means faster shakes
	
	
	line_renderer.clear_points()
	
	var point_count: int = 1000/point_interval
	for i in range(point_count):
		var clean_x: float = point_interval * i
		var x: float = clean_x + perlin_noise.get_noise_1d(clean_x + Time.get_ticks_msec()) * point_noise
		var y: float = position.y + perlin_noise.get_noise_1d(clean_x +  Time.get_ticks_msec() + 1000) * point_noise
		line_renderer.add_point(Vector2(x,y))
	

	#Fade out line
	var tween := get_tree().create_tween()
	var target_color:= line_renderer.modulate
	target_color.a = 0
	tween.set_trans(Tween.TRANS_EXPO)
	#tween.tween_property(line_renderer, "modulate", target_color, .25)
	tween.parallel().tween_property(line_renderer, "width", 0, lightning_lifetime)
	
	tween.tween_callback(queue_free)
