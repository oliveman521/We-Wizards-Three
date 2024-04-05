extends CardEffect
class_name CardEffect_GainSupplies

@export var type: Supply 

@export_enum("Plus", "Times") var gain_type: String = "Plus"
@export var gain_amnt:int = 1

func use_effect() -> void:
	if gain_type == "Plus":
		type.add_supply(gain_amnt)
	elif gain_type == "Times":
		type.add_supply(type.supply_count * (gain_amnt-1))
	else:
		print("Something Went Wrong in gain effect")
