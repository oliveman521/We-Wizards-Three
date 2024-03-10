extends Projectile

const lightning_lifetime = .5

func _ready() -> void:
	super._ready()
	var tween := get_tree().create_tween()
	var target_color:= sprite.modulate
	target_color.a = 0 
	tween.tween_property(sprite, "modulate", target_color, .25).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(queue_free)
