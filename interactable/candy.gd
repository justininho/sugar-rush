extends Node2D

@onready var spawn_timer: Timer = %SpawnTimer
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var candy_score: Label = %CandyScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_candy()

var score := 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	score += 1
	candy_score.text = str(score)
	hide_sprite()
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_candy()
	show_sprite()

@onready var tile_map_layer: TileMapLayer = %TileMapLayer

func spawn_candy() -> void:
	var tiles : Array[Vector2i] = tile_map_layer.can_spawn_on_cells
	if !tiles.is_empty():
		var rand : Vector2i = tiles.pick_random()
		var local_position = tile_map_layer.map_to_local(rand)
		var cell_size = tile_map_layer.tile_set.tile_size
		# center in x direction and float above the tile in the y direction
		var offset = Vector2(cell_size.x * 0.5, cell_size.y * 2.0)
		position = local_position - offset

func hide_sprite() -> void:
	sprite_2d.visible = false	
	
func show_sprite() -> void:
	sprite_2d.visible = true
