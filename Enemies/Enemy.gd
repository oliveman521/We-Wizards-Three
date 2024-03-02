@tool
extends Node2D
class_name Enemy

@export var enemy_name: String= "unnamed_enemy":
	set(new_val):
		enemy_name = new_val
		self.name = enemy_name
	get:
		if enemy_name == "unnamed_enemy":
			print("Warning: tried to get the name of enemy who's name has not yet been set up")
		return enemy_name

@export var move_speed: float= 50
@export var health: float = 5

@export var vulnerabilities: Array[GameManager.Damage_Type]
@export var resistances: Array[GameManager.Damage_Type]
@export var immunities: Array[GameManager.Damage_Type]

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
	
	if active:
		move(delta)

func _ready() -> void:
	name = "Enemy - " + enemy_name

func move(delta: float) -> void:
	position.x += move_speed * delta

func shoot_projectile() -> void:
	var projectile: Projectile = projectile_prefab.instantiate() as Projectile
	var warlock:WarlockCharacter = GameManager.warlock_character as WarlockCharacter
	warlock.projectile_container.add_child(projectile)
	projectile.global_position = projectile_spawner.global_position
	projectile.direction = projectile_spawner.target_position.normalized()
	projectile.target = 1 #1 means the projectile will try to damage players
	fire_rate_timer.wait_time = fire_interval * randf_range(0.8,1.2)

func take_damage(damage_type: GameManager.Damage_Type, amnt: float) -> void:
	
	if damage_type == GameManager.Damage_Type.MANA:
		amnt += GameManager.get_passive_ability_count(GameManager.Passive_Ability_Tag.MANA_DAMAGE)
	for i in range (GameManager.get_passive_ability_count(GameManager.Passive_Ability_Tag.DOUBLE_DAMAGE)):
		amnt *= 2
	
	if immunities.has(damage_type):
		print("enemy is immune to that damage type!")
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
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Tower Hit Zone":
		GameManager.lives -= 1
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
