class_name LevelSelectScreen
extends Control

@export var main_scene: PackedScene

@export var play_normal_button: Button
@export var level_select: LevelSelect


func _ready() -> void:
	play_normal_button.pressed.connect(play_normal)
	level_select.play_button.pressed.connect(play_level)


func play_normal() -> void:
	var main: Main = main_scene.instantiate()
	get_tree().root.add_child(main)
	queue_free()

func play_level() -> void:
	var main: Main = main_scene.instantiate()
	main.snake_tile_map.level_sequence = [level_select.get_level()]
	get_tree().root.add_child(main)
	queue_free()
