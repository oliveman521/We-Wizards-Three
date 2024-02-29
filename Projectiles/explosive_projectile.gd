extends Projectile

@export var explosive_damage: float = 1

@onready var explosion_visual: Sprite2D = $"Explosion Visual"
@onready var explosion_hitbox: Area2D = $"Explosion Hitbox"

@onready var final_visual_scale := explosion_visual.scale

func _ready() -> void: 
	explosion_visual.visible = false

func impact_effect() -> void:
	sprite.visible = false
	speed = 0
	
	#Explosion animation
	var tween:= get_tree().create_tween()
	explosion_visual.visible = true
	explosion_visual.scale = Vector2.ZERO
	tween.tween_property(explosion_visual, "scale", final_visual_scale, 0.25).set_trans(Tween.TRANS_QUINT)
	
	#damage in circle
	for area in explosion_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			area.take_damage(ammo_type.damage_type, explosive_damage)
	
	tween.tween_callback(queue_free)
