@tool
class_name Tile
extends Sprite2D

@export var tile_sprites: Texture2D

@export var color_palette: Texture2D:
	set(value):
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
