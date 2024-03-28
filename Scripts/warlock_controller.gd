extends CharacterBody2D
class_name WarlockCharacter

var base_speed: float = 250

@onready var projectile_spawn_point: Node2D = $"Projectile Spawn Point"

@onready var fire_cooldown_timer: Timer = $FireCooldownTimer
@onready var projectile_container: Node2D = %"Projectile Container"
@onready var stun_timer: Timer = $"Stun Timer" as Timer




var is_stunned: bool: 
	get: return not stun_timer.is_stopped()

var move_speed: float:
	get:
		return base_speed

func _ready() -> void:
	GameManager.warlock_character = self as WarlockCharacter


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

	
	#Bullets
	if Input.is_action_pressed("ship_shoot1"):
		shoot(GameManager.MANA) #TODO make not having amm make this not full auto
	if Input.is_action_just_pressed("ship_shoot2"):
		shoot(GameManager.FIRE)
	if Input.is_action_just_pressed("ship_shoot3"):
		shoot(GameManager.LIGHTNING)

	move_and_slide()

func shoot(ammo_type: Ammo_Type) -> void:
	if fire_cooldown_timer.time_left > 0:
		return
	
	if ammo_type.use_supply() or GameManager.debug_mode:
		var new_projectile: Node2D = ammo_type.projectile_prefab.instantiate()
		projectile_container.add_child(new_projectile)
		new_projectile.set_global_position(projectile_spawn_point.global_position)
		
		var cool_down:float = ammo_type.fire_cooldown
		var fire_rate_multiplier: float = GameManager.get_passive_ability_count("Warlock Fire Rate")
		fire_rate_multiplier = clamp(fire_rate_multiplier, 1, 10) #TODO I don't love this solution
		cool_down /= fire_rate_multiplier
		
		fire_cooldown_timer.wait_time = cool_down
		fire_cooldown_timer.start()
	else:
		fire_cooldown_timer.wait_time = 0.1
		fire_cooldown_timer.start()
		GameManager.spawn_popup(global_position,"No Scrolls!",Color(1,0.8,.1))

func take_damage(damage: float) -> void:
	var stun_time: float = damage
	
	if stun_timer.time_left < stun_time:
		stun_timer.wait_time = stun_time
		stun_timer.start()
	
	GameManager.spawn_popup(position, "Stunned!", Color.YELLOW)
	GameCamera.instance.shake(0.15)
	
