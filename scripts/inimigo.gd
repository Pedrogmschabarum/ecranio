extends CharacterBody2D

const SPEED = 140.0

var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player != null:
		var dx = player.global_position.x - global_position.x
		velocity.x = sign(dx) * SPEED
	else:
		velocity.x = 0.0

	move_and_slide()
