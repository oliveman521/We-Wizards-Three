extends Node2D
class_name EnemyManager


const FEED_RATE: float = 50

@onready var enemy_feed_tape: Node2D = $"Test Feed Tape" #gets replaced when level is loaded propporly

@onready var enemy_spawn_area: CollisionShape2D = %"Enemy Spawn Area"


var rng := RandomNumberGenerator.new()

static var max_y: float
static var min_y: float


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

func spawn_enemy(enemy_prefab: PackedScene) -> void:
	var new_enemy: Enemy = enemy_prefab.instantiate() as Enemy
	
	var rect_pos := enemy_spawn_area.get_global_position()
	var rect_size := enemy_spawn_area.shape.get_rect().size
	
	var x_spawn := rect_pos.x - rect_size.x/2
	var y_spawn_min := rect_pos.y + rect_size.y/2
	var y_spawn_max := rect_pos.y - rect_size.y/2
	new_enemy.global_position = Vector2(x_spawn, randf_range(y_spawn_min,y_spawn_max))
	add_child(new_enemy)
	new_enemy.activate()

var inactive_enemies: Array[Enemy]:
	get:
		var en: Array[Enemy] = []
		for i in enemy_feed_tape.get_children():
			if i is Enemy:
				en.append(i as Enemy)
		return en


func _ready() -> void:
	max_y = enemy_spawn_area.get_global_position().y + enemy_spawn_area.shape.get_rect().size.y/2
	min_y = enemy_spawn_area.get_global_position().y - enemy_spawn_area.shape.get_rect().size.y/2
	
	GameManager.enemy_manager = self as EnemyManager
	

func _process(delta: float) -> void:
	var feed_mult: float = 1
	if Input.is_key_pressed(KEY_P):
		feed_mult = 5
		
	
	#TODO both advancing the feedtape and checking for victory are pretty needlessly expensive
	#Advanceing the feed tape
	enemy_feed_tape.global_position.x += delta * FEED_RATE * feed_mult 
	
	if len(active_enemies) == 0 && len(inactive_enemies) == 0:
		GameManager.level_won()
