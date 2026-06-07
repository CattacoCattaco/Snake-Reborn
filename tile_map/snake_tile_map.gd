class_name SnakeTileMap
extends Node2D

enum Level {
	NORMAL,
	GHOST,
	CONFUSED,
	LEVEL_COUNT,
}

const MOVE_TIME_SECONDS: float = 0.125

@export var bg: ColorRect
@export var score_label: Label

@export var board_size := Vector2i(24, 21)

var level: Level = Level.NORMAL

var move_timer: Timer
var current_move_dir: Vector2i

var snake: Array[Vector2i]

var tiles: Array[Array]

var score: int:
	set(value):
		score = value
		score_label.text = "Score: %d" % score


static func get_level_light_palette(comp_level: Level) -> Texture2D:
	match comp_level:
		Level.NORMAL:
			return preload("res://tile_map/tile/color_palettes/snake_colors_light.png")
		Level.GHOST:
			return preload("res://tile_map/tile/color_palettes/snake_colors_ghost.png")
		Level.CONFUSED:
			return preload("res://tile_map/tile/color_palettes/snake_colors_confused_light.png")
	
	return preload("res://tile_map/tile/color_palettes/snake_colors_light.png")


static func get_level_dark_palette(comp_level: Level) -> Texture2D:
	match comp_level:
		Level.NORMAL:
			return preload("res://tile_map/tile/color_palettes/snake_colors_dark.png")
		Level.GHOST:
			return preload("res://tile_map/tile/color_palettes/snake_colors_ghost.png")
		Level.CONFUSED:
			return preload("res://tile_map/tile/color_palettes/snake_colors_confused_dark.png")
	
	return preload("res://tile_map/tile/color_palettes/snake_colors_dark.png")


func _ready() -> void:
	var offset := Vector2i(320, 180) - (board_size * 8)
	for y in range(board_size.y):
		tiles.append([])
		for x in range(board_size.x):
			var tile := Tile.new()
			add_child(tile)
			
			var pos := Vector2i(x, y)
			tile.position = pos * 16 + offset
			tiles[y].append(tile)
			
			tile.color_palette = get_light_palette()
			tile.is_light_tile = (x + y) % 2 == 0
			tile.sprite_coords = Tile.EMPTY
			tile.fg_sprite.flip_h = false
			tile.fg_sprite.flip_v = false
	
	reset_snake()
	
	place_walls()
	place_apple()
	
	bg.color = get_light_palette().get_image().get_pixel(1, 1)
	score_label.label_settings.font_color = get_light_palette().get_image().get_pixel(0, 1)
	
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.timeout.connect(move_snake)
	
	score = 0


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("move_up"):
			change_snake_dir(Vector2i(0, -1))
		elif event.is_action_pressed("move_left"):
			change_snake_dir(Vector2i(-1, 0))
		if event.is_action_pressed("move_down"):
			change_snake_dir(Vector2i(0, 1))
		elif event.is_action_pressed("move_right"):
			change_snake_dir(Vector2i(1, 0))


func change_snake_dir(dir: Vector2i) -> void:
	if current_move_dir == dir or (current_move_dir == -dir and len(snake) > 2):
		return
	
	current_move_dir = dir
	move_snake()


func move_snake() -> void:
	var new_head: Vector2i = snake[0] + current_move_dir
	var new_head_tile: Tile = get_tile(new_head)
	
	if snake[-1] != new_head and not new_head_tile.is_safe():
		die()
		return
	
	var ate: bool = new_head_tile.has_apple()
	var old_tale: Vector2i = snake[-1]
	
	if not ate:
		clear_tile(snake[-1])
	
	for i in range(len(snake) - 1, 0, -1):
		snake[i] = snake[i - 1]
		var tile: Tile = get_tile(snake[i])
		tile.color_palette = get_light_palette() if i % 2 == 0 else get_dark_palette()
	
	snake[0] = new_head
	if ate:
		snake.append(old_tale)
		place_apple()
		score += level + 1
		if level == Level.GHOST:
			place_flame()
	
	draw_head()
	if len(snake) > 2:
		draw_segment(1, false)
	draw_tail(len(snake) % 2 == 1)
	
	reset_move_timer()


func die() -> void:
	match level:
		Level.LEVEL_COUNT - 1:
			level = Level.NORMAL
			score = 0
		_:
			level = (level + 1) as Level
	
	move_timer.stop()
	current_move_dir = Vector2i(0, 0)
	
	bg.color = get_light_palette().get_image().get_pixel(1, 1)
	score_label.label_settings.font_color = get_light_palette().get_image().get_pixel(0, 1)
	
	clear_board()
	reset_snake()
	place_walls()
	place_apple()
	
	if level == Level.GHOST:
		place_flame()


func reset_snake() -> void:
	snake = [Vector2i(11, 10), Vector2i(12, 10)]
	draw_snake()


