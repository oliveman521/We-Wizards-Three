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

func _ready() -> void:
	background_color_UI.color = card_type_color_dict[card_type]
	card_name = card_name

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

var deck_building_mode: bool = false

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

func get_supply_costs() -> Array[Supply]:
	var costs: Array[Supply] = []
	for node: Node in costs_UI_section.get_children():
		if node is CardSupplyIcon:
			node = node as CardSupplyIcon
			for i in range(node.count):
				costs.append(node.supply)
	return costs

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
	button.disabled = true
	card_back.visible = true

func enter_hand_mode() -> void:
	button.disabled = false
	card_back.visible = false

func enter_preview_mode() -> void:
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_button_gui_input(event: InputEvent) -> void:
	if !(event is InputEventMouseButton): return
	if not event.pressed: return
	
	#Don't do shit if we scrolling
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
		return
	
	card_pressed.emit()
	
	if deck_building_mode && event.button_index == MOUSE_BUTTON_LEFT:
		SoundManager.play_sound(discard_sound)		
		if in_deck:
			slide_card_away(Vector2.LEFT, Color(0,0,1,0))
		else:
			slide_card_away(Vector2.RIGHT, Color(0,0,1,0))
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

@onready var multiples_indicator: Control = %"Multiples Indicator"
@onready var multiples_number: Label = %"Multiples Number"
var in_deck: bool = false;
signal card_pressed

func enter_deck_building_mode(count: int, card_in_deck: bool) -> void:
	self.in_deck = card_in_deck
	deck_building_mode = true
	if count > 1:
		multiples_indicator.visible = true
		multiples_number.text = str(count)

const SLIDE_DISTANCE: = 100
const MOVE_TIME: = .25

func move_center_to(target_pos: Vector2) -> void:
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "center_position", target_pos, MOVE_TIME).set_trans(Tween.TRANS_SINE)
	await tween.finished

func slide_card_away(dir: Vector2, color: Color = Color(0,0,0,0)) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE #make sure we can't detect more inputs
	var target_pos: Vector2 = center_position + dir * SLIDE_DISTANCE
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "modulate", color, MOVE_TIME).set_trans(Tween.TRANS_SINE)
	await move_center_to(target_pos)
	button.mouse_filter = Control.MOUSE_FILTER_PASS #TODO This should probably be changed. RN this is setting the mouse filter back so that if the card is to be added to the deck it'll still be clickable, but I think the whole deck data management needs to be reworked
