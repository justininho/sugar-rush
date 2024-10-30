extends State
class_name Idle

@export var idle_lerp_amount := 0.25
	
func enter() -> void:
	print('enter idle')
	animated_sprite.play("idle")
	pass

func update(_delta: float) -> void:
	if character.has_direction():
		if Input.is_action_pressed("run"):
			transition.emit(self, "run")
		else:
			print('walk')
			transition.emit(self, "walk")

func physics_update(delta: float) -> void:
	character.velocity.x = lerp(character.velocity.x, 0.0, idle_lerp_amount)
	character.move_and_slide()