func draw_snake() -> void:
	draw_head()
	
	var is_light: bool = false
	for i in range(1, len(snake) - 1):
		draw_segment(i, is_light)
		is_light = !is_light
	
	draw_tail(is_light)


func draw_head() -> void:
	var facing: Vector2i = snake[0] - snake[1]
	var sprite_coords := Vector2i(Tile.HEAD_COLUMN, Tile.get_hv_row(facing.y == 0))
	var flip_h: bool = facing.x == 1
	var flip_v: bool = facing.y == 1
	set_tile(snake[0], sprite_coords, true, flip_h, flip_v)


func draw_segment(index: int, is_light: bool) -> void:
	var coming_from: Vector2i = snake[index + 1] - snake[index]
	var going_to: Vector2i = snake[index - 1] - snake[index]
	
	var sprite_coords: Vector2i
	
	if coming_from == -going_to:
		sprite_coords = Vector2i(Tile.STRAIGHT_COLUMN, Tile.get_hv_row(coming_from.y == 0))
	else:
		var h_dir: Vector2i = coming_from if coming_from.y == 0 else going_to
		var v_dir: Vector2i = coming_from if coming_from.x == 0 else going_to
		
		match [h_dir.x, v_dir.y]:
			[1, 1]:
				sprite_coords = Tile.CORNER_BOTTOM_RIGHT
			[1, -1]:
				sprite_coords = Tile.CORNER_TOP_RIGHT
			[-1, 1]:
				sprite_coords = Tile.CORNER_BOTTOM_LEFT
			[-1, -1]:
				sprite_coords = Tile.CORNER_TOP_LEFT
	
	set_tile(snake[index], sprite_coords, is_light, false, false)


func draw_tail(is_light: bool) -> void:
	var dir: Vector2i = snake[-1] - snake[-2]
	var sprite_coords := Vector2i(Tile.TAIL_COLUMN, Tile.get_hv_row(dir.y == 0))
	var flip_h: bool = dir.x == 1
	var flip_v: bool = dir.y == 1
	set_tile(snake[-1], sprite_coords, is_light, flip_h, flip_v)


func place_walls() -> void:
	for x in [0, board_size.x - 1]:
		for y in range(board_size.y):
			var pos := Vector2i(x, y)
			if level == Level.GHOST:
				place_flame_at(pos)
			else:
				set_tile(pos, Tile.WALL)
	
	for y in [0, board_size.y - 1]:
		for x in range(board_size.x):
			var pos := Vector2i(x, y)
			if level == Level.GHOST:
				place_flame_at(pos)
			else:
				set_tile(pos, Tile.WALL)


func place_apple() -> void:
	var pos: Vector2i = get_random_empty_tile()
	set_tile(pos, Tile.APPLE)


func place_flame() -> void:
	var pos: Vector2i = get_random_empty_tile()
	place_flame_at(pos)


func place_flame_at(pos: Vector2i) -> void:
	set_tile(pos, Tile.FLAME)
	var tile: Tile = get_tile(pos)
	tile.color_palette = preload("res://tile_map/tile/color_palettes/fire_colors.png")


func get_random_empty_tile() -> Vector2i:
	var pos: Vector2i
	
	pos.x = randi_range(0, board_size.x - 1)
	pos.y = randi_range(0, board_size.y - 1)
	
	while not get_tile(pos).is_empty():
		pos.x = randi_range(0, board_size.x - 1)
		pos.y = randi_range(0, board_size.y - 1)
	
	return pos


func clear_board() -> void:
	for y in range(board_size.y):
		for x in range(board_size.x):
			clear_tile(Vector2i(x, y))
	snake = []


func clear_tile(pos: Vector2i) -> void:
	set_tile(pos, Tile.EMPTY)


func set_tile(pos: Vector2i, sprite_coords: Vector2i, is_light: bool = true, flip_h: bool = false,
		flip_v: bool = false) -> void:
	var tile := get_tile(pos)
	tile.color_palette = get_light_palette() if is_light else get_dark_palette()
	tile.sprite_coords = sprite_coords
	tile.fg_sprite.flip_h = flip_h
	tile.fg_sprite.flip_v = flip_v


func reset_move_timer() -> void:
	if level == Level.CONFUSED:
		move_timer.start(MOVE_TIME_SECONDS ** randf_range(0.2, 1.3))
	else:
		move_timer.start(MOVE_TIME_SECONDS)


func has_tile(pos: Vector2i) -> bool:
	return pos.x < board_size.x and pos.y < board_size.y and pos.x > -1 and pos.y > -1


func get_tile(pos: Vector2i) -> Tile:
	return tiles[pos.y][pos.x]


func get_light_palette() -> Texture2D:
	return get_level_light_palette(level)


func get_dark_palette() -> Texture2D:
	return get_level_dark_palette(level)
