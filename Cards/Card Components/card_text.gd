@tool

extends Label
class_name card_text


@export_enum("None", "Draw Blue", "Negative Red", "Exhaust") var preset: String = "None":
	set(new_val):
		preset = new_val
		match preset:
			"None":
				modulate = Color.BLACK
			"Draw Blue":
				modulate = Color("#004e8a")
			"Negative Red":
				modulate = Color("#ab1f00")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
