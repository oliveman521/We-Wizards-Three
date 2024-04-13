@tool
extends Node2D
class_name Enemy

var enemy_name: String:
	get:
		var file_name: String = scene_file_path.get_basename().split("/")[-1]
		file_name = file_name.replace("enemy_","")
		file_name = file_name.capitalize()
		name = file_name
		return file_name

@export var max_speed: float= 60
@export var health: float = 5
@export var play_bounce_walk_animation: bool = true

@export_range(0,1) var knockback_multiplier: float = 1
var knockback_tween: Tween
var is_being_knocked_back: bool = false


@export_group("Damage Types")
@export var vulnerabilities: Array[GameManager.Damage_Type]
@export var resistances: Array[GameManager.Damage_Type]
@export var immunities: Array[GameManager.Damage_Type]

@export_group("On Death Effects")
@export var spawn_on_death: Array[PackedScene]
@export var death_effect_location_noise: float = 25

@export_group("Projectile Firing")
@export var projectile_prefab: Resource
@export var fire_interval: float = 2
@onready var fire_rate_timer: Timer = $"Fire Rate Timer"
@onready var projectile_spawner: RayCast2D = $"Projectile Spawner"

var active: bool = false


const DAMAGE_COLOR = Color(1,0,0)


var icon: Texture:
	get:
		for child: Node in $GFX.get_children():
			if child is AnimatedSprite2D:
				child = child as AnimatedSprite2D
				return child.sprite_frames.get_frame_texture("default",0)
			if child is Sprite2D:
				return child.texture
		return null



func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !active: return
	if is_being_knocked_back: return
	
	bounce_walk_animation_player.speed_scale = max_speed / 50 #adjust our animation speed to match out speed
	move(delta)

@onready var bounce_walk_animation_player: AnimationPlayer = $BounceWalkAnimationPlayer


func _ready() -> void:
	enemy_name = enemy_name
	
	if !Engine.is_editor_hint():
		if get_parent() is EnemyManager:
			activate()

func move(delta: float) -> void:
	
	position.x += delta * max_speed

func shoot_projectile() -> void:
	var projectile: Projectile = projectile_prefab.instantiate() as Projectile
	var dir: Vector2 = projectile_spawner.target_position.normalized()
	var pos: Vector2 = projectile_spawner.global_position
	projectile.initialize(pos, dir, true)
	
	fire_rate_timer.wait_time = fire_interval * randf_range(0.8,1.2)

func take_damage(damage_type: GameManager.Damage_Type, amnt: float, knock_back: float = 0) -> void:
	if !active: return
	
	if damage_type == GameManager.Damage_Type.MANA:
		amnt += GameManager.get_passive_ability_count("Mana Damage")
	for i in range (GameManager.get_passive_ability_count("Double Damage")):
		amnt *= 2
	
	if immunities.has(damage_type):
		GameManager.spawn_popup(global_position, "IMMUNE!", Color.ORANGE)
		return
	
	if vulnerabilities.has(damage_type):
		amnt *= 2
		GameManager.spawn_popup(global_position, "Critical Hit!", Color.GREEN)
		
	if resistances.has(damage_type):
		amnt *= .5
		GameManager.spawn_popup(global_position, "Resist!", Color.YELLOW)
	
	health -= amnt
	
	var popup_text: String = "- " + str(amnt)
	GameManager.spawn_popup(position, popup_text, DAMAGE_COLOR, 1)
	
	knockback(knock_back)
	
	if health <= 0:
		die()


func die() -> void:
	for item: PackedScene in spawn_on_death:
		var new_node: Node2D = item.instantiate() as Node2D
		var randomize_location: Vector2 = Vector2(death_effect_location_noise, death_effect_location_noise)
		new_node.global_position = global_position + randomize_location
		add_sibling(new_node)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Tower Hit Zone":
		GameManager.lives -= 1
		GameManager.spawn_popup(global_position, "LIFE LOST!", Color.RED)
		SoundManager.play_sound($"Damaged Base Sound")
		GameCamera.instance.shake(0.6)
		queue_free()

func _on_screen_enter() -> void:
	if not active:
		activate()

func activate() -> void:
	active = true
	self.reparent(GameManager.enemy_manager)
	if play_bounce_walk_animation:
		bounce_walk_animation_player.play("Walk")
	if projectile_prefab:
		fire_rate_timer.wait_time = fire_interval
		fire_rate_timer.start()
		fire_rate_timer.timeout.connect(shoot_projectile)


func _on_body_entered(body: Node2D) -> void:
	#TODO this should repeat as long as we're still overlapping
	if body is Warlock:
		knockback(50)

var current_knockback_point: Vector2 = Vector2.ZERO
func knockback(dist: float) -> void:
	dist = dist * knockback_multiplier
	const knockback_speed: float = 150
	var knockback_time: float = dist / knockback_speed
	var new_knockback_point: Vector2 = position - Vector2(dist,0)
	
	if is_being_knocked_back:#if we're still being knocked back
		if new_knockback_point.x < current_knockback_point.x: #if the new knockback will take us back further
			if knockback_tween:
				knockback_tween.kill() # kill the old one
		else:
			return #ignore the new knockback if it aint enough
	
	bounce_walk_animation_player.pause()
	current_knockback_point = new_knockback_point
	is_being_knocked_back = true
	knockback_tween = create_tween()
	knockback_tween.set_ease(Tween.EASE_OUT)
	knockback_tween.set_trans(Tween.TRANS_SINE)
	knockback_tween.set_trans(Tween.TRANS_SINE)
	knockback_tween.tween_property(self,"position", new_knockback_point, knockback_time)
	
	await knockback_tween.finished
	if play_bounce_walk_animation:
		bounce_walk_animation_player.play()
	print("KB 2")
	is_being_knocked_back = false

