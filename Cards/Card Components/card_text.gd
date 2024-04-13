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


