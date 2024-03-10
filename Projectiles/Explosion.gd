@tool
extends Node2D
class_name Explosion


@export var radius: float = 500:
	set(new_val):
		radius = new_val
		queue_redraw()
@export var damage: int = 2
@export var damage_type: GameManager.Damage_Type = GameManager.Damage_Type.FIRE
@export var post_animation_hold_time: float = 5

var visual_size_multiplier: float = 1.5
@onready var visial: AnimatedSprite2D = $"Explosion Visual"
@onready var explosion_hitbox: Area2D = $"Explosion Hitbox"

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO,radius,Color(Color.AQUA,0.5))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	#Explosion animation
	var final_visual_scale: float = (radius*2) / visial.sprite_frames.get_frame_texture("default",0).get_size().x
	final_visual_scale *= visual_size_multiplier
	visial.scale = Vector2(final_visual_scale, final_visual_scale)
	
	visial.play()
	
	#damage in circle
	explosion_hitbox.scale = Vector2(radius,radius)
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for area in explosion_hitbox.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			area.take_damage(damage_type, damage)
	
	await visial.animation_finished
	
	await get_tree().create_timer(post_animation_hold_time).timeout
	
	var tween:= get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	await tween.finished
	
	queue_free()

