extends Node2D
class_name StoreroomManager

@onready var storeroom_tile_map: TileMap = %"Storeroom Tile Map"

func _ready() -> void:
	GameManager.storeroomManager = self

func load_new_layout(new_layout: Node2D) -> void:
	if storeroom_tile_map:
		storeroom_tile_map.queue_free()
	storeroom_tile_map = new_layout.duplicate()
	add_child(storeroom_tile_map)
