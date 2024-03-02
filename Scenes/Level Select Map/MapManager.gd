@tool
extends Control
class_name MapManager

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


