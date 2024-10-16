extends CharacterBody2D

@export var IDLE_LERP_AMOUNT := 0.25

@export var WALK_SPEED = 200
@export var RUN_SPEED = 300.0
@export var ACCELERATION_SPEED = 1800.0

@export var JUMP_VELOCITY = -300
@export var JUMP_HOLD_FORCE = -200.0 # Extra upward force applied when jump is held

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var jump_boost_remaining_timer := $JumpBoostRemainingTimer as Timer

signal state_change(state_string: String)

enum PlayerState {IDLE, WALKING, RUNNING, JUMPING, FALLING, WALL_SLIDE, WALL_JUMP}
var current_state := PlayerState.IDLE

func change_state(new_state: PlayerState):
	if current_state == new_state:
			return

	print("Changing state from %s to %s" % [get_player_state_string(current_state), get_player_state_string(new_state)])
	current_state = new_state
	state_change.emit(get_player_state_string(current_state))

func get_player_state_string(state: PlayerState) -> String:
	match state:
		PlayerState.IDLE:
			return "idle"
		PlayerState.WALKING:
			return "walking" 
		PlayerState.RUNNING:
			return "running"
		PlayerState.JUMPING:
			return "jumping"
		PlayerState.FALLING:
			return "falling"
	return ""

func update_state() -> void:
	match current_state:
		PlayerState.IDLE:
			if has_direction():
				change_state(PlayerState.WALKING)
			elif Input.is_action_pressed("run"):
				change_state(PlayerState.RUNNING)
			elif Input.is_action_pressed("jump"):
				change_state(PlayerState.JUMPING)
		PlayerState.WALKING:
			if not has_direction():
				change_state(PlayerState.IDLE)
			elif Input.is_action_pressed("run"):
				change_state(PlayerState.RUNNING)
			elif Input.is_action_pressed("jump"):
				change_state(PlayerState.JUMPING)
		PlayerState.RUNNING:
			if not has_direction():
				change_state(PlayerState.IDLE)
			elif not Input.is_action_pressed("run"):
				change_state(PlayerState.WALKING)
			elif Input.is_action_pressed("jump"):
				change_state(PlayerState.JUMPING)
		PlayerState.JUMPING:
			if is_on_floor_only():
				if has_direction():
					change_state(PlayerState.WALKING)
				else:
					change_state(PlayerState.IDLE)
			elif velocity.y > 0.0:
				change_state(PlayerState.FALLING) 
		PlayerState.FALLING:
			if is_on_floor():
				if has_direction():
					change_state(PlayerState.WALKING)
				else:
					change_state(PlayerState.IDLE)
	animated_sprite.play(get_player_state_string(current_state))
	
func _physics_process(delta: float) -> void:
	handle_state(delta)
	update_state()
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
func has_direction() -> bool:
	return Input.get_axis("move_left", "move_right") != 0

func handle_state(delta: float) -> void:
	apply_gravity(delta)
	match current_state:
		PlayerState.IDLE:
			handle_idle()
		PlayerState.WALKING:
			handle_movement(delta, WALK_SPEED)
		PlayerState.RUNNING:
			handle_movement(delta, RUN_SPEED)
		PlayerState.JUMPING:
			handle_jump(delta)
			handle_movement(delta, WALK_SPEED)
		PlayerState.FALLING:
			handle_movement(delta, WALK_SPEED)
	move_and_slide()

func handle_idle() -> void:
	#print_debug("idle", "velocity.x: ", velocity.x)
	velocity.x = lerp(velocity.x, 0.0, IDLE_LERP_AMOUNT)

func handle_movement(delta: float, speed: float) -> void:
	var direction := Input.get_axis("move_left", "move_right");
	if absf(direction) > 0.0:
		animated_sprite.flip_h = direction < 0
	# print_debug("speed", speed, "direction", direction)
	# print_debug("From: ", velocity.x, " To: ", direction, " Delta: ", ACCELERATION_SPEED * delta)
	
	velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION_SPEED * delta)

# Handles initial jump and sets the jump hold time.
func handle_jump(delta: float) -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_boost_remaining_timer.start()
	elif Input.is_action_pressed("jump") and jump_boost_remaining_timer.time_left > 0:
		velocity.y += JUMP_HOLD_FORCE * delta
