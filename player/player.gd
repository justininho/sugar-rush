extends CharacterBody2D

const IDLE_LERP_AMOUNT := 0.25
const WALK_SPEED = 250.0 # 300.0
const RUN_SPEED = WALK_SPEED * 1.25
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -350.0 # -400.0
const MAX_JUMP_HOLD_TIME = 0.2 # Maximum time (seconds) to hold the jump for extra height
const JUMP_HOLD_FORCE = -300.0 # Extra upward force applied when jump is held

const WALL_SLIDE_SPEED := 50.0
const WALL_SLIDE_LERP_AMOUNT := 0.1

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var wall_slide_buffer_timer := $WallSlideBufferTimer as Timer

signal state_change(state_string: String)

var jump_time_remaining := 0.0 # How much time is left to add extra force

enum PlayerState {IDLE, WALKING, RUNNING, JUMPING, FALLING, WALL_SLIDE}
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
		PlayerState.WALL_SLIDE:
			return "wall_slide"
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
			elif Input.is_action_pressed("jump"):
				change_state(PlayerState.JUMPING)
			elif is_on_wall_only():
				change_state(PlayerState.WALL_SLIDE)
			elif velocity.y > 0.0:
				change_state(PlayerState.FALLING)
		PlayerState.FALLING:
			if is_on_floor_only():
				if has_direction():
					change_state(PlayerState.WALKING)
				else:
					change_state(PlayerState.IDLE)
			elif is_on_wall() and velocity.y > 0.0:
				change_state(PlayerState.WALL_SLIDE)
		PlayerState.WALL_SLIDE:
				if is_on_floor_only():
					if has_direction():
						change_state(PlayerState.WALKING)
					else:
						change_state(PlayerState.IDLE)
				elif not touching_wall() and velocity.y > 0.0:
					change_state(PlayerState.FALLING)
	
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	update_state()
	move_and_slide()
	animated_sprite.play(get_player_state_string(current_state))

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func has_direction() -> bool:
	return Input.get_axis("move_left", "move_right") != 0
	
@onready var wall_raycast_right = $WallRaycastRight as RayCast2D
@onready var wall_raycast_left = $WallRaycastLeft as RayCast2D

func touching_wall() -> bool:
	return wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding()
		
func handle_state(delta: float) -> void:
	match current_state:
		PlayerState.IDLE:
			handle_idle()
		PlayerState.WALKING:
			handle_movement(delta, WALK_SPEED)
		PlayerState.RUNNING:
			handle_movement(delta, RUN_SPEED)
		PlayerState.JUMPING:
			handle_jump(delta)
		PlayerState.FALLING:
			handle_movement(delta, WALK_SPEED)
		PlayerState.WALL_SLIDE:
			handle_wall_slide()

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
		velocity.y = JUMP_VELOCITY # Initial jump velocity
		jump_time_remaining = MAX_JUMP_HOLD_TIME # Allow extra force for a limited time
	
	#	move in the air	
	handle_movement(delta, WALK_SPEED)
	
	# Apply extra jump force if the jump button is held and there is time left.
	# print_debug("jump: ", Input.is_action_pressed("jump"), " jump time remaining: ", jump_time_remaining > 0.0)
	# todo test this
	if Input.is_action_pressed("jump") and jump_time_remaining > 0.0:
		velocity.y += JUMP_HOLD_FORCE * delta
		jump_time_remaining -= delta
		
func handle_wall_slide() -> void:
	if is_on_wall():
		velocity.y = lerp(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_LERP_AMOUNT)
