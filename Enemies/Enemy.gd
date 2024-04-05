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

@export var move_speed: float= 50
@export var health: float = 5

@export var shovable: bool = true
var is_being_shoved: bool


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
		for child: Node in get_children():
			if child is AnimatedSprite2D:
				child = child as AnimatedSprite2D
				return child.sprite_frames.get_frame_texture("default",0)
			if child is Sprite2D:
				return child.texture
		return null

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !active: return
	if is_being_shoved: return

	move(delta)

func _ready() -> void:
	enemy_name = enemy_name
	
	if !Engine.is_editor_hint():
		if get_parent() is EnemyManager:
			activate()

func move(delta: float) -> void:
	position.x += move_speed * delta

func shoot_projectile() -> void:
	var projectile: Projectile = projectile_prefab.instantiate() as Projectile
	var warlock: Warlock = Warlock.instance
	warlock.projectile_container.add_child(projectile)
	projectile.global_position = projectile_spawner.global_position
	projectile.direction = projectile_spawner.target_position.normalized()
	projectile.target = "Player"
	fire_rate_timer.wait_time = fire_interval * randf_range(0.8,1.2)

func take_damage(damage_type: GameManager.Damage_Type, amnt: float) -> void:
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
	if projectile_prefab:
		fire_rate_timer.wait_time = fire_interval
		fire_rate_timer.start()
		fire_rate_timer.timeout.connect(shoot_projectile)


func _on_body_entered(body: Node2D) -> void:
	if !shovable: return
	if is_being_shoved: return
	
	#TODO this should continue as long as we're still overlapping
	if body is Warlock:
		var shove_dist: float = 50
		var shove_time: float = 0.3
		
		is_being_shoved = true
		var tween: Tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self,"position", position - Vector2(shove_dist,0), shove_time)
		await tween.finished
		
		is_being_shoved = false
