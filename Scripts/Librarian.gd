extends CharacterBody2D
class_name Librarian

var move_speed: float = 300

var combo: int = 1:
	set(new_val):
		new_val = clamp(new_val, 0, max_combo)
		combo = new_val
		#update UI
		var combo_num_label: Label = %"Combo Num Label" as Label
		var combo_display: Control = %"Combo Display" as Control
		var combo_type_icon: TextureRect = %"Combo Type Icon" as TextureRect


		if max_combo <= 1:
			combo_display.visible = false
		
		combo_num_label.text = str(combo)
		
		if last_pickup_type:
			combo_type_icon.visible = true
			combo_type_icon.texture = last_pickup_type.icon
		else:
			combo_type_icon.visible = false

var last_pickup_type: Supply


var max_combo_bonus: int = 0
var max_combo: int:
	get:
		return 1 + GameManager.current_save.check_unlock("Max Combo") + max_combo_bonus


@onready var stun_timer: Timer = $"Stun Timer"

var boost_multiplier: float = 3
var boost_durration: float = 0.1
@onready var boost_timer: Timer = $"Boost Timer"

@onready var footstep_timer: Timer = $"Footstep Timer"
@onready var footstep_sound: AudioStreamPlayer2D = $"Footstep Sound"
var distance_per_footstep: float = 75

@onready var librarian_gfx: Node2D = %"Librarian GFX"
@onready var movement_animation_player: AnimationPlayer = %MovementAnimationPlayer
@onready var arm_animation_player: AnimationPlayer = %ArmAnimationPlayer

const WALK_ANIMATION: String = "Walk"
const IDLE_ANIMATION: String = "Idle"
const PICKUP_ANIMATION: String = "Pickup"

var boosting: bool = false:
	get:
		return !boost_timer.is_stopped()

var is_stunned: bool: 
	get: return not stun_timer.is_stopped()


var input_dir : Vector2

#var combo_progression: Array[float] = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 7, 8, 9, 10]
static var instance: Librarian

func _ready() -> void:
	instance = self
	
	combo = 0
	footstep_timer.timeout.connect(func() -> void:
		SoundManager.play_sound(footstep_sound,0.2)
		footstep_timer.start()
		)

var last_frame_input_dir: Vector2 = Vector2.ZERO
func _process(_delta: float) -> void:
	
	if is_stunned: return
	
	if not boosting: #we can only update our movement direction if we aren;'t boosting
		input_dir = Input.get_vector("labyrinth_left","labyrinth_right","labyrinth_up","labyrinth_down")
	
	input_dir = input_dir.normalized()
	velocity = input_dir * move_speed
	
	var boost_unlocked: bool = GameManager.current_save.check_unlock("Librarian Boost") > 0
	var can_boost: bool = (not boosting) and boost_unlocked
	
	if Input.is_action_just_pressed("labyrinth_boost") and can_boost:
		boost_timer.wait_time = boost_durration
		boost_timer.start()
	
	if boosting:
		velocity *= boost_multiplier
	
	move_and_slide()
	
	#sounds
	if velocity.length() == 0:
		footstep_timer.stop()
	else:
		footstep_timer.wait_time = 1/velocity.length() * distance_per_footstep
		if footstep_timer.is_stopped():
			footstep_timer.wait_time *= 0.3
			footstep_timer.start()
	
	
	movement_animation_player.speed_scale = velocity.length()/200 + 1
	
	if input_dir.x > 0: #moving right
		librarian_gfx.scale.x = -abs(librarian_gfx.scale.x)
	elif input_dir.x < 0: #moving left
		librarian_gfx.scale.x = abs(librarian_gfx.scale.x)
	
	

	
	
	if input_dir != Vector2.ZERO:
		if movement_animation_player.current_animation != WALK_ANIMATION:
			movement_animation_player.play(WALK_ANIMATION)
		if arm_animation_player.current_animation != WALK_ANIMATION && arm_animation_player.current_animation != PICKUP_ANIMATION:
			arm_animation_player.play(WALK_ANIMATION)
	else:
		if movement_animation_player.current_animation != IDLE_ANIMATION:
			movement_animation_player.play(IDLE_ANIMATION)
		if arm_animation_player.current_animation != IDLE_ANIMATION && arm_animation_player.current_animation != PICKUP_ANIMATION:
			arm_animation_player.play(IDLE_ANIMATION)


func _on_collection_hitbox_area_entered(area: Area2D) -> void:
	if area is Pickup:
		var pickup: Pickup= area as Pickup
		if pickup.supply_to_be_gained == last_pickup_type:
			combo += 1
		else:
			combo = 1
		last_pickup_type = pickup.supply_to_be_gained
		
		combo = combo #Refreshes the combo graphic again to reflect the new pickup type if its changed
		
		# Sounds!
		if combo > 0:
			pickup.pickup_sound.pitch_scale += 0.1 * combo
		SoundManager.play_sound(pickup.pickup_sound)
		
		# Animation!
		arm_animation_player.play(IDLE_ANIMATION,0) #this makes interrupting the prvious one work smoothly
		arm_animation_player.play(PICKUP_ANIMATION,0.05)
		arm_animation_player.queue(IDLE_ANIMATION)
		
		#TODO put item in hand
		#TODO delete gfx item when animation is over
		
		#Math!
		var gain_count: int = (combo * pickup.count_to_be_gained)
		var passive_multiplier: int =  int(GameManager.get_passive_ability_count("Next Pickup Multiplier"))
		if passive_multiplier > 0:
			gain_count += passive_multiplier
		
		pickup.supply_to_be_gained.on_pickup(gain_count)
		pickup.queue_free()

func take_damage(amnt: int) -> void:
	var stun_time: float = amnt
	
	combo = 0
	
	if stun_timer.time_left < stun_time:
		stun_timer.wait_time = stun_time
		stun_timer.start()
	
	GameManager.spawn_popup(global_position, "Stunned!", Color.YELLOW)
