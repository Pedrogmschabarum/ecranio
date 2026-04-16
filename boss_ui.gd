extends CanvasLayer

@onready var barra = $BossUI/ProgressBar

func atualizar_vida(vida_atual: int, vida_max: int):
	barra.max_value = vida_max
	barra.value = vida_atual
