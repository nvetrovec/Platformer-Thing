tool
extends TileMap

# cardinal directions for bitmasking
const NORTH = 1
const WEST = 2
const EAST = 4
const SOUTH = 8

func _ready():
	if (get_tree().is_editor_hint()):
		set_process(true)

func _process(delta):
	for cell in get_used_cells():
		var tile_id = 0
		# check for tiles in each of the 4 cardinal directions, then
		#  apply the id bitmask
		if (get_cell(cell.x, cell.y - 1) != -1):
			tile_id |= NORTH
		if (get_cell(cell.x - 1, cell.y) != -1):
			tile_id |= WEST
		if (get_cell(cell.x + 1, cell.y) != -1):
			tile_id |= EAST
		if (get_cell(cell.x, cell.y + 1) != -1):
			tile_id |= SOUTH
		# update the current cell with the new tile id
		set_cell(cell.x, cell.y, tile_id)
