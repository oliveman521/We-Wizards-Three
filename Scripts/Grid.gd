@tool
extends Node2D
class_name Grid


const cell_size := Vector2(64,64)
const dimensions_pixels: Vector2 = Vector2(896,512)
const size_cells: Vector2i = dimensions_pixels / cell_size

var grid_color := Color(255,255,255, 0.14) 
var grid_line_width: float = 3

var _half_cell_size: Vector2:
	get: return cell_size/2

func _draw() -> void:
	draw_grid()

func get_random_dir() -> Vector2:
		return [Vector2(0,1),
		Vector2(1,0),
		Vector2(0,-1),
		Vector2(-1,0)].pick_random()

func cell_to_world_pos(cell_coordinates: Vector2) -> Vector2:
	return cell_coordinates * cell_size + _half_cell_size + global_position

func cell_to_local_pos(cell_coordinates: Vector2) -> Vector2:
	return cell_coordinates * cell_size + _half_cell_size
	
func world_pos_to_cell_center(world_position: Vector2) -> Vector2:
	return ((world_position - global_position) / cell_size).floor()

func world_pos_to_cell_space(world_position: Vector2) -> Vector2:
	return ((world_position - global_position) / cell_size)

func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var in_x := cell_coordinates.x >= 0 and cell_coordinates.x < size_cells.x
	var in_y := cell_coordinates.y >= 0 and cell_coordinates.y < size_cells.y
	return in_x and in_y

func get_random_cell() -> Vector2:
	return Vector2(randi_range(0,size_cells.x-1), randi_range(0,size_cells.y-1))

func draw_grid() -> void: 
	#verical lines
	for xi in range(size_cells.x + 1):
		var start := Vector2(xi * cell_size.x, 0)
		var end := Vector2(xi * cell_size.x, cell_size.y * size_cells.y)
		#note. These are drawn relative to this node, so they don't need to be offset by startpoint
		draw_line(start, end, grid_color, grid_line_width)
	
	#horizontal Lines
	for yi in range(size_cells.y + 1):
		var start := Vector2(0, yi * cell_size.y)
		var end := Vector2(cell_size.x * size_cells.x ,yi * cell_size.y)
		#note. These are drawn relative to this node, so they don't need to be offset by startpoint
		draw_line(start, end, grid_color, grid_line_width)
