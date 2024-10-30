extends State
class_name MovementState

@export var speed := 200.0
@export var acceleration_speed := 1200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func do_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right");
	animated_sprite.flip_h = false if direction > 0 else true
	#var speed : float = WALK_SPEED
	#if Input.is_action_pressed("run"):
		#speed = RUN_SPEED
		
	var acceleration := acceleration_speed * delta
	var target_speed : float = direction * speed
	# Using cubic_interpolate to smooth velocity
	var x = cubic_interpolate(character.velocity.x, target_speed, 0.0, 0.0, 0.5)
	# Adjust final velocity value to include delta
	character.velocity.x = move_toward(x, target_speed, acceleration)
