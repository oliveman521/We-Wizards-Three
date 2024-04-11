extends Node2D

@onready var left_arm: Sprite2D = $LeftArm
var left_arm_neutral_angle: float


@onready var right_arm: Sprite2D = $RightArm
var right_arm_neutral_angle: float
var right_arm_target_angle: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const PLAY_ANIM: String = "Cast"
const IDLE_ANIM: String  = "Idle"
const DISCARD_ANIM: String  = "Discard"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left_arm_neutral_angle = left_arm.rotation_degrees
	right_arm_neutral_angle = right_arm.rotation_degrees
	
	animation_player.play(IDLE_ANIM)
	CardManager.instance.card_played.connect(func(_card: Card) -> void:
		animation_player.play(IDLE_ANIM)#this makes it so it'll restart the animation if it's alteady playign the play animation. Otherwise if we're already playing a card it'll just finish that animation unaffected
		animation_player.play(PLAY_ANIM)
		animation_player.queue(IDLE_ANIM)
		)
	CardManager.instance.card_discarded.connect(func(_card: Card) -> void:
		animation_player.play(IDLE_ANIM)
		animation_player.play(DISCARD_ANIM)
		animation_player.queue(IDLE_ANIM)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	const arm_move_speed: float = 10
	var mouse_angle: float = -rad_to_deg(get_local_mouse_position().angle_to(Vector2.UP))
	right_arm_target_angle = (mouse_angle - 20)/2
	
	right_arm.rotation_degrees = lerp(right_arm.rotation_degrees,right_arm_target_angle,delta* arm_move_speed)

	
