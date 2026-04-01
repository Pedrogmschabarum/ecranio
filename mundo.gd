extends Node2D

var score = 0

@onready var score_label = $ScoreLabel

func add_score(value):
	score += value
	print("SCORE:", score)
	score_label.text = "Score: " + str(score)

func reset_score():
	score = 0
	score_label.text = "Score: 0"
