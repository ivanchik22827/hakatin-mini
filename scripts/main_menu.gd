extends Control

# Указываем пути к сценам, куда будем переходить
# Замени "res://levels/world.tscn" на путь к твоему первому уровню
const START_LEVEL = "res://scenes/ui/TestAnimations2.tscn"

func _ready():
	# При запуске проверяем, чтобы фокус был на первой кнопке (для геймпада/клавиатуры)
	$"MarginContainer/MainLayout/ButtonsStack/New game".grab_focus()

# --- Логика кнопок ---

func _on_new_game_pressed():
	print("Начинаем новую игру...")
	# Переключаем сцену на игровой мир
	get_tree().change_scene_to_file(START_LEVEL)

func _on_load_game_pressed():
	print("Загрузка сохранения...")
	# Здесь будет логика открытия файла сохранения
	# Пока можно просто вывести в консоль

func _on_settings_pressed():
	print("Открываем настройки...")
	# Обычно здесь создается экземпляр сцены настроек:
	var settings = load("res://scenes/ui/settings_menu.tscn").instantiate()
	add_child(settings)

func _on_quit_pressed():
	print("Выход из игры")
	get_tree().quit()
