class_name SnakeTileMap
extends Node2D

const MOVE_TIME_SECONDS: float = 0.125

const ORTHOGONALS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 0)]

@export var bg: ColorRect
@export var score_label: Label
@export var blindness_cover: ColorRect
@export var level_transition_screen: ColorRect
@export var level_transition_label: Label

@export var board_size := Vector2i(26, 21)

var level_num: int = 0
var level_sequence: Array[LevelSettings] = LevelSettings.DEFAULT_LEVEL_SEQUENCE
var level: LevelSettings = level_sequence[level_num]

var move_timer: Timer
var transition_timer: Timer
var current_move_dir: Vector2i
var blindness_countdown: int = 0

var snake: Array[Vector2i]

var tiles: Array[Array]

var score: int:
	set(value):
		score = value
		score_label.text = "Score: %d" % score


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
	move_timer.one_shot = true
	move_timer.timeout.connect(move_snake)
	
	transition_timer = Timer.new()
	add_child(transition_timer)
	transition_timer.one_shot = true
	
	score = 0
	blindness_countdown = level.blindness_duration


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
		elif event.is_action_pressed("start"):
			if transition_timer.time_left > 0:
				transition_timer.stop()
				transition_timer.timeout.emit()


func change_snake_dir(dir: Vector2i) -> void:
	if transition_timer.time_left > 0.0:
		return
	
	var is_start_turn_around: bool = current_move_dir == Vector2i(0, 0) and dir == Vector2i(1, 0)
	var is_turn_around_attempt: bool = current_move_dir == -dir or is_start_turn_around
	var can_turn_around: bool = len(snake) == 2 and not level.do_unconditional_growth
	if current_move_dir == dir or (is_turn_around_attempt and not can_turn_around):
		return
	
	match dir:
		Vector2i(0, -1):
			play_sound(preload("res://tile_map/sound_effects/turn_up.wav"))
		Vector2i(-1, 0):
			play_sound(preload("res://tile_map/sound_effects/turn_left.wav"))
		Vector2i(0, 1):
			play_sound(preload("res://tile_map/sound_effects/turn_down.wav"))
		Vector2i(1, 0):
			play_sound(preload("res://tile_map/sound_effects/turn_right.wav"))
	
	current_move_dir = dir
	move_snake(true)


func move_snake(from_turn: bool = false) -> void:
	if not from_turn and randf() < level.confused_chance:
		var safe_dirs: Array[Vector2i] = []
		for dir in ORTHOGONALS:
			if dir == current_move_dir:
				continue
			
			if dir == -current_move_dir and len(snake) > 2:
				continue
			
			if get_tile(snake[0] + dir).is_safe():
				safe_dirs.append(dir)
		
		if safe_dirs:
			change_snake_dir(safe_dirs.pick_random())
			return
	
	var new_head: Vector2i = snake[0] + current_move_dir
	var new_head_tile: Tile = get_tile(new_head)
	
	if (snake[-1] != new_head or level.do_unconditional_growth) and not new_head_tile.is_safe():
		die()
		return
	
	var ate: bool = new_head_tile.has_apple()
	var old_tale: Vector2i = snake[-1]
	
	if not (ate or level.do_unconditional_growth):
		clear_tile(snake[-1])
	
	for i in range(len(snake) - 1, 0, -1):
		snake[i] = snake[i - 1]
		var tile: Tile = get_tile(snake[i])
		tile.color_palette = get_light_palette() if i % 2 == 0 else get_dark_palette()
	
	snake[0] = new_head
	if ate:
		play_sound(preload("res://tile_map/sound_effects/eat.wav"))
		
		snake.append(old_tale)
		place_apple()
		score += level.point_value
		
		for i in range(level.walls_made_per_eat):
			place_flame()
	elif level.do_unconditional_growth:
		snake.append(old_tale)
	
	draw_head()
	if len(snake) > 2:
		draw_segment(1, false)
	draw_tail(len(snake) % 2 == 1)
	
	if level.blindness_duration:
		blindness_countdown -= 1
		if blindness_countdown == 0:
			blindness_countdown = level.blindness_duration
			
			if blindness_cover.visible:
				blindness_cover.hide()
			else:
				blindness_cover.show()
	
	reset_move_timer()


func die() -> void:
	if level.blindness_duration:
		blindness_cover.hide()
	
	if level_num == len(level_sequence) - 1:
		level_num = 0
		score = 0
		play_sound(preload("res://tile_map/sound_effects/die.wav"))
	else:
		level_num += 1
		play_sound(preload("res://tile_map/sound_effects/rebirth.wav"))
	
	level = level_sequence[level_num]
	
	level_transition_screen.show()
	level_transition_label.text = level.level_name
	
	move_timer.stop()
	current_move_dir = Vector2i(0, 0)
	
	bg.color = get_light_palette().get_image().get_pixel(1, 1)
	score_label.label_settings.font_color = get_light_palette().get_image().get_pixel(0, 1)
	
	clear_board()
	reset_snake()
	place_walls()
	place_apple()
	
	blindness_countdown = level.blindness_duration
	
	do_transition_time()


