@tool
class_name Tile
extends Sprite2D

const CORNER_BOTTOM_RIGHT := Vector2i(0, 0)
const CORNER_TOP_RIGHT := Vector2i(0, 1)
const CORNER_BOTTOM_LEFT := Vector2i(1, 0)
const CORNER_TOP_LEFT := Vector2i(1, 1)

const STRAIGHT_COLUMN: int = 2
const HEAD_COLUMN: int = 3
const TAIL_COLUMN: int = 4
const DEAD_COLUMN: int = 5
const HORZONTAL_ROW: int = 0
const VERTICAL_ROW: int = 1

const APPLE := Vector2i(6, 0)
const EMPTY := Vector2i(6, 1)

@export var color_palette: Texture2D:
	set(value):
		if not material or material is not ShaderMaterial:
			material = ShaderMaterial.new()
			material.shader = preload("res://tile_map/tile/tile.gdshader")
		
		color_palette = value
		material.set_shader_parameter("palette", value)

@export var sprite_coords: Vector2i:
	set(value):
		sprite_coords = value
		
		var atlas := AtlasTexture.new()
		atlas.atlas = tile_sprites
		atlas.region.size = Vector2(16, 16)
		atlas.region.position = Vector2(sprite_coords * 16)
		
		texture = atlas

var tile_sprites: Texture2D

# Returns HORZONTAL_ROW if is_horizontal
# [br]Otherwise, returns VERTICAL_ROW
static func get_hv_row(is_horizontal: bool) -> int:
	return HORZONTAL_ROW if is_horizontal else VERTICAL_ROW


func _ready() -> void:
	centered = false
