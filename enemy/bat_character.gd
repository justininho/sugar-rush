extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -400.0

var target: Node2D = null

@onready var bat: Node2D = $".."
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var detection_zone: Area2D = %DetectionZone
@onready var detection_zone_collision_2d: CollisionShape2D = $DetectionZone/DetectionZoneCollision2D

signal state_change(state: String)

func _ready() -> void:
	pass

enum BatStates { IDLE, CHASE, ATTACK}
var current_state := BatStates.IDLE :
	set(state):
		print('state change: ', state)
		if current_state == state:
			return
	
		current_state = state
		set_animation()
		state_change.emit(get_state_string(current_state))
		
func update_state() -> void:
	match current_state:
		BatStates.IDLE:
			print('overlap: ', detection_zone.get_overlapping_bodies())
			if detection_zone.has_overlapping_bodies():
				print('start chasing')
				current_state = BatStates.CHASE
		BatStates.CHASE:
			pass
			 #todo aggression zone
			#current_state = BatStates.IDLE

func on_state() -> void:
	match current_state:
		BatStates.IDLE:
			pass
		BatStates.CHASE:
			do_navagation()

func _physics_process(delta: float) -> void:
	on_state()
	update_state()
		
func do_navagation() -> void:
	print('do navigation', bat.target)

	if is_instance_valid(bat.target):
		navigation_agent_2d.target_position = bat.target.global_position
		
	if navigation_agent_2d.is_navigation_finished():
		return
	
	print('do this thing')
		
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * SPEED

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
			
func get_state_string(state: BatStates) -> String:
	match state:
		BatStates.IDLE:
			return "IDLE"
		BatStates.CHASE:
			return "CHASE"
		BatStates.ATTACK:
			return "ATTACK"
	return ""
