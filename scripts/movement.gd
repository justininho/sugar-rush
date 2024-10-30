extends Node

class_name MoveUtils

#@export 
var character : CharacterBody2D
#@export 
var animated_sprite : AnimatedSprite2D

func _init(char : CharacterBody2D, sprite : AnimatedSprite2D) -> void:
	character = char
	animated_sprite = sprite

func move_character(
	#character: CharacterBody2D,
	#animated_sprite: AnimatedSprite2D,
	speed: float, 
	acceleration: float
) -> void:
	var direction := Input.get_axis("move_left", "move_right");
	animated_sprite.flip_h = false if direction > 0 else true
	#var speed : float = WALK_SPEED
	#if Input.is_action_pressed("run"): 
		#speed = RUN_SPEED
	#var acceleration : float = acceleration_force * delta
	var target_speed := direction * speed
	# Using cubic_interpolate to smooth velocity
	var x = cubic_interpolate(character.velocity.x, target_speed, 0.0, 0.0, 0.5)
	# Adjust final velocity value to include delta
	character.x = move_toward(x, target_speed, acceleration)
	character.move_and_slide()
