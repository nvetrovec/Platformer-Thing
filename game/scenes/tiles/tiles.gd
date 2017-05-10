tool
extends Node2D

export(bool) var reset = false setget _on_reset
export(Texture) var sprite_sheet = null
export(int) var rows
export(int) var columns
export(int) var tile_size

func _on_reset(value):
	if (value):
		reset = false
		for child in get_children():
			child.free()
		var i = 0
		# column-major, to fit with the x and y coordinates
		for col in range(columns):
			for row in range(rows):
				_make_tile("tile_" + str(i), col, row)
				i += 1

func _make_tile(name, col, row):
	var tile = Sprite.new()
	add_child(tile)
	tile.set_owner(self)
	tile.set_name(name)
	tile.set_pos(Vector2(row * tile_size * 1.25 + (tile_size / 2), col * tile_size * 1.25 + (tile_size / 2)))
	tile.set_texture(sprite_sheet)
	tile.set_region(true)
	tile.set_region_rect(Rect2(Vector2(row * tile_size, col * tile_size), Vector2(tile_size, tile_size)))
	# setup body
	var body = StaticBody2D.new()
	tile.add_child(body)
	body.set_owner(self)
	body.set_name("body")
	body.set_global_transform(tile.get_global_transform())
	# setup hitbox
	var hitbox = CollisionShape2D.new()
	body.add_child(hitbox)
	hitbox.set_owner(self)
	hitbox.set_name("hitbox")
	var rect = RectangleShape2D.new()
	rect.set_extents(tile.get_region_rect().size * 0.5)
	hitbox.set_shape(rect)
	hitbox.set_global_transform(tile.get_global_transform())
