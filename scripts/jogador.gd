extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DAMAGE_COOLDOWN = 1.0
const KNOCKBACK_X = 250.0
const KNOCKBACK_Y = -200.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

var is_jumping := false
var health := 3
var can_take_damage := true
var is_dead: bool = false
var is_attacking: bool = false
var is_blocking: bool = false
var facing: float = 1.0

func _ready() -> void:
	add_to_group("player")
	attack_collision.disabled = true
	attack_area.body_entered.connect(_on_attack_area_body_entered)

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Verifica se o personagem morreu	
	if is_player_dead():
		move_and_slide()
		return
	
	
	# Ataque
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dead:
		attack()
	if is_attacking:
		velocity.x = 0.0
		move_and_slide()
		return
		
	# Bloqueio
	is_blocking = Input.is_action_pressed("block") and not is_dead and not is_attacking
	if is_blocking:
		velocity.x = 0.0
		animation.play("block")
		move_and_slide()
		return	
		
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
	WrapManager.wrap_node(self)

func take_damage(amount: int, enemy_position: Vector2) -> void:
	if not can_take_damage or is_dead:
		return

	if is_blocking:
		print("Ataque bloqueado!")
		return

	health -= amount
	can_take_damage = false

	print("Tomou dano! Vida atual: ", health)

	var direction: float = sign(global_position.x - enemy_position.x)
	if direction == 0.0:
		direction = 1.0

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	animation.modulate.a = 0.5

	if health <= 0:
		die()
		return

	await get_tree().create_timer(DAMAGE_COOLDOWN).timeout
	can_take_damage = true
	animation.modulate.a = 1.0
	
	
func is_player_dead():
	return is_dead

func die() -> void:
	if is_player_dead():
		return

	is_dead = true
	velocity.x = 0.0
	animation.play("dead")

	await animation.animation_finished


#region Funcoes de ataque
func attack() -> void:
	is_attacking = true
	velocity.x = 0.0
	animation.play("attack1")

	attack_collision.disabled = false
	await get_tree().create_timer(0.15).timeout
	attack_collision.disabled = true

	await animation.animation_finished
	is_attacking = false

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1, global_position)
	
#endregion
