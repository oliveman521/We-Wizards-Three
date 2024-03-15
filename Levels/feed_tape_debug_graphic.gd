@tool
extends Node2D

const FEED_RATE: float = 50

func _ready() -> void:
	if not Engine.is_editor_hint():
		GameManager.debug_mode_changed.connect(queue_redraw)

func _draw() -> void:
	#don't draw if the game is running and we aren't in debug mode
	if not Engine.is_editor_hint() && not GameManager.debug_mode: return
	
	const LINE_LENGTH: int = 100000
	const EDGE_BUFFER: int = 100
	const minor_tick_marks_seconds:float = 10
	const major_tick_marks_seconds:float = 60

	var top: int = 0
	var bottom: int = 1080
	
	#absolute borders
	draw_line(Vector2(0,top),Vector2(-LINE_LENGTH,top),Color.RED,5)
	draw_line(Vector2(0,bottom),Vector2(-LINE_LENGTH,bottom),Color.RED, 5)
	
	#Edge Buffers. Don't usually put enemies past this line
	draw_line(Vector2(0,top + EDGE_BUFFER),Vector2(-LINE_LENGTH,top+ EDGE_BUFFER),Color.WHITE,5)
	draw_line(Vector2(0,bottom - EDGE_BUFFER),Vector2(-LINE_LENGTH,bottom- EDGE_BUFFER),Color.WHITE, 5)
	
	#tick Marks
	var major_tick_mark_incriment:float = major_tick_marks_seconds * FEED_RATE
	var minor_tick_mark_incriment:float = minor_tick_marks_seconds * FEED_RATE
	
	var tick_color: Color = Color(1,1,1,0.1)
	
	for tick_x:int in range(0,-LINE_LENGTH,-minor_tick_mark_incriment):
		draw_line(Vector2(tick_x,top),Vector2(tick_x,bottom),tick_color,15)
	
	var font := load("res://UI/Fonts/Franklin Gothic Medium Regular.ttf")
	var i: int = 0
	for tick_x:int in range(0,-LINE_LENGTH,-major_tick_mark_incriment):
		draw_line(Vector2(tick_x,top),Vector2(tick_x,bottom),tick_color,30)
		draw_string(font, Vector2(tick_x,top + 100), str(i) + " min",HORIZONTAL_ALIGNMENT_LEFT,300,100)
		i += 1
	
	
