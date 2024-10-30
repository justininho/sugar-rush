extends Node
class_name State_Machine

@export var initial_state : State
@export var character : CharacterBody2D
@export var animated_sprite : AnimatedSprite2D

var states := {}
var current_state : State = null

func _ready():
	#print('state machine ready')
	assert(character != null, "State Machine must have a character")
	assert(animated_sprite != null, "State Machine must have an animated sprite")
	for child in get_children():
		if child is State:
			states[child.get_name().to_lower()] = child
			child.transition.connect(on_transition)
			child.character = character
			child.animated_sprite = animated_sprite
	
	#print('states: ', states)
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()

func _process(delta: float) -> void:
	#print('process: ', current_state)
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	#print('physics: ', current_state)
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	#print('input: ', current_state, event)
	if current_state:
		current_state.handle_input(event)

func on_transition(state: State, next_state_name: String) -> void:
		if state != current_state:
				return

		var next_state = states[next_state_name.to_lower()]
		if !next_state:
				return

		if current_state:
				current_state.exit()

		current_state = next_state
		#print('current_state: ', current_state)
