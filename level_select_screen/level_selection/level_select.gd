class_name LevelSelect
extends PanelContainer

@export var level_type_options: OptionButton
@export var play_button: Button
@export var custom_level_property_controls: Array[Control]
@export var ghost_walls_box: SpinBox
@export var lagginess_box: SpinBox
@export var blindness_duration_box: SpinBox
@export var do_unconditional_growth_check: CheckButton
@export var confused_chance_box: SpinBox
@export var generate_maze_check: CheckButton


func _ready() -> void:
	_level_type_selected(0)
	level_type_options.item_selected.connect(_level_type_selected)


func _level_type_selected(level_type: int) -> void:
	if level_type == level_type_options.item_count - 1:
		for property_control in custom_level_property_controls:
			property_control.show()
	else:
		for property_control in custom_level_property_controls:
			property_control.hide()


func get_level() -> LevelSettings:
	if level_type_options.selected == level_type_options.item_count - 1:
		var level := LevelSettings.new(1, "Custom", LevelSettings.LevelType.COMBO)
		level.walls_made_per_eat = roundi(ghost_walls_box.value)
		level.lagginess = roundi(lagginess_box.value)
		level.blindness_duration = roundi(blindness_duration_box.value)
		level.do_unconditional_growth = do_unconditional_growth_check.button_pressed
		level.confused_chance = confused_chance_box.value
		level.generate_maze = generate_maze_check.button_pressed
		return level
	else:
		return LevelSettings.DEFAULT_LEVEL_SEQUENCE[level_type_options.selected]
