extends CharacterBody2D

const SPEED = 140.0
const DAMAGE_COOLDOWN = 0.4
const KNOCKBACK_X = 180.0
const KNOCKBACK_Y = -120.0
const ATTACK_DAMAGE = 1
const BLOCK_KNOCKBACK_X = 260.0
const BLOCK_KNOCKBACK_Y = -80.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_range: Area2D = $AttackRange
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D = null
var health: int = 10
var can_take_damage: bool = true
var is_dead: bool = false
var is_attacking: bool = false
var player_in_range: bool = false
var facing: float = 1.0
var knockback_time_left: float = 0.0

func _ready() -> void:
	add_to_group("enemies")

	player = get_tree().get_first_node_in_group("player") as Node2D

	attack_range.area_entered.connect(_on_attack_range_area_entered)
	attack_range.area_exited.connect(_on_attack_range_area_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	attack_timer.wait_time = 2.0
	attack_timer.one_shot = false

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Se morreu, só cai/chão e acabou
	if is_dead:
		velocity.x = 0.0
		move_and_slide()
		return

	# Se não achou player, para
	if player == null:
		velocity.x = 0.0
		animation.play("idle")
		move_and_slide()
		return

	# Se o player morreu, inimigo para
	if player.has_method("is_player_dead") and player.is_player_dead():
		velocity.x = 0.0
		animation.play("idle")
		move_and_slide()
		return

	# Knockback tem prioridade sobre qualquer ação (inclusive ataque)
	if knockback_time_left > 0.0:
		knockback_time_left = maxf(0.0, knockback_time_left - delta)
		move_and_slide()
		WrapManager.wrap_node(self)
		return

	# Sempre vira para o player
	update_facing()

	# Se estiver atacando, não anda
	if is_attacking:
		velocity.x = 0.0
		move_and_slide()
		return

	# Se player estiver no alcance, para e espera o timer de ataque
	if player_in_range:
		velocity.x = 0.0
		animation.play("idle")
		move_and_slide()
		return

	# Senão, persegue
	var direction: float = sign(player.global_position.x - global_position.x)
	velocity.x = direction * SPEED

	if direction != 0.0:
		animation.play("run")
	else:
		animation.play("idle")

	move_and_slide()
	WrapManager.wrap_node(self)

func update_facing() -> void:
	if player == null:
		return

	var direction: float = sign(player.global_position.x - global_position.x)
	if direction != 0.0:
		facing = direction
		animation.scale.x = direction

func take_damage(amount: int, attack_position: Vector2) -> void:
	if not can_take_damage or is_dead:
		return

	health -= amount
	can_take_damage = false

	print("Inimigo tomou dano! Vida atual: ", health)

	var direction: float = sign(global_position.x - attack_position.x)
	if direction == 0.0:
		direction = 1.0

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	animation.modulate.a = 0.5

	if health <= 0:
		die()
		return

	var t := get_tree().create_timer(DAMAGE_COOLDOWN)
	t.timeout.connect(func() -> void:
		can_take_damage = true
		animation.modulate.a = 1.0
	)

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity.x = 0.0
	attack_timer.stop()
	animation.play("dead")

	await animation.animation_finished

	var world = get_tree().get_first_node_in_group("world")

	if world and world.has_method("add_score"):
		world.add_score(25)

	queue_free()
#region Funcoes de ataque
func attack() -> void:
	if is_dead:
		return

	if player == null:
		return

	if player.has_method("is_player_dead") and player.is_player_dead():
		return

	is_attacking = true
	velocity.x = 0.0
	update_facing()
	animation.play("attack1")

	# Momento do hit
	await get_tree().create_timer(0.15).timeout

	if player_in_range and player != null and player.has_method("take_damage"):
		var bloqueou: bool = player.take_damage(ATTACK_DAMAGE, global_position)
		if bloqueou:
			_aplicar_knockback_bloqueio()

	await animation.animation_finished
	is_attacking = false

func _aplicar_knockback_bloqueio() -> void:
	# Recuo ao ter ataque bloqueado
	if player == null:
		return
	var direction: float = sign(global_position.x - player.global_position.x)
	if direction == 0.0:
		direction = 1.0
	velocity.x = direction * BLOCK_KNOCKBACK_X
	velocity.y = BLOCK_KNOCKBACK_Y
	knockback_time_left = 0.18

func _on_attack_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		player_in_range = true
		var p := area.get_parent()
		if p is Node2D:
			player = p

		if attack_timer.is_stopped():
			attack_timer.start()

func _on_attack_range_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		player_in_range = false
		attack_timer.stop()

func _on_attack_timer_timeout() -> void:
	if player_in_range and not is_attacking and not is_dead:
		await attack()

#endregion
