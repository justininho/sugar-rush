extends CanvasLayer

@onready var player: CharacterBody2D = %Player
@onready var player_health_container: GridContainer = %PlayerHealthContainer
@onready var player_health_icon: TextureRect = %PlayerHealthIcon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_health_icons()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_health_icons() -> void:
	var health : int = player.health
	player_health_container.columns = health
	for i in range(health - 1):
		var new_icon = TextureRect.new()
		new_icon.texture = player_health_icon.texture  # Use the same texture as the original icon
		player_health_container.add_child(new_icon)

func _on_player_hit(health: int) -> void:
		var icons := player_health_container.get_children()
		if health > 0 and health < len(icons):
			icons[health].hide()
			
