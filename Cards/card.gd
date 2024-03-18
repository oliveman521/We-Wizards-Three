@tool
extends Control
class_name Card

@onready var button: Button = %Button
@onready var card_back: Control = %"Card Back"

@onready var card_name_UI: Label = %CardName
@onready var costs_UI_section: Control = %Costs
@onready var effects_UI_section: Control = %Effects
@onready var background_color_UI: ColorRect =  %"Background Color"

@onready var play_sound: AudioStreamPlayer2D = %"Play Sound"
@onready var discard_sound: AudioStreamPlayer2D = %"Discard Sound"
@onready var cannot_be_played_sound: AudioStreamPlayer2D = %"Cannot Be Played Sound"

@onready var highlight_ui: ColorRect = $Highlight
@onready var warning_ui: TextureRect = $Warning

var card_mode: String = "none"
const DECK_BUILDING_MODE = "DECK_BUILDING_MODE"
const HAND_MODE = "HAND_MODE"
const HAND_QUEUE_MODE = "HAND_QUEUE_MODE"
const PREVIEW_MODE = "PREVIEW_MODE"


@export_enum("Misc", "Draw", "Fire Damage", "Lightning Damage", "Crafting", "Buff") var card_type: String = "Misc":
	set(new_val):
		card_type = new_val
		if background_color_UI:
			background_color_UI.color = card_type_color_dict[card_type]
		queue_redraw()

#TODO mixed type cards would be kinda sick
var card_type_color_dict: Dictionary = {
	"Misc": Color("#3b097c"), 
	"Draw" : Color("#09117c"), 
	"Fire Damage": Color("#7c1b09"),
	"Lightning Damage": Color("#96901e"),	
	"Crafting": Color("#c79650"),
	"Buff": Color("#3a7c3e"),
}


signal card_played()
signal card_discarded()

@export var card_name: String:
	get:
		var file_name: String = scene_file_path.get_basename().split("/")[-1]
		file_name = file_name.replace("card_","")
		file_name = file_name.capitalize()
		name = file_name
		if card_name_UI:
			card_name_UI.text = file_name
		return file_name

var center_position: Vector2:
	get:
		return global_position + size/2
	set(new_value):
		global_position = new_value - size/2

var supplies_interacted_with: Array[Supply]:
	get:
		return []

var card_manager: CardManager:
	get: return GameManager.card_manager as CardManager


signal card_pressed

var exhausts_on_play: bool:
	get:
		for node: Node in effects_UI_section.get_children():
			if node.is_in_group("Exhaust"):
				return true
		return false

func check_costs() -> bool:
	for node: Node in costs_UI_section.get_children():
		if node.check_cost() == false:
			return false
	return true

func can_card_be_played_on_level(level_data: LevelData) -> bool:
	for supply: Supply in get_supply_costs():
		if !level_data.supplies_present.has(supply):
			return false
	return true

func get_supply_costs() -> Array[Supply]:
	var costs: Array[Supply] = []
	for node: Node in costs_UI_section.get_children():
		if node is CardSupplyIcon:
			node = node as CardSupplyIcon
			for i in range(node.count):
				costs.append(node.supply)
	return costs

func _ready() -> void:
	background_color_UI.color = card_type_color_dict[card_type]


func _process(_delta: float) -> void:
	if card_mode == HAND_MODE:
		if check_costs():
			highlight(Color.FOREST_GREEN)
		else:
			highlight_ui.visible = false
	if card_mode == DECK_BUILDING_MODE:
		if GameManager.level_about_to_begin:
			if can_card_be_played_on_level(GameManager.level_about_to_begin):
				highlight_ui.visible = false
			else:
				highlight(Color.RED)
		else:
			highlight_ui.visible = false


var num_in_collection: int:
	get:
		var count: int = 0
		for card_prefab: PackedScene in GameManager.current_save.unlocked_cards:
			if card_prefab.resource_path == scene_file_path:
				count += 1
		return count

func highlight(color: Color) -> void:
	highlight_ui.visible = true
	highlight_ui.modulate = color

func play() -> void:
	if not check_costs(): #TODO currently this is a double check and shouldn't be necessary
		print("!!!You can't play that card because it costs too much! This should never fire")
		return
	card_played.emit() 
	
	SoundManager.play_sound(play_sound)
	
	#Spend all the costs
	for node: Node in costs_UI_section.get_children():
		node.spend_cost()
	
	#activate all the effects
	for node: Node in effects_UI_section.get_children():
		if node.has_method("use_effect"):
			await node.use_effect()
	
	await slide_card_away(Vector2.UP, Color(0,1,0,0))
	#animate it flying away
	
	if exhausts_on_play: #return card to our deck as long as we aren't supposed to exhaust
		pass #TODO exhaust visual
	else:
		card_manager.cards_in_deck.append(self.duplicate()) #NOTE this duplicate is transparent cuz dumb reasons. This should be be fixed, but I'll add a quick note to make it full visible on arrangeing the playspace
	queue_free()

func enter_queue_mode() -> void:
	card_mode = HAND_QUEUE_MODE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	card_back.visible = true
	highlight_ui.visible = false

func enter_hand_mode() -> void:
	card_mode = HAND_MODE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	card_back.visible = false

func enter_preview_mode() -> void:
	card_mode = PREVIEW_MODE
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if num_in_collection == 0:
		highlight(Color.YELLOW)

@onready var multiples_indicator: HBoxContainer = %"Multiples Indicator"

func enter_deck_building_mode(count: int) -> void:
	card_mode = DECK_BUILDING_MODE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var multiples_number: Label = %"Multiples Number" as Label
	
	if count > 1:
		multiples_indicator.visible = true
		multiples_number.text = str(count)

func _on_button_gui_input(event: InputEvent) -> void:
	if !(event is InputEventMouseButton): return
	if not event.pressed: return
	
	#Don't do shit if we scrolling
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
		return
	
	card_pressed.emit()
	
	if card_mode == DECK_BUILDING_MODE:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		if check_costs(): #CARD IS BEING PLAYED
			play()
		else:
			GameManager.spawn_popup(center_position,"Not Enough Resources!",Color(1,0.8,.1))
			SoundManager.play_sound(cannot_be_played_sound)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		card_discarded.emit()
		SoundManager.play_sound(discard_sound)
		await slide_card_away(Vector2.DOWN, Color(1,0,0,0))
		card_manager.cards_in_deck.append(self.duplicate()) #TODO. This should somehow go back to the deck. Right now it's doing some christopher nolan's the prestige type shit
		queue_free()


const SLIDE_DISTANCE: = 100
const MOVE_TIME: = .25

func move_center_to(target_pos: Vector2, move_time: float = MOVE_TIME) -> void:
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "center_position", target_pos, move_time).set_trans(Tween.TRANS_SINE)
	await tween.finished

func slide_card_away(dir: Vector2, color: Color = Color(0,0,0,0), move_time: float = MOVE_TIME) -> void:
	
	if multiples_indicator.visible: #if we have a multiples indicator, leave it behind
		multiples_indicator.reparent(get_tree().root)
		tree_exiting.connect(multiples_indicator.queue_free)
	
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE #make sure we can't detect more inputs
	var target_pos: Vector2 = center_position + dir * SLIDE_DISTANCE
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "modulate", color, move_time).set_trans(Tween.TRANS_SINE)
	await move_center_to(target_pos, move_time)
	button.mouse_filter = Control.MOUSE_FILTER_PASS #TODO This should probably be changed. RN this is setting the mouse filter back so that if the card is to be added to the deck it'll still be clickable, but I think the whole deck data management needs to be reworked

