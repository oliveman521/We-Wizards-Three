extends Node2D
class_name StoreroomManager

@onready var storeroom_tile_map: TileMap = %"Storeroom Tile Map"
@onready var pickup_spawner: Node2D = %"Pickup Spawner"
var pickup_prefab: PackedScene = preload("uid://5g7xihe0lyk3")

@export var available_supplies : Array[Supply]
@export var repeat_spawn_curve : Curve

var minimum_pickups: int = 12

var grid: Grid:
	get: return %Grid


func _ready() -> void:
	GameManager.storeroom_Manager = self

func load_new_layout(new_layout: Node2D) -> void:
	if storeroom_tile_map:
		storeroom_tile_map.queue_free()
	storeroom_tile_map = new_layout.duplicate()
	add_child(storeroom_tile_map)


var spawned_pickups: Array[Pickup]:
	get:
		var pickups: Array[Pickup] = []
		for pickup: Node2D in pickup_spawner.get_children():
			if pickup is Pickup:
				pickups.append(pickup as Pickup)
		return pickups

func how_many_of_supply_are_spawned(supply: Supply) -> int:
	var count: int = 0
	for pickup: Pickup in spawned_pickups:
		if pickup.supply_to_be_gained.resource_path == supply.resource_path:
			count += 1
	return count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pickup_spawner.get_children().size() < minimum_pickups:
		spawn_pickup()

func choose_random_pickup_type() -> Supply:
	#TODO Make this stip spawning cards if your deck is full
	var spawn_rate_dict: Dictionary = {}
	
	for supply: Supply in available_supplies:
		var spawn_rate: float = supply.pickup_spawn_rate
		if spawned_pickups.size() > 0:
			var percent_of_pickup_population: float = how_many_of_supply_are_spawned(supply) as float / spawned_pickups.size()
			spawn_rate *= repeat_spawn_curve.sample(percent_of_pickup_population)
		spawn_rate_dict[supply] = spawn_rate
	
	#sum of all entries
	var highest_roll: float = spawn_rate_dict.values().reduce(func(i: float, accum: float)-> float: return accum + i)
	var roll := randf_range(0,highest_roll)
	
	#for supply: Supply in spawn_rate_dict.keys():
	#	print(supply.spawn_rate , " modified spawn rate:  ", spawn_rate_dict[supply])
	
	var sum: float = 0
	for supply: Supply in spawn_rate_dict.keys():
		sum += spawn_rate_dict[supply]
		if roll <= sum:
			return supply
	
	#print(roll, " Sum: ", sum, " Max Roll: ", highest_roll)
	#print("failed to select a pickup to spawn")
	return null

func spawn_pickup() -> void:
	var pickup_type: Supply = choose_random_pickup_type() as Supply
	var new_pickup: Pickup = pickup_prefab.instantiate() as Pickup
	
	pickup_spawner.add_child(new_pickup)
	var cell = pick_vacant_cell()
	
	new_pickup.global_position = grid.cell_to_world_pos(cell)
	new_pickup.set_type_of_pickup(pickup_type, randi_range(pickup_type.pickup_count_min, pickup_type.pickup_count_max))

func spawn_snare() -> void:
	pass

func pick_vacant_cell() -> Vector2i:
	const min_cells_from_player = 2
	var min_dist_from_player: float = min_cells_from_player * grid.cell_size.x
	
	var cell: Vector2i
	for i in range(1000): #TODO this is bad
		cell = grid.get_random_cell()
		var cell_pos: Vector2 = grid.cell_to_world_pos(cell)
		var dist: float = cell_pos.distance_to(GameManager.apprentice_character.global_position)
		var player_too_close: bool = dist < min_dist_from_player
		
		var point: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		point.position = cell_pos
		point.collide_with_areas = true
		var hits := get_world_2d().direct_space_state.intersect_point(point)
		
		var cell_has_collider = hits.size() > 0
		
		if not player_too_close and not does_cell_have_pickup(cell) and not cell_has_collider:
			return cell
	
	return Vector2i(2,2)

func does_cell_have_pickup(cell_pos: Vector2) -> bool:
	for pickup: Pickup in spawned_pickups:
		if pickup.global_position == grid.cell_to_world_pos(cell_pos):
			return true
	return false
