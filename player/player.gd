extends CharacterBody2D

const WALK_SPEED = 250.0#300.0
const RUN_SPEED = WALK_SPEED * 1.25
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -350.0#-400.0
const MAX_JUMP_HOLD_TIME = 0.2  # Maximum time (seconds) to hold the jump for extra height
const JUMP_HOLD_FORCE = -300.0  # Extra upward force applied when jump is held

const WALL_GLIDE_SPEED := 50.0
const WALL_GLIDE_LERP_AMOUNT := 0.1

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D

var jump_time_remaining := 0.0  # How much time is left to add extra force
var is_running := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_wall_only():
		velocity.y = lerp(velocity.y, WALL_GLIDE_SPEED, WALL_GLIDE_LERP_AMOUNT)

	# walk or run
	var speed := WALK_SPEED
	if Input.is_action_pressed("run"):
		is_running = true
		speed = RUN_SPEED
	else:
		is_running = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		try_jump()
		
	# Apply extra jump force if the jump button is held and there is time left.
	print_debug("jump: ", Input.is_action_pressed("jump"), " jump time remaining: ", jump_time_remaining > 0.0)
	if Input.is_action_pressed("jump") and jump_time_remaining > 0.0:
		velocity.y += JUMP_HOLD_FORCE * delta
		jump_time_remaining -= delta
	
	var direction := Input.get_axis("walk_left", "walk_right") * speed;
	print_debug("From: ", velocity.x, " To: ", direction, " Delta: ", ACCELERATION_SPEED * delta)
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	move_and_slide()
	
	var animation := get_new_animation(direction)
	animated_sprite.play(animation)

# Handles initial jump and sets the jump hold time.
func try_jump() -> void: 
	if is_on_floor():
		velocity.y = JUMP_VELOCITY  # Initial jump velocity
		jump_time_remaining = MAX_JUMP_HOLD_TIME  # Allow extra force for a limited time
		
func get_new_animation(direction: float) -> String:
	if absf(direction) > 0.0:
		animated_sprite.flip_h = direction < 0
	
	if is_on_floor():
		return _get_ground_animation()
	else:
		return _get_air_animation(direction)

func _get_ground_animation() -> String:
	if absf(velocity.x) > 0.1:
		if is_running:
			return "running"
		else:
			return "walking"
	return "idle"

func _get_air_animation(direction: float) -> String:
#	pressed against wall
	if is_on_wall_only():
		#animated_sprite.flip_h = !animated_sprite.flip_h
		return "wall"
	elif velocity.y >= 0.0:
		return "falling"
	else:
		return "jumping"
