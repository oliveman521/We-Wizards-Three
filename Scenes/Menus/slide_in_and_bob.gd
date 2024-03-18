extends Node



@export var direction: Vector2 = Vector2.UP:
	set(new_val):
		direction = new_val.normalized()
@export var enter_delay: float = 0
@export var enter_time: float = 0.5
var distance: float = 1920
var starting_pos: Vector2
@export var bob_dist: float = 20
var bob_time: float = 3:
	get:
		return bob_time * randf_range(0.7,1.3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_pos = self.global_position
	self.global_position = starting_pos - direction * distance
	
	await get_tree().create_timer(enter_delay).timeout
	
	
	var tween:= get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(tween.TRANS_SINE)
	tween.tween_property(self, "global_position", starting_pos, enter_time)
	await tween.finished

	
	var tween2:= get_tree().create_tween()
	tween2.tween_property(self, "global_position", starting_pos + Vector2(0,-bob_dist), bob_time).set_trans(Tween.TRANS_SINE)
	tween2.chain().tween_property(self, "global_position", starting_pos, bob_time).set_trans(Tween.TRANS_SINE)
	tween2.set_loops()
	
	tree_exiting.connect(func()-> void: #this keeps it from erroring when we leave the scene
		tween2.kill()
		)

