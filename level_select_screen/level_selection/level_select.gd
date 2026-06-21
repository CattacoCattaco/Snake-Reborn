class_name LevelSelect
extends PanelContainer

@export var level_type_options: OptionButton
@export var play_button: Button


func get_level() -> LevelSettings:
	if level_type_options.selected == level_type_options.item_count - 1:
		return LevelSettings.new()
	else:
		return LevelSettings.DEFAULT_LEVEL_SEQUENCE[level_type_options.selected]
