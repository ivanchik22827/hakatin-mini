extends CharacterBody3D

class_name Player

@onready var sprite = $Sprite3D
@onready var attack_shape = $AttackShape # <--- Ссылка на наш узел луча

const SPEED = 5.0
var health = 10
var current_dir = "front" 
var is_locked = false 
var is_invulnerable = false # Временная бессмертность
var face_direction = Vector3(0, 0, 1) # Куда мы сейчас смотрим
const ATTACK_RANGE = 1.0 # Дальность удара
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ==========================================
const TIME_ATTACK = 0.5       # Время атаки
const TIME_TAKE_DAMAGE = 0.2 # Время стана от урона
const TIME_DEATH = 1.0        # Время смерти
# ==========================================

func _physics_process(_delta):
	if not is_on_floor():
		velocity.y -= gravity * _delta
	
	if is_locked:
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
		
		# Поворачиваем луч атаки в ту сторону, куда идем
		face_direction = direction
		attack_shape.target_position = face_direction * ATTACK_RANGE
		
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
		current_dir = "back" if dir.z < 0 else "front"

# ==========================================
# ВОТ ТА САМАЯ ФУНКЦИЯ АТАКИ
# ==========================================
func perform_attack():
	sprite.play("attack_" + current_dir)
	is_locked = true
	
	# Небольшая задержка перед уроном (чтобы меч успел опуститься)
	await get_tree().create_timer(0.3).timeout 
	
	# Заставляем коробку обновиться прямо сейчас
	attack_shape.force_shapecast_update()
	
	if attack_shape.is_colliding(): 
		# Перебираем ВСЕХ, кто попал в нашу коробку (можно ударить толпу!)
		for i in attack_shape.get_collision_count():
			var target = attack_shape.get_collider(i)
			
			if target.has_method("take_damage"):
				target.take_damage()
				print("Размашистый удар по: ", target.name)
				
	await get_tree().create_timer(0.4).timeout 
	if health > 0:
		is_locked = false
		
# Получение урона игроком
func take_damage():
	# Если мы мертвы ИЛИ у нас активна неуязвимость - игнорируем удар
	if is_invulnerable or health <= 0: 
		return 
	
	health -= 1
	is_locked = true
	is_invulnerable = true # Включаем щит неуязвимости!
	
	if health <= 0:
		die()
	else:
		sprite.play("takeDamage_" + current_dir)
		
		# 1. Ждем время стана (TIME_TAKE_DAMAGE)
		await get_tree().create_timer(TIME_TAKE_DAMAGE).timeout
		is_locked = false # Стан прошел, ТЕПЕРЬ ТЫ МОЖЕШЬ БИТЬ
		
		# 2. Ждем еще полсекунды, пока враг машет руками сквозь нас
		await get_tree().create_timer(0.5).timeout 
		is_invulnerable = false # Неуязвимость спала, теперь снова можно получить урон

# Смерть игрока
func die():
	is_locked = true
	sprite.play("death_" + current_dir)
	await get_tree().create_timer(TIME_DEATH).timeout
	print("Игрок умер")
