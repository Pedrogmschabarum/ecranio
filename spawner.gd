extends Node2D

@export var enemy_scene = preload("res://atores/inimigo.tscn")

var timer
var inimigos_vivos = 0 

func _ready():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(spawn_enemy)
	timer.start()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemy)
	enemy.global_position = Vector2(200, 249)

	inimigos_vivos += 1   # <-- CONTA O INIMIGO

	enemy.morreu.connect(_on_enemy_morreu)   # <-- CONECTA SIGNAL
	
	
func _on_enemy_morreu():
	inimigos_vivos -= 1

	if inimigos_vivos <= 0:
		print("Todos os inimigos morreram!")
		# aqui você pode iniciar nova wave, abrir porta, etc.
func parar_spawner():
	timer.stop()
