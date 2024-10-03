extends CharacterBody2D

const WALK_SPEED = 250.0#300.0
const RUN_SPEED = WALK_SPEED * 1.25
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -350.0#-400.0
const MAX_JUMP_HOLD_TIME = 0.2  # Maximum time (seconds) to hold the jump for extra height
const JUMP_HOLD_FORCE = -300.0  # Extra upward force applied when jump is held

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D

var jump_time_remaining := 0.0  # How much time is left to add extra force
var is_running := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
	
	animated_sprite.flip_h = direction < 0
	var animation := get_new_animation()
	animated_sprite.play(animation)

# Handles initial jump and sets the jump hold time.
func try_jump() -> void: 
	if is_on_floor():
		velocity.y = JUMP_VELOCITY  # Initial jump velocity
		jump_time_remaining = MAX_JUMP_HOLD_TIME  # Allow extra force for a limited time
		
func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			if is_running:
				animation_new = "running"
			else: 
				animation_new = "walking"
		else:
			animation_new = "idle"
	else:
		if velocity.y >= 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	return animation_new
	
