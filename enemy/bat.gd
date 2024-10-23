extends CharacterBody2D


@export var fly_speed = 50.0

var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var aggro_zone: Area2D = %AggroZone
@onready var aggro_timer: Timer = %AggroTimer
@onready var attack_duration_timer: Timer = %AttackDurationTimer

signal state_change(state: String)

var home_position : Vector2 = Vector2(0.0, 0.0)

func _ready() -> void:
	animated_sprite_2d.play("fly")
	home_position = global_position
	pass

enum BatStates { IDLE, CHASE, ATTACK}
var current_state := BatStates.IDLE :
	set(state):
		if current_state == state:
			return
			
		if current_state == BatStates.CHASE:
			aggro_timer.start()
			
		if current_state == BatStates.ATTACK:
			attack_cooldown_timer.start()
		elif state == BatStates.ATTACK:
			attack_duration_timer.start()
	
		current_state = state
		set_animation()
		state_change.emit(get_state_string(current_state))
		
func update_state() -> void:
	match current_state:
		BatStates.IDLE:
			if aggro_zone.has_overlapping_bodies():
				target = aggro_zone.get_overlapping_bodies()[0]
				current_state = BatStates.CHASE
		BatStates.CHASE:
			if aggro_timer.is_stopped():
				current_state = BatStates.IDLE
			elif in_attack_range() and attack_cooldown_timer.is_stopped():
				current_state = BatStates.ATTACK
		BatStates.ATTACK:
			if attack_duration_timer.is_stopped():
				if aggro_timer.is_stopped():
					current_state = BatStates.IDLE
				elif attack_duration_timer.is_stopped():
					current_state = BatStates.CHASE

func on_state(delta: float) -> void:
	match current_state:
		BatStates.IDLE:
			on_idle(delta)
		BatStates.CHASE:
			on_chase()
		BatStates.ATTACK:
			on_attack()

func _physics_process(delta: float) -> void:
	on_state(delta)
	update_state()

@export var WANDER_RADIUS = 50.0
@export var WANDER_SPEED = 25.0
var wander_target = null
func on_idle(delta: float) -> void:
	if wander_target == null or global_position.distance_to(wander_target) < WANDER_RADIUS * .25:
		wander_target = get_wander_target()
	do_navigation(wander_target, WANDER_SPEED)
		
func get_wander_target() -> Vector2:
	var rand_x = randf_range(-WANDER_RADIUS, WANDER_RADIUS)
	var rand_y = randf_range(-WANDER_RADIUS, WANDER_RADIUS)
	var wander_point = Vector2(rand_x, rand_y)
	return home_position + wander_point
		
func on_chase() -> void:
	if is_instance_valid(target):
		do_navigation(target.global_position, fly_speed)

@export var attack_range = 75.0
@export var attack_speed = 100.0
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer

func on_attack() -> void:
	if is_instance_valid(target):
		do_navigation(target.global_position, attack_speed)

func in_attack_range() -> bool:
	var in_range := false
	if is_instance_valid(target):
		in_range = global_position.distance_to(target.global_position) <= attack_range
	return in_range

func do_navigation(target: Vector2, speed: float) -> void:
	navigation_agent_2d.target_position = target
		
	if navigation_agent_2d.is_navigation_finished():
		return
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed

	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		velocity = new_velocity
		
	move_and_slide()
	animated_sprite_2d.flip_h = false if velocity.x > 0 else true

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	
func set_animation() -> void:
	match current_state:
		BatStates.IDLE, BatStates.CHASE:
			animated_sprite_2d.play("fly")
		BatStates.ATTACK:
			animated_sprite_2d.play("attack")
			
func get_state_string(state: BatStates) -> String:
	match state:
		BatStates.IDLE:
			return "IDLE"
		BatStates.CHASE:
			return "CHASE"
		BatStates.ATTACK:
			return "ATTACK"
	return ""
