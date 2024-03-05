extends Node2D
class_name Explosion


@export var radius: float = 500
@export var damage: int = 2
@export var damage_type: GameManager.Damage_Type = GameManager.Damage_Type.FIRE
@export var animation_time: float = 0.25

@onready var visial: Sprite2D = $"Explosion Visual"
@onready var explosion_hitbox: Area2D = $"Explosion Hitbox"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#Explosion animation
	var final_visual_scale: Vector2 = visial.get_rect().size / (Vector2(radius,radius)*2)
	visial.scale = Vector2.ZERO
	var tween:= get_tree().create_tween()
	visial.visible = true
	visial.scale = Vector2.ZERO
	tween.tween_property(visial, "scale", final_visual_scale, animation_time).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	
	#damage in circle
	explosion_hitbox.scale = Vector2(radius,radius)
	for area in explosion_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			area.take_damage(damage_type, damage)
	
	queue_free()

