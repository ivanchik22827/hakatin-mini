extends CanvasLayer

# Ссылка на основной контейнер, который мы будем скрывать/показывать
@onready var menu_container = $Control

func _ready():
	# При старте игры меню должно быть скрыто
	menu_container.hide()
	# Важно: разрешаем этому узлу работать, даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Проверяем нажатие клавиши Esc (в Godot по умолчанию это "ui_cancel")
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused # Ставим игру на паузу или снимаем
	menu_container.visible = is_paused # Показываем или скрываем UI
	
	# Если нужно освободить курсор мыши при паузе:
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Эти функции нужно подключить через сигналы кнопок (вкладка "Node" рядом с Инспектором)

func _on_restart_pressed():
	get_tree().paused = false # Обязательно снимаем паузу перед перезагрузкой!
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
