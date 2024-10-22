extends CharacterBody2D

@export var IDLE_LERP_AMOUNT := 0.25

@export var WALK_SPEED = 200
@export var RUN_SPEED = 300.0
@export var ACCELERATION_SPEED = 1200.0

@export var JUMP_VELOCITY = 300
@export var JUMP_BOOST_FORCE = 200.0 # Extra upward force applied when jump is held

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var jump_boost_remaining_timer := $JumpBoostRemainingTimer as Timer

var jump_count := 0
var max_jumps := 2

@export var health := 3

signal dead

signal state_change(state_string: String)

enum PlayerState {IDLE, WALKING, RUNNING, JUMPING, FALL_JUMP, DOUBLE_JUMP, FALLING}

var previous_state := PlayerState.IDLE
var current_state := PlayerState.IDLE :
	set(state):  
		if current_state == state:
			return
		
		previous_state = current_state
		current_state = state
		animated_sprite.play(get_player_state_string(state))
		state_change.emit(get_player_state_string(state)) 
		match state:
			PlayerState.WALKING, PlayerState.RUNNING, PlayerState.IDLE:
				jump_count = 0

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
		PlayerState.DOUBLE_JUMP:
			return "double_jumping"
		PlayerState.FALL_JUMP:
			return "fall_jumping"
		PlayerState.FALLING:
			return "falling"
	return ""

func update_state() -> void:
	match current_state:
		PlayerState.IDLE, PlayerState.WALKING, PlayerState.RUNNING:
			if Input.is_action_pressed("jump"):
				current_state = PlayerState.JUMPING
			elif has_direction():
				if Input.is_action_pressed("run"):
					current_state = PlayerState.RUNNING
				else:
					current_state = PlayerState.WALKING
			else:
				current_state = PlayerState.IDLE
		PlayerState.JUMPING:
			if is_on_floor():
				if has_direction():
					current_state = PlayerState.WALKING
				else:
					current_state = PlayerState.IDLE
			elif Input.is_action_just_pressed("jump"):
				current_state = PlayerState.DOUBLE_JUMP
			elif velocity.y > 0.0:
				current_state = PlayerState.FALLING
		PlayerState.DOUBLE_JUMP:
			if is_on_floor():
				if has_direction():
					current_state = PlayerState.WALKING
				else:
					current_state = PlayerState.IDLE
			elif velocity.y > 0.0:
				current_state = PlayerState.FALLING
		PlayerState.FALL_JUMP:
			if is_on_floor():
				if has_direction():
					current_state = PlayerState.WALKING
				else:
					current_state = PlayerState.IDLE
			elif velocity.y > 0.0:
				current_state = PlayerState.FALLING
		PlayerState.FALLING:
			if is_on_floor():
				if has_direction():
					current_state = PlayerState.WALKING
				else:
					current_state = PlayerState.IDLE
			if Input.is_action_just_pressed("jump") and previous_state != PlayerState.DOUBLE_JUMP:
				current_state = PlayerState.FALL_JUMP

func _physics_process(delta: float) -> void:
	on_state(delta)
	update_state()
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
func has_direction() -> bool:
	return Input.get_axis("move_left", "move_right") != 0
	
func on_state(delta: float) -> void:
	apply_gravity(delta)
	match current_state:
		PlayerState.IDLE:
			on_idle()
		PlayerState.WALKING:
			on_walking(delta)
		PlayerState.RUNNING:
			on_running(delta)
		PlayerState.JUMPING:
			on_jump(delta)
		PlayerState.FALLING:
			on_falling(delta)
		PlayerState.FALL_JUMP:
			on_fall_jump(delta)
		PlayerState.DOUBLE_JUMP:
			on_double_jump(delta)	
	move_and_slide()

func on_idle() -> void:
	velocity.x = lerp(velocity.x, 0.0, IDLE_LERP_AMOUNT)

func on_walking(delta: float) -> void:
	do_movement(delta)

func on_running(delta: float) -> void:
	do_movement(delta)

func on_falling(delta: float) -> void:
	do_movement(delta)

func do_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right");
	animated_sprite.flip_h = false if direction > 0 else true
	#if absf(direction) > 0.0:
		#animated_sprite.flip_h = direction < 0
	var speed : float = WALK_SPEED
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
		
	var acceleration : float = ACCELERATION_SPEED * delta
	var target_speed := direction * speed
	# Using cubic_interpolate to smooth velocity
	var x = cubic_interpolate(velocity.x, target_speed, 0.0, 0.0, 0.5)
	# Adjust final velocity value to include delta
	velocity.x = move_toward(x, target_speed, acceleration)

func can_jump_boost():
	return Input.is_action_pressed("jump") and jump_boost_remaining_timer.time_left > 0

func do_jump_boost(delta: float) -> void:
	velocity.y -= JUMP_BOOST_FORCE * delta

func on_jump(delta: float) -> void:
	if is_on_floor():
		jump_count = 1
		velocity.y = -JUMP_VELOCITY
		jump_boost_remaining_timer.start()
	elif can_jump_boost():
		do_jump_boost(delta)
	do_movement(delta)

func do_extra_jump(delta: float) -> void:
	if jump_count < max_jumps:
		velocity.y = -JUMP_VELOCITY
		jump_count += 1
		jump_boost_remaining_timer.start()
	elif can_jump_boost():
		do_jump_boost(delta)
	do_movement(delta)

func on_double_jump(delta: float) -> void:
	do_extra_jump(delta)

func on_fall_jump(delta: float) -> void:
	do_extra_jump(delta)

func _on_hit_box_body_entered(body: Node2D) -> void:
	health -= 1
	print('health: ', health)
	if health <= 0:
		dead.emit()
