extends CharacterBody3D

class_name Player

@onready var sprite = $Sprite3D

const SPEED = 5.0
var health = 5
var current_dir = "front" # Направление по умолчанию
var is_locked = false # Блокировка действий (для стана, атаки, смерти)

# ==========================================
# ЗДЕСЬ МОЖНО ПОМЕНЯТЬ ВРЕМЯ ПРОИГРЫВАНИЯ АНИМАЦИЙ (в секундах)
const TIME_ATTACK = 1.0       # Время атаки
const TIME_TAKE_DAMAGE = 0.25 # Время стана от урона
const TIME_DEATH = 1.0        # Время анимации смерти
# ==========================================

func _physics_process(_delta):
	if is_locked:
		# Если мертв, получаем урон или атакуем - стоим на месте
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Атака
	if Input.is_action_just_pressed("attack"):
		perform_attack()
		return

	# Получаем нажатия клавиш
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		update_direction_string(direction)
		sprite.play("run_" + current_dir)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		sprite.play("idle_" + current_dir)

	move_and_slide()

# Вычисление направления для анимации
func update_direction_string(dir: Vector3):
	if abs(dir.x) > abs(dir.z):
		current_dir = "right" if dir.x > 0 else "left"
	else:
		# В 3D ось Z направлена "на нас", поэтому Z > 0 это движение назад (от камеры)
		current_dir = "back" if dir.z < 0 else "front"

func perform_attack():
	is_locked = true
	sprite.play("attack_" + current_dir)
	
	# ТУТ МОЖНО ДОБАВИТЬ ЛОГИКУ НАНЕСЕНИЯ УРОНА ВРАГАМ (RayCast или Area3D)
	
	await get_tree().create_timer(TIME_ATTACK).timeout # Ждем время атаки
	if health > 0:
		is_locked = false

# Эту функцию должны вызывать враги, когда бьют игрока
func take_damage():
	if is_locked and health <= 0: return # Если уже мертв
	
	health -= 1
	is_locked = true
	
	if health <= 0:
		die()
	else:
		sprite.play("takeDamage_" + current_dir)
		await get_tree().create_timer(TIME_TAKE_DAMAGE).timeout # Ждем время стана
		is_locked = false

func die():
	is_locked = true
	sprite.play("death_" + current_dir)
	await get_tree().create_timer(TIME_DEATH).timeout
	# Действия после смерти (например, рестарт сцены или Game Over)
	print("Игрок умер")
