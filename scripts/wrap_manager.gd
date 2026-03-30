extends Node

var world_width: float = 640
var world_height: float = 320
var wrap_margin: float = 32.0

func wrap_node(node: Node2D) -> void:
	if node.global_position.x > world_width + wrap_margin:
		node.global_position.x = -wrap_margin
	elif node.global_position.x < -wrap_margin:
		node.global_position.x = world_width + wrap_margin

	if node.global_position.y > world_height + wrap_margin:
		node.global_position.y = -wrap_margin
	elif node.global_position.y < -wrap_margin:
		node.global_position.y = world_height + wrap_margin
