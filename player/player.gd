extends CharacterBody2D

var is_jumping := false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		is_jumping = true
		$AnimatedSprite2D.animation = "jump"
		velocity.y = JUMP_VELOCITY
	elif is_on_floor() and is_jumping:
		is_jumping = false
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not is_jumping:
			$AnimatedSprite2D.flip_h = direction < 0
			$AnimatedSprite2D.animation = "walk"
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
