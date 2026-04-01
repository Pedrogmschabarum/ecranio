extends Node2D

@export var enemy_scene = preload("res://atores/inimigo.tscn")

var timer

func _ready():
	timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(spawn_enemy)
	timer.start()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemy)

	enemy.global_position = Vector2(200, 249)
