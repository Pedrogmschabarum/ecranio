extends Node2D

@export var enemy_scene = preload("res://atores/inimigo.tscn")

signal horda_finalizada

@export var spawn_interval: float = 3.0
@export var score_por_inimigo: int = 10

var timer: Timer
var inimigos_vivos: int = 0
var score_horda: int = 0
var meta_score_horda: int = 0
var spawn_parado_por_meta: bool = false

func _ready():
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(spawn_enemy)
	timer.start()

func set_spawn_interval(seconds: float) -> void:
	spawn_interval = max(0.1, seconds)
	if timer != null:
		timer.wait_time = spawn_interval

func iniciar_horda(nova_meta_score: int) -> void:
	meta_score_horda = max(0, nova_meta_score)
	score_horda = 0
	spawn_parado_por_meta = false
	_avaliar_para_parar_spawn()

	if not spawn_parado_por_meta and timer.is_stopped():
		timer.start()

func atualizar_score_horda(novo_score_horda: int) -> void:
	score_horda = max(0, novo_score_horda)
	_avaliar_para_parar_spawn()

func spawn_enemy():
	if spawn_parado_por_meta:
		return

	_avaliar_para_parar_spawn()
	if spawn_parado_por_meta:
		return

	var enemy = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemy)
	enemy.global_position = Vector2(200, 249)

	inimigos_vivos += 1   # <-- CONTA O INIMIGO

	enemy.morreu.connect(_on_enemy_morreu)   # <-- CONECTA SIGNAL
	
	_avaliar_para_parar_spawn()
	
func _on_enemy_morreu():
	inimigos_vivos -= 1

	if inimigos_vivos <= 0:
		print("Todos os inimigos morreram!")
		# aqui você pode iniciar nova wave, abrir porta, etc.
		if score_horda >= meta_score_horda:
			horda_finalizada.emit()

	_avaliar_para_parar_spawn()

func parar_spawner():
	timer.stop()

func _avaliar_para_parar_spawn() -> void:
	if meta_score_horda <= 0:
		return

	var restante: int = max(0, meta_score_horda - score_horda)
	if restante <= 0:
		spawn_parado_por_meta = true
		if not timer.is_stopped():
			parar_spawner()
		return

	var inimigos_necessarios: int = int(ceil(float(restante) / float(max(1, score_por_inimigo))))
	var deve_parar: bool = inimigos_vivos >= inimigos_necessarios
	spawn_parado_por_meta = deve_parar

	# Importante: isso precisa ser dinâmico.
	# Se o player matar inimigos antes de bater a meta, voltamos a spawnar.
	if deve_parar:
		if not timer.is_stopped():
			parar_spawner()
	else:
		if timer.is_stopped():
			timer.start()
