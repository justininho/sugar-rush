extends State
class_name Walk

@export var speed = 200.0
@export var acceleration_speed := 1200.0

var move_utils : MoveUtils

func _ready() -> void:
	move_utils = MoveUtils.new(character, animated_sprite)
	pass

func enter() -> void:
	#print('enter walk')
	animated_sprite.play("walk")

func update(_delta: float) -> void:
	if character.has_direction():
		pass
		#if Input.is_action_pressed("run"):
			#transition.emit(self, "run")
	else:
		transition.emit(self, "idle")
	
	
func physics_update(delta: float) -> void:
	move_utils.move_character(speed, acceleration_speed * delta)
	#MoveUtils.move_character(character, animated_sprite, speed, acceleration_speed * delta)
	#character.velocity.x = move_x()
	#character.do_movement(delta)
	#character.move_and_slide()
	
		#
#func do_movement(delta: float) -> void:
	#print('move')
	#var direction := Input.get_axis("move_left", "move_right");
	#animated_sprite.flip_h = false if direction > 0 else true
	##var speed : float = WALK_SPEED
	##if Input.is_action_pressed("run"):
		##speed = RUN_SPEED
		#
	#var acceleration := acceleration_speed * delta
	#var target_speed : float = direction * speed
	## Using cubic_interpolate to smooth velocity
	#var x = cubic_interpolate(character.velocity.x, target_speed, 0.0, 0.0, 0.5)
	## Adjust final velocity value to include delta
	#character.velocity.x = move_toward(x, target_speed, acceleration)
