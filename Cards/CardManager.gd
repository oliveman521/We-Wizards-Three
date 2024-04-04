extends Node2D
class_name CardManager

@export var starting_cards_count: int = 3
var card_pool: Array[Card] = []

@onready var queue_of_cards: Node = $Queue
@onready var hand_of_cards: Node = $Hand
@onready var card_spawn_point: Node2D = $"Card Spawn Point"

@onready var hand_card_anchors: Array[Node] = $"Hand/Hand Anchors".get_children()

@onready var ongoing_abilities_region: HBoxContainer = %"Ongoing Abilities"
@onready var card_draw_sound: AudioStreamPlayer2D = $"Card Draw Sound"




var max_hand_size: int:
	get: return hand_card_anchors.size()

var cards_in_hand : Array[Card]:
	get: return get_children_that_are_cards(hand_of_cards)

var cards_in_deck: Array[Card]

signal card_played(card:Card)
signal card_discarded(card:Card)


static var instance: CardManager

func _ready() -> void:
	instance = self
	for scene: PackedScene in GameManager.current_save.cards_in_deck:
		cards_in_deck.append(scene.instantiate() as Card)
	
	for i in range(starting_cards_count):
		draw_random_card()


func add_ongoing_ability(ongoing_ability_prefab: PackedScene, amnt: float) -> void:
	var new_ability: OngoingAbility = ongoing_ability_prefab.instantiate() as OngoingAbility
	new_ability.id = ongoing_ability_prefab.resource_path
	var existing_ability: OngoingAbility = null
	for node: Node in ongoing_abilities_region.get_children():
		if node is OngoingAbility:
			var ability: OngoingAbility = node as OngoingAbility
			if ability.id == new_ability.id:
				existing_ability = ability
				break
	
	if not existing_ability: #If the ability doesn't yet exist
		ongoing_abilities_region.add_child(new_ability)
		new_ability.count = amnt
		return
	
	if new_ability.stack_behavior == "Independent":
		ongoing_abilities_region.add_child(new_ability)
		new_ability.count = amnt
	else:
		existing_ability.another_one(amnt)

func get_children_that_are_cards(node: Node) -> Array[Card]:
	var cards: Array[Card] = []
	for c in node.get_children():
		if c is Card:
			cards.append(c as Card)
	return cards

func random_card_from_deck() -> Card:
	if len(cards_in_deck) == 0:
		print("no cards left in deck")
		return null
	cards_in_deck.shuffle()
	return cards_in_deck.pop_at(0)

func draw_random_card() -> void:
	var new_card: Card = random_card_from_deck() as Card

	if new_card == null:
		print("Deck is empty. Draw failed. TODO this shouldn't be possible")
		#TODO graphic
		return
	
	SoundManager.play_sound(card_draw_sound)
	add_child(new_card)
	new_card.global_position = card_spawn_point.global_position
	
	new_card.reparent(hand_of_cards)
	arrange_cards_in_playspace()


func arrange_cards_in_playspace() -> void:
	if !is_inside_tree(): return #this function normally triggers when nodes are rearranged. Since this happens whenever the scene is unloaded, this fires when the scene is unloading, so we should skip it if we're currently unloading
	
	var queue_pos: Vector2 = queue_of_cards.global_position
	const queue_span:= Vector2(100,100)
	
	for i in range(cards_in_hand.size()):
		var card: Card = cards_in_hand[i]
		var target_pos: Vector2
		card.modulate = Color(1,1,1,1) #Dumb fix because the cards are somtimes transparent when they get re-added to deck. TODO fix this
		if i < hand_card_anchors.size():
			target_pos = hand_card_anchors[i].global_position
			card.enter_hand_mode()
		else:
			var card_step: Vector2 = queue_span/(cards_in_hand.size() - max_hand_size)
			card.enter_queue_mode()
			target_pos = queue_pos
			queue_pos += card_step
		card.move_center_to(target_pos)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_mode"):
		draw_random_card()
