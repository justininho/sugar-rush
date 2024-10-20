extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D

signal candy_collected

# make group so I can free all the nodes when the game is restarted

func _ready() -> void:
	sprite_2d.region_rect = random_region()

func _on_area_2d_body_entered(body: Node2D) -> void:
	candy_collected.emit()
	queue_free()

func random_region() -> Rect2:
	var base_x := 48
	var offset := randi_range(0, 4)
	return Rect2(base_x + 16 * offset, 0, 16, 16)
