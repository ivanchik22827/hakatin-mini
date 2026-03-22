extends Control

# Используем @onready, чтобы пути к узлам были чистыми
@onready var master_slider = $MarginContainer/VBoxContainer/GeneralVolume/GVolSlider
@onready var music_slider = $MarginContainer/VBoxContainer/MusicVolume/MusicVolSlider
@onready var speech_slider = $MarginContainer/VBoxContainer/VoiceVolume/VoiceSlider
@onready var brightness_slider = $MarginContainer/VBoxContainer/Brightness/BrightnessSlider

func _ready():
	# 1. Загружаем текущие значения из глобального скрипта Settings в слайдеры
	master_slider.value = Settings.config.get_value("audio", "master_vol", 0.8)
	music_slider.value = Settings.config.get_value("audio", "music_vol", 0.8)
	speech_slider.value = Settings.config.get_value("audio", "speech_vol", 0.8)
	brightness_slider.value = Settings.config.get_value("video", "brightness", 1.0)
	
	# 2. Соединяем сигналы программно (чтобы не тыкать мышкой в редакторе)
	master_slider.value_changed.connect(_on_g_vol_slider_value_changed)
	music_slider.value_changed.connect(_on_music_vol_slider_value_changed)
	speech_slider.value_changed.connect(_on_voice_slider_value_changed)
	brightness_slider.value_changed.connect(_on_brightness_slider_value_changed)
	
	# Кнопка назад (убедись, что имя узла точно "Back")
	if has_node("MarginContainer/VBoxContainer/Back"):
		$MarginContainer/VBoxContainer/Back.pressed.connect(_on_back_pressed)

# --- Функции обработки ---

func _on_g_vol_slider_value_changed(value):
	Settings.apply_setting("audio", "master_vol", value)

func _on_music_vol_slider_value_changed(value):
	Settings.apply_setting("audio", "music_vol", value)

func _on_voice_slider_value_changed(value):
	Settings.apply_setting("audio", "speech_vol", value)

func _on_brightness_slider_value_changed(value):
	Settings.apply_setting("video", "brightness", value)
	# Пример применения яркости через модуляцию всего экрана:
	# self.modulate.v = value 

func _on_back_pressed():
	# Просто закрываем меню
	queue_free()
