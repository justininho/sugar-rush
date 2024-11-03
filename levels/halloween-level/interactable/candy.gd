extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D

signal candy_collected(points: int)

func _ready() -> void:
	sprite_2d.region_rect = random_region()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var points: int = get_meta("points")
	candy_collected.emit(points)
	queue_free()

func random_region() -> Rect2:
	var base_x := 48
	var offset := randi_range(0, 4)
	# golden candy is worth 5 points	
	if offset == 2:
		set_meta("points", 5)
	else:
		set_meta("points", 1)
	return Rect2(base_x + 16 * offset, 0, 16, 16)

func _on_despawn_timer_timeout() -> void:
	queue_free()
