class_name SnakeTileMap
extends Node2D

@export var light_palette: Texture2D
@export var dark_palette: Texture2D

@export var board_size := Vector2i(10, 10)

var snake: Array[Vector2i]
var tiles: Array[Array]

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
			
			tile.color_palette = light_palette
			tile.is_light_tile = (x + y) % 2 == 0
			tile.sprite_coords = Tile.EMPTY
			tile.fg_sprite.flip_h = false
			tile.fg_sprite.flip_v = false
	
	snake = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(3, 2), Vector2i(4, 2),
			Vector2i(4, 3), Vector2i(4, 4), Vector2i(5, 4)]
	draw_snake()
	
	set_tile(Vector2i(5, 5), Tile.APPLE, true, false, false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("move_up"):
			move_snake(Vector2i(0, -1))
		elif event.is_action_pressed("move_left"):
			move_snake(Vector2i(-1, 0))
		if event.is_action_pressed("move_down"):
			move_snake(Vector2i(0, 1))
		elif event.is_action_pressed("move_right"):
			move_snake(Vector2i(1, 0))


func move_snake(dir: Vector2i) -> void:
	var new_head: Vector2i = snake[0] + dir
	
	if not has_tile(new_head):
		print("Can't move off board")
		return
	
	var new_head_tile: Tile = get_tile(new_head)
	
	if snake[-1] != new_head and new_head_tile.has_snake():
		print("Can't move into self")
		return
	
	set_tile(snake[-1], Tile.EMPTY, true, false, false)
	
	for i in range(len(snake) - 1, 0, -1):
		snake[i] = snake[i - 1]
		var tile: Tile = get_tile(snake[i])
		tile.color_palette = light_palette if tile.color_palette == dark_palette else dark_palette
	
	snake[0] = new_head
	draw_head()
	draw_segment(1, false)
	draw_tail(len(snake) % 2 == 1)


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


func set_tile(pos: Vector2i, sprite_coords: Vector2i, is_light: bool, flip_h: bool, flip_v: bool
		) -> void:
	var tile := get_tile(pos)
	tile.color_palette = light_palette if is_light else dark_palette
	tile.sprite_coords = sprite_coords
	tile.fg_sprite.flip_h = flip_h
	tile.fg_sprite.flip_v = flip_v


func has_tile(pos: Vector2i) -> bool:
	return pos.x < 20 and pos.y < 20 and pos.x > -1 and pos.y > -1


func get_tile(pos: Vector2i) -> Tile:
	return tiles[pos.y][pos.x]
