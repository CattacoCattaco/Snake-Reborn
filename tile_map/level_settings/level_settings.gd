class_name LevelSettings
extends Resource

enum LevelType {
	COMBO,
	NORMAL,
	GHOST,
	LAGGY,
	BLINDNESS,
	GROWTH_SPURT,
	CONFUSED,
	MAZE,
	COUNT,
}


static func get_level_type_light_palette(comp_level: LevelType) -> Texture2D:
	match comp_level:
		LevelType.COMBO:
			return preload("res://tile_map/tile/color_palettes/snake_colors_hell_light.png")
		LevelType.NORMAL:
			return preload("res://tile_map/tile/color_palettes/snake_colors_light.png")
		LevelType.GHOST:
			return preload("res://tile_map/tile/color_palettes/snake_colors_ghost.png")
		LevelType.LAGGY:
			return preload("res://tile_map/tile/color_palettes/snake_colors_laggy_light.png")
		LevelType.BLINDNESS:
			return preload("res://tile_map/tile/color_palettes/snake_colors_blindness_light.png")
		LevelType.GROWTH_SPURT:
			return preload("res://tile_map/tile/color_palettes/snake_colors_growth_spurt_light.png")
		LevelType.CONFUSED:
			return preload("res://tile_map/tile/color_palettes/snake_colors_confused_light.png")
		LevelType.MAZE:
			return preload("res://tile_map/tile/color_palettes/snake_colors_maze_light.png")
	
	return preload("res://tile_map/tile/color_palettes/snake_colors_light.png")


static func get_level_type_dark_palette(comp_level: LevelType) -> Texture2D:
	match comp_level:
		LevelType.COMBO:
			return preload("res://tile_map/tile/color_palettes/snake_colors_hell_dark.png")
		LevelType.NORMAL:
			return preload("res://tile_map/tile/color_palettes/snake_colors_dark.png")
		LevelType.GHOST:
			return preload("res://tile_map/tile/color_palettes/snake_colors_ghost.png")
		LevelType.LAGGY:
			return preload("res://tile_map/tile/color_palettes/snake_colors_laggy_dark.png")
		LevelType.BLINDNESS:
			return preload("res://tile_map/tile/color_palettes/snake_colors_blindness_dark.png")
		LevelType.GROWTH_SPURT:
			return preload("res://tile_map/tile/color_palettes/snake_colors_growth_spurt_dark.png")
		LevelType.CONFUSED:
			return preload("res://tile_map/tile/color_palettes/snake_colors_confused_dark.png")
		LevelType.MAZE:
			return preload("res://tile_map/tile/color_palettes/snake_colors_maze_dark.png")
	
	return preload("res://tile_map/tile/color_palettes/snake_colors_dark.png")

static var NORMAL := LevelSettings.new(1, "Normal", LevelType.NORMAL)
static var GHOST := LevelSettings.new(2, "Ghost", LevelType.GHOST, true, 1)
static var LAGGY := LevelSettings.new(3, "LAGGY", LevelType.LAGGY, false, 0, 1)
static var BLINDNESS := LevelSettings.new(4, "BLINDNESS", LevelType.BLINDNESS, false, 0, 0, 3)
static var GROWTH_SPURT := LevelSettings.new(5, "Growth Spurt", LevelType.GROWTH_SPURT, false, 0, 0,
		0, true)
static var CONFUSED := LevelSettings.new(6, "Confused", LevelType.CONFUSED, false, 0, 0, 0, false,
		0.1)
static var MAZE := LevelSettings.new(7, "Maze", LevelType.MAZE, false, 0, 0, 0, false, 0.0, true)

static var DEFAULT_LEVEL_SEQUENCE: Array[LevelSettings] = [
	NORMAL,
	GHOST,
	LAGGY,
	BLINDNESS,
	GROWTH_SPURT,
	CONFUSED,
	MAZE,
]

@export var point_value: int = 1
@export var level_name: String = ""
@export var light_palette: Texture2D
@export var dark_palette: Texture2D

@export var use_flames_for_walls: bool = false

@export var walls_made_per_eat: int = 0
@export var lagginess: int = 0
@export var blindness_duration: int = 0
@export var do_unconditional_growth: bool = false
@export var confused_chance: float = 0.0
@export var generate_maze: bool = false

func _init(p_point_value: int = 1, p_level_name: String = "",
		level_type: LevelType = LevelType.NORMAL, p_use_flames_for_walls: bool = false, 
		p_walls_made_per_eat: int = 0, p_lagginess: int = 0, p_blindness_duration: int = 0,
		p_do_unconditional_growth: bool = false, p_confused_chance: float = 0.0,
		p_generate_maze: bool = false) -> void:
	point_value = p_point_value
	level_name = p_level_name
	light_palette = get_level_type_light_palette(level_type)
	dark_palette = get_level_type_dark_palette(level_type)
	use_flames_for_walls = p_use_flames_for_walls
	walls_made_per_eat = p_walls_made_per_eat
	lagginess = p_lagginess
	blindness_duration = p_blindness_duration
	do_unconditional_growth = p_do_unconditional_growth
	confused_chance = p_confused_chance
	generate_maze = p_generate_maze
