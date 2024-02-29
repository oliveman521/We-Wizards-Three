@tool
extends Node

func get_all_children(in_node: Node, arr:Array[Node]=[]) -> Array[Node]:
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

@export var redraw_card: bool:
	set(new_val):
		var card: Card = $".." as Card
		card.queue_redraw()
		#for node: Node in get_all_children(card):
		#	node.queue_redraw()