func reset_snake() -> void:
	var row: int = floori(board_size.y / 2.0)
	var right_column: int = ceili(board_size.x / 2.0)
	
	if level.generate_maze:
		row -= 1
	
	snake = [Vector2i(right_column - 1, row), Vector2i(right_column, row)]
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
			place_wall(Vector2i(x, y))
	
	for y in [0, board_size.y - 1]:
		for x in range(board_size.x):
			place_wall(Vector2i(x, y))
	
	for i in range(level.walls_made_per_eat):
		place_flame()
	
	if level.generate_maze:
		var center_right: int = ceili(board_size.x / 2.0)
		for x in [center_right - 1, center_right]:
			for y in range(0, board_size.y, 2):
				place_wall(Vector2i(x, y))
		
		create_maze_half(0, center_right - 1)
		create_maze_half(center_right, board_size.x - 1)


func create_maze_half(left_column: int, right_column: int) -> void:
	for x in range(left_column + 2, right_column, 2):
		for y in range(1, board_size.y - 1):
			place_wall(Vector2i(x, y))
	
	for x in range(left_column, right_column):
		for y in range(2, board_size.y - 1, 2):
			place_wall(Vector2i(x, y))
	
	var path: Array[Vector2i] = []
	var unused_tiles: Array[Vector2i] = []
	var dead_ends: Array[Vector2i] = []
	
	for x in range(left_column + 1, right_column, 2):
		for y in range(1, board_size.y - 1, 2):
			unused_tiles.append(Vector2i(x, y))
	
	path.append(unused_tiles.pop_back())
	dead_ends.append(path[0])
	
	while unused_tiles:
		var valid_dirs: Array[Vector2i] = []
		for dir in ORTHOGONALS:
			var neighbor: Vector2i = path[-1] + dir * 2
			var wall: Vector2i = path[-1] + dir
			if neighbor in unused_tiles or (neighbor in dead_ends and get_tile(wall).has_wall()):
				valid_dirs.append(dir)
		
		if not valid_dirs:
			dead_ends.append(path[-1])
			path.append(unused_tiles.pop_back())
			dead_ends.append(path[-1])
		else:
			var dir: Vector2i = valid_dirs.pick_random()
			var neighbor: Vector2i = path[-1] + dir * 2
			
			clear_tile(path[-1] + dir)
			
			if neighbor in path:
				dead_ends.erase(neighbor)
				path.append(unused_tiles.pop_back())
				dead_ends.append(path[-1])
			else:
				unused_tiles.erase(neighbor)
				path.append(neighbor)
	
	dead_ends.append(path[-1])
	
	var center_right: int = ceili(board_size.x / 2.0)
	
	for dead_end in dead_ends:
		var valid_dirs: Array[Vector2i] = []
		for dir in ORTHOGONALS:
			var neighbor: Vector2i = dead_end + dir * 2
			var wall: Vector2i = dead_end + dir
			
			var is_in_center = neighbor.x == center_right or neighbor.x == center_right - 1
			if has_tile(neighbor) and (get_tile(wall).has_wall()) and (not is_in_center):
				valid_dirs.append(dir)
		
		clear_tile(dead_end + valid_dirs.pick_random())
	
	var connected_tiles: Array[Vector2i] = []
	var disconnected_tiles: Array[Vector2i] = path.duplicate()
	var disconnected_tiles_for_later: Array[Vector2i] = []
	connected_tiles.append(disconnected_tiles.pop_back())
	
	while disconnected_tiles or disconnected_tiles_for_later:
		if not disconnected_tiles:
			disconnected_tiles = disconnected_tiles_for_later
			disconnected_tiles_for_later = []
		
		var pos: Vector2i = disconnected_tiles[-1]
		
		var pos_is_connected: bool = false
		for dir in ORTHOGONALS:
			var neighbor: Vector2i = pos + dir * 2
			var wall: Vector2i = pos + dir
			
			if (not get_tile(wall).has_wall()) and neighbor in connected_tiles:
				pos_is_connected = true
				break
		
		if pos_is_connected:
			connected_tiles.append(disconnected_tiles.pop_back())
		else:
			for dir in ORTHOGONALS:
				var neighbor: Vector2i = pos + dir * 2
				var wall: Vector2i = pos + dir
				
				if get_tile(wall).has_wall() and neighbor in connected_tiles:
					clear_tile(wall)
					connected_tiles.append(disconnected_tiles.pop_back())
					pos_is_connected = true
					break
			
			if not pos_is_connected:
				disconnected_tiles_for_later.append(disconnected_tiles.pop_back())


func place_wall(pos: Vector2i) -> void:
	if level.use_flames_for_walls:
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
	if level.lagginess:
		var min_exponent: float = 0.5 / (level.lagginess + 1)
		var max_exponent: float = 1 + (level.lagginess * 0.25)
		move_timer.start(MOVE_TIME_SECONDS ** randf_range(min_exponent, max_exponent))
	else:
		move_timer.start(MOVE_TIME_SECONDS)


func has_tile(pos: Vector2i) -> bool:
	return pos.x < board_size.x and pos.y < board_size.y and pos.x > -1 and pos.y > -1


func get_tile(pos: Vector2i) -> Tile:
	return tiles[pos.y][pos.x]


func get_light_palette() -> Texture2D:
	return level.light_palette


func get_dark_palette() -> Texture2D:
	return level.dark_palette


func play_sound(sound: AudioStreamWAV) -> void:
	var sound_effect_player := AudioStreamPlayer.new()
	add_child(sound_effect_player)
	sound_effect_player.stream = sound
	sound_effect_player.play()
	sound_effect_player.finished.connect(sound_effect_player.queue_free)


func do_transition_time() -> void:
	transition_timer.start(1.5)
	await transition_timer.timeout
	level_transition_screen.hide()
