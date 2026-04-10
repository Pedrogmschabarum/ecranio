extends Node2D

var score = 0

@onready var score_label = $ScoreLabel
@onready var spawner = $Spawner

func add_score(value):
	score += value
	print("SCORE:", score)
	score_label.text = "Score: " + str(score)
	
	# fazer condição para spawnar boss
	if score >= 100:
		#para de spawnar inimigo
		spawner.parar_spawner()
		#verifica se ainda tem inimigos em tela
		if get_tree().get_nodes_in_group("enemies").size() == 0:
			print("Não tem inimigos")
		#chama boss

func reset_score():
	score = 0
	score_label.text = "Score: 0"
