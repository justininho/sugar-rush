extends Node2D

const candy_scene := preload("res://levels/halloween-level/interactable/candy.tscn")
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var candy_score: Label = %CandyScore
@onready var spawn_timer: Timer = %SpawnTimer
@onready var score_hud: CanvasLayer = %ScoreHUD
@onready var dead_hud: CanvasLayer = $HUD/DeadHUD
@onready var death_sound: AudioStreamPlayer2D = $DeathSfx
@onready var take_candy_sfx: AudioStreamPlayer2D = $TakeCandySfx
@onready var player: CharacterBody2D = %Player
@onready var start_game_hud: CanvasLayer = $HUD/StartGameHUD
@onready var music: AudioStreamPlayer2D = $Music
@onready var final_score_label: Label = $HUD/GameOverHUD/FinalScoreLabel
@onready var player_lives_hud: CanvasLayer = $HUD/PlayerLivesHUD
@onready var game_timer: Timer = $GameTimer
@onready var game_over_hud: CanvasLayer = $HUD/GameOverHUD
@onready var game_hud: CanvasLayer = %GameHUD
@onready var high_score_label: Label = $HUD/StartGameHUD/HighScoreLabel

func _ready() -> void:
	var highscore = load_highscore()
	update_high_score_label(highscore)
	spawn_timer.stop()
	player.hide()
	player.position = Vector2(-1000, -1000)
	get_tree().call_group("enemy", "hide")
	get_tree().create_timer(2.0).timeout
	start_game_hud.show()
	
func start_game() -> void:
	start_game_hud.hide()
	game_hud.show()
	spawn_timer.start()
	player.spawn()
	player.show()
	get_tree().call_group("enemy", "show")
	music.play()
	game_timer.start()
	
func game_over() -> void:
	var highscore = load_highscore()
	if candy_collected > highscore:
		highscore = candy_collected
		save_highscore(highscore)

	game_hud.hide()
	update_final_score_label(candy_collected)
	game_over_hud.show()
	game_timer.stop()
	spawn_timer.stop()
	player.queue_free()
	get_tree().call_group("candy", "queue_free")
	get_tree().call_group("enemy", "queue_free")
	music.stop()
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

var candy_collected := 0
func _on_candy_collected(points: int) -> void:
	candy_collected += points
	take_candy_sfx.play()
	update_score(candy_collected)
	
func update_score(score: int):
	candy_score.text = str(candy_collected)
	
func spawn_candy() -> void:
	var tiles : Array[Vector2i] = tile_map_layer.can_spawn_on_cells
	if !tiles.is_empty():
		var rand : Vector2i = tiles.pick_random()
		var local_position = tile_map_layer.map_to_local(rand)
		var cell_size = tile_map_layer.tile_set.tile_size
		# center in x direction and float above the tile in the y direction
		var offset = Vector2(cell_size.x * 0.5, cell_size.y * 3.0)
		var candy_instance = candy_scene.instantiate()
	 	# Connect the signal emitted by candy_instance to a function in this script
		candy_instance.candy_collected.connect(_on_candy_collected)
		candy_instance.position = local_position - offset
		add_child(candy_instance)

func _on_spawn_timer_timeout() -> void:
	spawn_candy()
	
@onready var dead_label: Label = $HUD/GameOverHUD/DeadLabel
@onready var retry_button: Button = $HUD/DeadHUD/RetryButton

func _on_player_dead() -> void:
	dead_label.show()
	death_sound.play()
	game_over()

func _on_start_button_pressed() -> void:
	start_game()

func update_final_score_label(points: int) -> void:
	final_score_label.text = str(points) + " candy collected"

func update_high_score_label(highscore: int) -> void:
	high_score_label.text = "High Score: " + str(highscore)
	
func _on_game_timer_timeout() -> void:
	game_over()

var save_path = "user://score.save"
		
func load_highscore() -> int:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var high_score = file.get_var()
		file.close()
		return high_score
	else:
		return 0

func save_highscore(highscore: int) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(highscore)
