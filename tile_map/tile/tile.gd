@tool
class_name Tile
extends Node2D

const FG_SPRITE_SHEET: Texture2D = preload("res://tile_map/tile/sprites/tiles.png")
const BG_SPRITE_SHEET: Texture2D = preload("res://tile_map/tile/sprites/background_tiles.png")

const SNAKE_PART_COLUMNS: Array[int] = [0, 1, 2, 3, 4]

const CORNER_BOTTOM_RIGHT := Vector2i(0, 0)
const CORNER_TOP_RIGHT := Vector2i(0, 1)
const CORNER_BOTTOM_LEFT := Vector2i(1, 0)
const CORNER_TOP_LEFT := Vector2i(1, 1)

const STRAIGHT_COLUMN: int = 2
const HEAD_COLUMN: int = 3
const TAIL_COLUMN: int = 4
const HORZONTAL_ROW: int = 0
const VERTICAL_ROW: int = 1

const APPLE := Vector2i(5, 0)
const FLAME := Vector2i(6, 0)

const EMPTY := Vector2i(5, 1)

@export var color_palette: Texture2D:
	set(value):
		if not material or material is not ShaderMaterial:
			material = ShaderMaterial.new()
			material.shader = preload("res://recolor/recolor.gdshader")
		
		color_palette = value
		material.set_shader_parameter("palette", value)

@export var is_light_tile: bool:
	set(value):
		is_light_tile = value
		
		var atlas := AtlasTexture.new()
		atlas.atlas = BG_SPRITE_SHEET
		atlas.region.size = Vector2(16, 16)
		atlas.region.position = Vector2(0 if is_light_tile else 16, 0)
		
		bg_sprite.texture = atlas

@export var sprite_coords: Vector2i:
	set(value):
		sprite_coords = value
		
		var atlas := AtlasTexture.new()
		atlas.atlas = FG_SPRITE_SHEET
		atlas.region.size = Vector2(16, 16)
		atlas.region.position = Vector2(sprite_coords * 16)
		
		fg_sprite.texture = atlas

var bg_sprite: Sprite2D
var fg_sprite: Sprite2D

# Returns HORZONTAL_ROW if is_horizontal
# [br]Otherwise, returns VERTICAL_ROW
static func get_hv_row(is_horizontal: bool) -> int:
	return HORZONTAL_ROW if is_horizontal else VERTICAL_ROW


func _ready() -> void:
	bg_sprite = Sprite2D.new()
	fg_sprite = Sprite2D.new()
	
	add_child(bg_sprite)
	add_child(fg_sprite)
	
	bg_sprite.centered = false
	fg_sprite.centered = false
	
	bg_sprite.use_parent_material = true
	fg_sprite.use_parent_material = true


func has_snake() -> bool:
	return sprite_coords.x in SNAKE_PART_COLUMNS


func has_apple() -> bool:
	return sprite_coords == APPLE


func has_flame() -> bool:
	return sprite_coords == FLAME


func is_empty() -> bool:
	return sprite_coords == EMPTY
