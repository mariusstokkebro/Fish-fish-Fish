extends Area2D

@onready var score_sound: AudioStreamPlayer = $"ScoreSoundPlayer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(onBodyEntered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onBodyEntered(body:CharacterBody2D):
	print_debug(body.name)
	if body.hooked == true:
		if "powerup_type" in body:
			var catcher = body.currentBait.player
			var is_player1 = (catcher == WinManager.player1)
			
			match body.powerup_type:
				"sardine":
					apply_speed_boost(catcher)
				"shrimp":
					if is_player1:
						WinManager.player1_score += 1
					else:
						WinManager.player2_score += 1
					score_sound.play()
				"fly":
					var enemy = WinManager.player2 if is_player1 else WinManager.player1
					apply_stun(enemy)
					
			body.queue_free() 
			return
			
		score_sound.play()
		if body.name == "PorcupineBody":
			WinManager.player2_score += 1
			WinManager.reset = true
		if body.name == "PorcupineBody2":
			WinManager.player1_score += 1
			WinManager.reset = true

func apply_speed_boost(player: CharacterBody2D) -> void:
	player.speed = 600.0
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(player):
		player.speed = 300.0

func apply_stun(player: CharacterBody2D) -> void:
	player.is_stunned = true
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(player):
		player.is_stunned = false
