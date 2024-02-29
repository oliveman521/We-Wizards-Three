extends Control
class_name  OngoingAbility


@export var passive_ability_tag: GameManager.Passive_Ability_Tag = GameManager.Passive_Ability_Tag.NONE
@export var tool_tip: String = "This is not yet implimented" #TODO impliment this
var id: String

@export_enum("Add", "Multiply", "Reset Timer", "Independent") var stack_behavior: String = "Add"


@export_group("Timed Ability")
@export var timed: bool = false
@export var time: float = 3 
@export var one_shot: bool = false

@onready var progress_bar: ProgressBar = $"Progress Bar" as ProgressBar
@onready var timer: Timer = $"Progress Bar/Timer"
@onready var effects_collection: Node = %"Timeout Effects"



var count: float = 1:
	set(new_val):
		count = new_val
		var count_disp: Label = %Count as Label
		if count == 1:
			count_disp.visible = false
		else:
			var txt: String = str(count)
			if stack_behavior == "Multiply":
				txt = "x" + txt
			count_disp.text = txt
			count_disp.visible = true

func another_one(amnt: float = 1) -> void:
	#https://www.youtube.com/watch?v=fYpx8oDMQBU
	if stack_behavior == "Add":
		count += amnt
	elif stack_behavior == "Multiply":
		count *= amnt
	elif stack_behavior == "Reset Timer":
		timer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count = 1
	if timed:
		timer.wait_time = time
		timer.start()
		timer.timeout.connect(func() -> void:
			if one_shot:
				execute_effects()
				queue_free()
			else:
				for i in range(count):
					execute_effects()
			)
			
	else:
		progress_bar.visible = false

func execute_effects() -> void:
	for node: Node in effects_collection.get_children():
		if node.has_method("use_effect"):
			node.use_effect()

func _process(_delta: float) -> void:
	if timed:
		progress_bar.max_value = time
		progress_bar.value = timer.wait_time - timer.time_left
