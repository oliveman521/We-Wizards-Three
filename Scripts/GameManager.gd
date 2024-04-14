extends Node

enum Damage_Type{
	MANA,
	FIRE,
	LIGHTNING
}

#TODO delete these
const MANA: Ammo_Type = preload("uid://dfoqxs41hjlrc")
const FIRE: Ammo_Type = preload("uid://bow64ukpfnomj")
const LIGHTNING: Ammo_Type = preload("uid://0wqn3ujbcm2j")

var storeroom_Manager: StoreroomManager
var enemy_manager: EnemyManager

signal debug_mode_changed()
var debug_mode: bool = false:
	set(new_val):
		debug_mode = new_val
		debug_mode_changed.emit()

var lives: int = 0:
	set(new_value):
		lives = new_value
		if lives <= 0:
			game_over()

var all_supplies: Array[Supply] = [
	preload("uid://dgsybemasha7i"),
	preload("uid://dun667tokfc1l"),
	preload("uid://br1k5yssu1q83"),
	preload("uid://bow64ukpfnomj"),
	preload("uid://bb24w4yw0g0k"),
	preload("uid://0wqn3ujbcm2j"),
	preload("uid://dfoqxs41hjlrc"),
	preload("uid://bjgnfhrpwmh30"),
]

const DECK_MAX_SIZE: int = 15


var current_save: Resource  #FOR SOME REASON THIS HAS TO BE LOAD AND NOT PRELOAD AND I DON"T NO WHY SO LONG 4 HOURS OF MY LIFE IT WAS NICE KNOWING YA
var card_pool: Array[PackedScene] = []


const main_menu: PackedScene = preload("uid://dpdlppetxwu3m")
const level_select_scene: PackedScene = preload("uid://bpfb1n271ove4")
const game_scene: PackedScene = preload("uid://c4qnaj4cqxgny")
const deck_builder_scene: PackedScene = preload("res://Scenes/Menus/deck_builder_menu.tscn")

const SAVE_PATH: String = "user://save.tres"

func _ready() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH)
	else:
		setup_new_save()
	
	#on game boot, fill out our deck if its missing any cards
	for card_prefab: PackedScene in current_save.unlocked_cards:
		if current_save.cards_in_deck.size() >= DECK_MAX_SIZE:
			break
		current_save.cards_in_deck.append(card_prefab)

func setup_new_save() -> void:
	print("Resetting Save")
	current_save = load("uid://ds1jr58cmcm3j")
	save_game()

func save_game() -> void:
	ResourceSaver.save(current_save, SAVE_PATH)


var in_progress_level_prefab: PackedScene
var in_progress_level: LevelData

var level_about_to_begin: LevelData


func start_level(level_prefab: PackedScene) -> void:
	if in_progress_level_prefab != null:
		print("error. tried to start a level when one was already in progress")
		return
	
	in_progress_level_prefab = level_prefab
	in_progress_level = in_progress_level_prefab.instantiate() as LevelData
	level_about_to_begin = null
	
	#reset some values
	lives = 3
	for supply: Supply in all_supplies:
		supply.supply_count = 0
	
	#load the new scene in
	var level: LevelData = level_prefab.instantiate() as LevelData
	get_tree().change_scene_to_packed(game_scene)
	await get_tree().node_added #Singleton references should all connect by the end of ready
	await get_tree().current_scene.ready
	enemy_manager.load_feed_tape(level.enemy_feed_tape) #Load in the feed tape
	storeroom_Manager.load_new_layout(level.storeroom_tile_map)
	storeroom_Manager.available_supplies = level.supplies_present
	storeroom_Manager.minimum_pickups = level.supplies_spawned_at_once




func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_mode"):
		debug_mode = !debug_mode
	if Input.is_key_pressed(KEY_O):
		GameManager.level_won()
	if Input.is_action_just_pressed("full_screen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func spawn_popup(location: Vector2, message: String, color: Color = Color(1,1,1), lifetime:float = 1, parent: Node = self) -> void:
	const popup_prefab: Resource = preload("res://UI/popup_text.tscn")
	var new_popup_text: Label = popup_prefab.instantiate()
	parent.add_child(new_popup_text)
	new_popup_text.initialize(location, message, color, lifetime)


var end_sequence: bool = false
var transition_time: float = 1

func game_over() -> void:
	var level_failed_splash: PackedScene = preload("uid://dbl6hqacylj7")
	
	if debug_mode: 
		print("can't die in debug mode") 
		return 
	if end_sequence: return
	end_sequence = true
	print("you lose!")
	var msg: Control = level_failed_splash.instantiate()
	get_tree().current_scene.add_child(msg)
	msg.modulate = Color(1,1,1,0)
	var tween := get_tree().create_tween()
	tween.tween_property(msg, "modulate", Color(1,1,1,1), transition_time).set_trans(Tween.TRANS_SINE)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(level_select_scene)
	in_progress_level_prefab = null
	
	end_sequence = false


func level_won() -> void:
	if debug_mode == true: 
		return
	if end_sequence: return
	end_sequence = true
	
	#save the game whenever we win
	current_save.completed_levels.append(in_progress_level_prefab)
	save_game()
	
	var level_complete_splash: PackedScene = preload("uid://bhn3n3xw2vfd2")
	
	var msg: Control = level_complete_splash.instantiate()
	get_tree().current_scene.add_child(msg)
	msg.modulate = Color(1,1,1,0)
	var tween := get_tree().create_tween()
	tween.tween_property(msg, "modulate", Color(1,1,1,1), transition_time).set_trans(Tween.TRANS_SINE)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(level_select_scene)
	
	
	in_progress_level_prefab = null
	
	end_sequence = false

func get_passive_ability_count(ability_tag: String) -> float:
	var count: float = 0
	for node: Node in CardManager.instance.ongoing_abilities_region.get_children():
		if node is OngoingAbility:
			var ability: OngoingAbility = node as OngoingAbility
			if ability.passive_ability_tag == ability_tag:
				count+=ability.count
			if ability.consume == true:
				ability.queue_free()
				return count
	return count



