extends Camera3D

@export var follow_speed: float = 10.0
var target_node: Node3D

func _ready():
	# Отвязываем камеру от локальных трансформаций игрока, 
	# чтобы она не крутилась, если игрок повернется
	top_level = true 
	target_node = get_parent()
	global_position = target_node.global_position

func _process(delta):
	if is_instance_valid(target_node):
		# Плавное следование за игроком
		global_position = global_position.lerp(target_node.global_position, delta * follow_speed)
