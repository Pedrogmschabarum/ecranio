extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DAMAGE_COOLDOWN = 1.0
const KNOCKBACK_X = 250.0
const KNOCKBACK_Y = -200.0

@onready var animation := $AnimatedSprite2D as AnimatedSprite2D

var is_jumping := false
var health := 3
var can_take_damage := true
var is_dead: bool = false

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Movimento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.scale.x = direction

		if is_jumping:
			animation.play("jump")
		else:
			animation.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		if is_jumping:
			animation.play("jump")
		else:
			animation.play("idle")

	move_and_slide()

	# Detecta colisão com inimigo
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider != null and collider.is_in_group("enemies"):
			take_damage(1, collider.global_position)

func take_damage(amount: int, enemy_position: Vector2) -> void:
	if not can_take_damage:
		return

	health -= amount
	can_take_damage = false

	print("Tomou dano! Vida atual: ", health)

	# Knockback
	var direction: float = sign(global_position.x - enemy_position.x)
	if direction == 0:
		direction = 1

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	# Efeito visual simples
	animation.modulate.a = 0.5

	if health <= 0:
		die()
		return

	await get_tree().create_timer(DAMAGE_COOLDOWN).timeout
	can_take_damage = true
	animation.modulate.a = 1.0

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	animation.play("dead")

	await animation.animation_finished
