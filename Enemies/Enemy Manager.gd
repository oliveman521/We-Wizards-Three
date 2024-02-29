extends Node2D
class_name EnemyManager


const FEED_RATE: float = 50

@onready var enemy_feed_tape: Node2D = $"Test Feed Tape" #gets replaced when level is loaded propporly

var rng := RandomNumberGenerator.new()


var active_enemies: Array[Enemy]:
	get:
		var en: Array[Enemy] = []
		for i in get_children():
			if i is Enemy:
				if i.active == false:
					print("inactive enemy detected under the wrong parent.")
				en.append(i as Enemy)
		return en

func load_feed_tape(feed_tape: Node2D) -> void:
	if enemy_feed_tape != null: #clear old feedtape
		enemy_feed_tape.queue_free()
	enemy_feed_tape = feed_tape.duplicate()
	add_child(enemy_feed_tape)


var inactive_enemies: Array[Enemy]:
	get:
		var en: Array[Enemy] = []
		for i in enemy_feed_tape.get_children():
			if i is Enemy:
				en.append(i as Enemy)
		return en


func _ready() -> void:
	GameManager.enemy_manager = self as EnemyManager

func _process(delta: float) -> void:
	var feed_mult: float = 1
	if Input.is_key_pressed(KEY_P):
		feed_mult = 5
	enemy_feed_tape.global_position.x += delta * FEED_RATE * feed_mult
	
	if len(active_enemies) == 0 && len(inactive_enemies) == 0:
		#no enemies remain
		GameManager.level_won()
