extends TileMapLayer

var can_spawn_on_cells : Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var used_cells := get_used_cells()
	for cell in used_cells:
		var data := get_cell_tile_data(cell)
		if data:
			var can_spawn_on : bool = data.get_custom_data("can_spawn_on")
			if can_spawn_on:
				#print('cell: ', cell)
				#var neighbor := get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE)
				#print('neighbor: ', neighbor)
				can_spawn_on_cells.append(cell)
			else:
				print("can't spawn on")