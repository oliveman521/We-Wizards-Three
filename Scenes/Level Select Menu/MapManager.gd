@tool
extends Control
class_name MapManager

@export var line_color: Color

var all_map_nodes: Array[MapNode]:
	get:
		var map_nodes: Array[MapNode] = []
		for mn in get_children():
			if mn is MapNode:
				map_nodes.append(mn as MapNode)
		return map_nodes

func redraw_all_map_nodes() -> void:
	for mn: MapNode in all_map_nodes:
		mn.queue_redraw()

func get_map_node_by_id(id: String) -> MapNode:
	for map_node: MapNode in all_map_nodes:
		if map_node.id == id:
			return map_node
	print("Failed to find map node of ID ", id)
	return null

	
