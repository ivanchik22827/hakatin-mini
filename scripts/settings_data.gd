extends Node
var config = ConfigFile.new()
func _ready():
	config.load("user://settings.cfg")
func apply_setting(section, key, value):
	config.set_value(section, key, value)
	config.save("user://settings.cfg")
