extends Node2D
class_name Projectile

@export var speed: float = 750
@export var damage: float = 1
@export var damage_type: GameManager.Damage_Type
@export var knockback: float = 10
#Used for effects like the explosion
@export var spawn_on_hit: Array[PackedScene]
@export var piercing: bool = false

@export_range(0,0.5) var screen_shake_on_shot: float = 0.01
@export_range(0,0.5) var screen_shake_on_hit: float = 0.01


@export var shoot_sound_pitch_variance: float = 0.2
@onready var shoot_sound: AudioStreamPlayer2D = $"Shoot Sound"
@onready var hit_sound: AudioStreamPlayer2D = $"Hit Sound"

@onready var sprite: Sprite2D = $Sprite


@onready var shoot_particles: GPUParticles2D = $"Shoot Particles"

var direction: Vector2 = Vector2(-1,0)

var targets_player: bool = false


func initialize(pos: Vector2, dir: Vector2, _targets_player: bool) -> void:
	Warlock.instance.projectile_container.add_child(self)
	
	#TODO add angle noise here
	targets_player = _targets_player
	direction = dir
	global_position = pos
	rotation = direction.angle()
	
	SoundManager.play_sound(shoot_sound, shoot_sound_pitch_variance)
	GameCamera.instance.shake(screen_shake_on_shot)
	
	Warlock.instance.projectile_container.add_child(shoot_particles)
	shoot_particles.emitting = true
	shoot_particles.finished.connect(func() -> void:
		shoot_particles.queue_free()
		)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation = direction.angle()


func _on_area_exited(area: Area2D) -> void:
	if area.name == "Play Boundry":
		queue_free()

func impact_effect() -> void:
	GameCamera.instance.shake(screen_shake_on_hit)
	SoundManager.play_sound(hit_sound)
	for item: PackedScene in spawn_on_hit:
		var new_node: Node2D = item.instantiate() as Node2D
		new_node.global_position = global_position
		add_sibling(new_node)
	if not piercing:
		queue_free() #delete bullet


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and targets_player: #TODO make the player take damage
		body.take_damage(damage)
		impact_effect()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and not targets_player:
		area.take_damage(damage_type, damage, knockback)
		impact_effect()
