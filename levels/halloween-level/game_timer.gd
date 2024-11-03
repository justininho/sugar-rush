extends Timer

@onready var game_timer_label: Label = %GameTimerLabel

func _process(delta: float) -> void:
	if time_left > 0.0:
		game_timer_label.text = str(round(time_left))
