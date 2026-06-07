class_name StartMenu
extends Control

@export var main_scene: PackedScene

@export var title_screen: Sprite2D
@export var press_enter_to_start: Sprite2D


func _ready() -> void:
	var level: SnakeTileMap.Level = (randi_range(0, SnakeTileMap.Level.LEVEL_COUNT - 1)
			as SnakeTileMap.Level)
	var palette: Texture2D = SnakeTileMap.get_level_light_palette(level)
	
	title_screen.material = ShaderMaterial.new()
	title_screen.material.shader = preload("res://recolor/recolor.gdshader")
	title_screen.material.set_shader_parameter("palette", palette)
	
	press_enter_to_start.material = ShaderMaterial.new()
	press_enter_to_start.material.shader = preload("res://recolor/enter_to_start.gdshader")
	press_enter_to_start.material.set_shader_parameter("palette", palette)
	
	grab_focus()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("start"):
			print("hi")
			var main: Node2D = main_scene.instantiate()
			get_tree().root.add_child(main)
			queue_free()
