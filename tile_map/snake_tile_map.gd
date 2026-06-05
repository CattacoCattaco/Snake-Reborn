class_name SnakeTileMap
extends Node2D

@export var sprite_sheet: Texture2D
@export var light_palette: Texture2D
@export var dark_palette: Texture2D

var snake: Array[Vector2i]
var tiles: Dictionary[Vector2i, Tile]

func _ready() -> void:
	snake = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(3, 2), Vector2i(4, 2),
			Vector2i(4, 3), Vector2i(4, 4), Vector2i(5, 4)]
	draw_snake()


func draw_snake() -> void:
	var facing: Vector2i = snake[0] - snake[1]
	var head_sprite_coords := Vector2i(3, 0 if facing.y == 0 else 1)
	var head_flip_h: bool = facing.x == 1
	var head_flip_v: bool = facing.y == 1
	create_tile(snake[0], head_sprite_coords, true, head_flip_h, head_flip_v)
	
	var is_light: bool = false
	for i in range(1, len(snake) - 1):
		var coming_from: Vector2i = snake[i + 1] - snake[i]
		var going_to: Vector2i = snake[i - 1] - snake[i]
		
		var sprite_coords: Vector2i
		
		if coming_from == -going_to:
			sprite_coords = Vector2i(2, 0 if coming_from.y == 0 else 1)
		else:
			var h_dir: Vector2i = coming_from if coming_from.y == 0 else going_to
			var v_dir: Vector2i = coming_from if coming_from.x == 0 else going_to
			
			match [h_dir.x, v_dir.y]:
				[1, 1]:
					sprite_coords = Vector2i(0, 0)
				[1, -1]:
					sprite_coords = Vector2i(0, 1)
				[-1, 1]:
					sprite_coords = Vector2i(1, 0)
				[-1, -1]:
					sprite_coords = Vector2i(1, 1)
		
		create_tile(snake[i], sprite_coords, is_light, false, false)
		is_light = !is_light
	
	var tail_dir: Vector2i = snake[-1] - snake[-2]
	var tail_sprite_coords := Vector2i(4, 0 if tail_dir.y == 0 else 1)
	var tail_flip_h: bool = tail_dir.x == 1
	var tail_flip_v: bool = tail_dir.y == 1
	create_tile(snake[-1], tail_sprite_coords, is_light, tail_flip_h, tail_flip_v)


func create_tile(pos: Vector2i, sprite_coords: Vector2i, is_light: bool, flip_h: bool, flip_v: bool
		) -> void:
	var tile := Tile.new()
	add_child(tile)
	tile.tile_sprites = sprite_sheet
	tile.color_palette = light_palette if is_light else dark_palette
	tile.sprite_coords = sprite_coords
	tile.position = pos * 16
	tile.flip_h = flip_h
	tile.flip_v = flip_v
	
	tiles[pos] = tile
