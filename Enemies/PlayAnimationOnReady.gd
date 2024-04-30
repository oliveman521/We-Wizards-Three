extends AnimationPlayer

@export var anim_name: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(anim_name)
