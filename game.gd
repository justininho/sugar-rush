extends Node2D

const candy_scene := preload("res://interactable/candy.tscn")
#@export var candy_scene: PackedScene
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var candy_score: Label = %CandyScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var candy_collected := 0
func _on_candy_collected() -> void:
	candy_collected += 1
	candy_score.text = str(candy_collected)
	
func spawn_candy() -> void:
	var tiles : Array[Vector2i] = tile_map_layer.can_spawn_on_cells
	if !tiles.is_empty():
		var rand : Vector2i = tiles.pick_random()
		var local_position = tile_map_layer.map_to_local(rand)
		var cell_size = tile_map_layer.tile_set.tile_size
		# center in x direction and float above the tile in the y direction
		var offset = Vector2(cell_size.x * 0.5, cell_size.y * 2.0)
		var candy_instance = candy_scene.instantiate()
	 	# Connect the signal emitted by candy_instance to a function in this script
		candy_instance.candy_collected.connect(_on_candy_collected)
		candy_instance.position = local_position - offset
		add_child(candy_instance)

func _on_spawn_timer_timeout() -> void:
	spawn_candy()
