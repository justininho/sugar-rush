extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var detection_zone: Area2D = %DetectionZone
@onready var aggro_zone: Area2D = %AggroZone

signal state_change(state: String)

func _ready() -> void:
	#current_state = BatStates.IDLE;
	pass

enum BatStates { IDLE, CHASE, ATTACK}
var current_state := BatStates.IDLE :
	set(state):
		if current_state == state:
			return
	
		current_state = state
		set_animation()
		state_change.emit(get_state_string(current_state))
		
func update_state() -> void:
	match current_state:
		BatStates.IDLE:
			print('')
			if detection_zone.has_overlapping_bodies():
				current_state = BatStates.CHASE
		BatStates.CHASE:
			if !aggro_zone.has_overlapping_bodies():
				current_state = BatStates.IDLE
			 #todo aggression zone
			#if current_state = BatStates.IDLE

func on_state() -> void:
	match current_state:
		BatStates.IDLE:
			return
		BatStates.CHASE:
			do_navagation()

func _physics_process(delta: float) -> void:
	on_state()
	update_state()
		
func do_navagation() -> void:
	if is_instance_valid(target):
		navigation_agent_2d.target_position = target.global_position
		
	if navigation_agent_2d.is_navigation_finished():
		return
	
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


func _on_detection_zone_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print('body shape entered: ', body_rid)
	if target.get_instance_id() == body.get_instance_id():
		print('target detected')
