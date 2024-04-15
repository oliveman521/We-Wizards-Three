extends CharacterBody2D
class_name Warlock

var base_speed: float = 250

@onready var projectile_spawn_point: RayCast2D = $"Projectile Spawn Point"

@onready var fire_cooldown_timer: Timer = $FireCooldownTimer
@onready var projectile_container: Node2D = %"Projectile Container"
@onready var stun_timer: Timer = $"Stun Timer" as Timer

static var instance: Warlock

const DOWN_CAST_ANIM: String = "Down Cast"
const UP_CAST_ANIM: String = "Up Cast"
const WALK_ANIM: String = "Walk"
const IDLE_ANIM: String = "Idle"
@onready var walk_animation_player: AnimationPlayer = $"GFX/Walk Animation Player"
@onready var casting_animation_player: AnimationPlayer = $"GFX/Casting Animation Player"



var projectiles: Array[Projectile] = []

var is_stunned: bool: 
	get: return not stun_timer.is_stopped()

var move_speed: float:
	get:
		return base_speed

func _ready() -> void:
	instance = self

var MANA_ORB: Ammo_Type = load("res://Supplies/Mana_Orb.tres")
var FIRE_ORB: Ammo_Type = load("res://Supplies/Fire_Orb.tres")
var LIGHTNING_ORB: Ammo_Type = load("res://Supplies/Lightning_Orb.tres")

func _process(_delta: float) -> void:
	if is_stunned: return
	
	var input_dir: Vector2 = Input.get_vector("warlock_left","warlock_right","warlock_up","warlock_down")
	if input_dir != Vector2.ZERO:
		velocity = input_dir * move_speed
	else:
		velocity = Vector2.ZERO
	
	
	var warlock_move_area: ColorRect = $"../Warlock Move Area"
	var collision_shape_2d: CollisionShape2D = $CollisionShape2D
	var move_area_rect: Rect2 = warlock_move_area.get_global_rect()
	
	#TODO this creates a bit of jitter when ramming the walls
	var warlock_rect: Rect2 = collision_shape_2d.shape.get_rect()
	position.y = clamp(position.y, move_area_rect.position.y + warlock_rect.size.y/2, move_area_rect.end.y - warlock_rect.size.y/2)
	position.x = clamp(position.x, move_area_rect.position.x + warlock_rect.size.x/2, move_area_rect.end.x - warlock_rect.size.x/2)

	#Walk Animations:
	walk_animation_player.speed_scale = velocity.length() / 100
	if velocity == Vector2.ZERO:
		walk_animation_player.play(IDLE_ANIM)
	else:
		walk_animation_player.play(WALK_ANIM)
	
	#Bullets
	if Input.is_action_pressed("warlock_shoot1"):
		shoot(MANA_ORB)
	if Input.is_action_just_pressed("warlock_shoot2"):
		shoot(FIRE_ORB)
	if Input.is_action_just_pressed("warlock_shoot3"):
		shoot(LIGHTNING_ORB)
	
	move_and_slide()

var most_recent_arm_swing: String = ""
func shoot(ammo_type: Ammo_Type) -> void:
	
	if fire_cooldown_timer.time_left > 0:
		return #Check if we're ready to shoot or not


	if ammo_type.use_supply() or GameManager.debug_mode:
		#if we have ammo

		var new_projectile: Projectile = ammo_type.projectile_prefab.instantiate() as Projectile
		var pos: Vector2 = projectile_spawn_point.global_position
		var dir: Vector2 = projectile_spawn_point.target_position.normalized()
		new_projectile.initialize(pos,dir,false)
		
		var cool_down:float = ammo_type.fire_cooldown
		var fire_rate_multiplier: float = GameManager.get_passive_ability_count("Warlock Fire Rate")
		fire_rate_multiplier = clamp(fire_rate_multiplier, 1, 10) #TODO I don't love this solution
		cool_down /= fire_rate_multiplier
		
		fire_cooldown_timer.wait_time = cool_down
		fire_cooldown_timer.start()
		
		#Animations
		casting_animation_player.speed_scale = cool_down / 0.2
		if most_recent_arm_swing != UP_CAST_ANIM:
			casting_animation_player.play(UP_CAST_ANIM)
			most_recent_arm_swing = UP_CAST_ANIM
		else:
			casting_animation_player.play(DOWN_CAST_ANIM)
			most_recent_arm_swing = DOWN_CAST_ANIM
			
	else:
		fire_cooldown_timer.wait_time = 0.1
		fire_cooldown_timer.start()
		GameManager.spawn_popup(global_position,"No Orbs!",Color(1,0.8,.1))

func take_damage(damage: float) -> void:
	var stun_time: float = damage
	
	if stun_timer.time_left < stun_time:
		stun_timer.wait_time = stun_time
		stun_timer.start()
	
	GameManager.spawn_popup(position, "Stunned!", Color.YELLOW)
	GameCamera.instance.shake(0.15)
	
