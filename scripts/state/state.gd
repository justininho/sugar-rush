extends Node
class_name State

@export var character: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

signal transition(next_state_name)

# Initialize the state. E.g. change the animation
func enter() -> void:
	pass

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
	
func handle_animation(anim_name: String) -> void:
	pass

func _on_animation_finished(anim_name):
	pass
