extends Area2D
class_name Pickup

var supply_to_be_gained: Supply
var count_to_be_gained: int
@onready var card_supply_icon: MarginContainer = $"Card Supply Icon"
@onready var pickup_sound: AudioStreamPlayer2D = $"Pickup Sound"


func set_type_of_pickup(supply: Supply, count: int = 1) -> void:
	supply_to_be_gained = supply
	count_to_be_gained = count
	card_supply_icon.supply = supply
	card_supply_icon.count = count
