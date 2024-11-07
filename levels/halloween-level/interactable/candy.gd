extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var despawn_timer: Timer = $DespawnTimer

@export var golden_bias := 0

signal candy_collected(points: int)

func _ready() -> void:
	sprite_2d.region_rect = random_region(golden_bias)

var phase = 0.0  # Tracks the sine wave phase
func _process(delta: float) -> void:
	var remaining_time = despawn_timer.time_left
	var timer_duration = despawn_timer.wait_time
	
	if remaining_time < timer_duration / 2:
		# Calculate blink speed based on remaining time
	 	# Calculate the normalized time for the second half
		var normalized_time = 1.0 - (remaining_time / (timer_duration / 2))

		# Use cubic interpolation for the blink speed
		var blink_speed = cubic_interpolate(0.5, 10.0, 0.0, 10.0, normalized_time)

		# Increment the phase by the blink speed
		phase += blink_speed * delta
		
		# Make the sprite blink by toggling visibility at the current blink speed
		if sin(phase * PI) > 0:
			visible = true
		else:
			visible = false
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	var points: int = get_meta("points")
	candy_collected.emit(points)
	queue_free()

func random_region(golden_bias: int) -> Rect2:
	var base_x := 48
	var bias = []
	bias.resize(golden_bias)
	bias.fill(2)
	var offsets = [0, 1, 2, 3, 4] + bias
	var offset : int = offsets[randi() % offsets.size()]
	# golden candy is worth 5 points	
	if offset == 2:
		set_meta("points", 5)
	else:
		set_meta("points", 1)
	return Rect2(base_x + 16 * offset, 0, 16, 16)
	
func _on_despawn_timer_timeout() -> void:
	queue_free()
