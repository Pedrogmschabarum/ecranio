extends Node2D

var score = 0
var score_horda: int = 0
var horda_atual: int = 1
var meta_score_horda: int = 0

@export var meta_inicial: int = 50
@export var incremento_meta: int = 25
@export var score_por_inimigo: int = 10

@export var spawn_interval_inicial: float = 3.0
@export var spawn_interval_reducao_por_horda: float = 0.1
@export var spawn_interval_minimo: float = 1.0

@onready var score_label = $ScoreLabel
@onready var spawner = $Spawner
@export var boss_scene: PackedScene = preload("res://atores/boss.tscn")

func _ready() -> void:
	_iniciar_horda(1)
	spawner.horda_finalizada.connect(_on_horda_finalizada)

func add_score(value):
	score += value
	print("SCORE:", score)
	score_horda += value
	score_label.text = "Score: " + str(score) + " | Horda " + str(horda_atual) + " (" + str(score_horda) + "/" + str(meta_score_horda) + ")"
	spawner.atualizar_score_horda(score_horda)

func reset_score():
	score = 0
	score_horda = 0
	score_label.text = "Score: 0"
	_iniciar_horda(1)

func _iniciar_horda(numero_horda: int) -> void:
	horda_atual = max(1, numero_horda)
	score_horda = 0
	meta_score_horda = max(1, meta_inicial + (horda_atual - 1) * incremento_meta)

	spawner.score_por_inimigo = score_por_inimigo
	var intervalo: float = maxf(
		float(spawn_interval_minimo),
		float(spawn_interval_inicial) - float(horda_atual - 1) * float(spawn_interval_reducao_por_horda)
	)
	spawner.set_spawn_interval(intervalo)
	spawner.iniciar_horda(meta_score_horda)

	score_label.text = "Score: " + str(score) + " | Horda " + str(horda_atual) + " (" + str(score_horda) + "/" + str(meta_score_horda) + ")"

func _on_horda_finalizada() -> void:
	# Evento de fim de horda (por enquanto só reinicia o ciclo)
	if (horda_atual < 2) :
		_iniciar_horda(horda_atual + 1)
	else:
		_iniciar_boss()
	

func _iniciar_boss() -> void:
	var boss = boss_scene.instantiate()
	
	# posição (ajusta como quiser)
	boss.global_position = Vector2(400, 200)
	
	get_tree().current_scene.add_child(boss)
	
	print("BOSS SPAWNADO!")
