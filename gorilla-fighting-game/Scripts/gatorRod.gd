extends Node2D
@export var ballTexture: Sprite2D
@export var reticleTexture: Sprite2D
@export var player: CharacterBody2D
@export var collision: Area2D
@export var castTime: float = 1.0
@export var distanceMultiplier: float = 1.0
@export var steerSpeed: float = 150.0
@export var maxSteer: float = 80.0
@export var steerAxis: Vector2 = Vector2.DOWN
@export var reelSpeed: float = 0.2
@export var timeToCatch: float = 5
enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}
@export var current_player: Player = Player.PLAYER_1
var distance := 10.0
var thrown := false
var steering := false
var hooking = false
var enemyBody: CharacterBody2D
var base_pos
var steer_offset := 0.0
var tween: Tween
var fishList: Array
var lastAngle: float = 0.0
var rotationSpeed: float = 0.0
var timer: float = 0.0
func _ready() -> void:
	base_pos = player.position
	
func _physics_process(delta: float) -> void:
	fishList = collision.get_overlapping_bodies()
	
func _process(delta: float) -> void:
	if WinManager.reset:
		thrown = false
		ballTexture.visible = false
		position = player.position
	if steering:
		var up = "p%d_rotate_up" % current_player
		var down = "p%d_rotate_down" % current_player
		var input := Input.get_axis(up, down)
		steer_offset = clamp(steer_offset + input * steerSpeed * delta, -maxSteer, maxSteer)
	if thrown == false:
		base_pos = player.position
	position = base_pos + steerAxis * steer_offset
	
	castRod(delta)
	
	if hooking == true:
		timer += delta
		if tween:
			tween.kill()
			reelIn(delta)
		if enemyBody:
			enemyBody.getMoved(get_global_position(),self)
		if timer > timeToCatch:
			hooking = false
			timer = 0.0
			base_pos = player.position
			ballTexture.visible = false
			thrown = false
			enemyBody.hooked = false
func castRod(delta: float) -> void:
	var confirm = "p%d_confirm" % current_player
	if thrown:
		if Input.is_action_pressed(confirm):
			reticleTexture.position = Vector2.ZERO
			if fishList.is_empty() == false:
				hookFish(fishList[0])
			reelIn(delta)
		return
	
	if Input.is_action_pressed(confirm):
		distance += 100.0 * distanceMultiplier * delta
		reticleTexture.visible = true
		if current_player == Player.PLAYER_1:
			reticleTexture.position.x = distance
		else:
			reticleTexture.position.x = -distance

		if ballTexture:
			ballTexture.visible = true

	if Input.is_action_just_released(confirm):
		reticleTexture.visible = false
		reticleTexture.position.x = 0
		var target
		thrown = true
		steering = true
		if current_player == Player.PLAYER_1:
			target = base_pos + Vector2(distance, 0)
		else:
			target = base_pos + Vector2(-distance, 0)
		distance = 10.0
		
		tween = create_tween()
		tween.tween_property(self, "base_pos", target, castTime)
		tween.tween_interval(2.0) 
		tween.tween_callback(func(): steering = false)

func hookFish(body: Node2D):
	var confirm = "p%d_confirm" % current_player
	if body.current_player != current_player:
		enemyBody = body
		body.Hooked()
		if Input.is_action_pressed(confirm):
			hooking = true
		
func reelIn(delta:float):
	if hooking:
		var currentPosition = base_pos
		var input_vector := Input.get_vector(
		"p%d_rotate_left" % current_player,
		"p%d_rotate_right" % current_player, 
		"p%d_rotate_up" % current_player,
		"p%d_rotate_down" % current_player)
		if input_vector.length() > 0.1:
			var currentAngle = atan2(input_vector.y,input_vector.x)
			var angle_diff = wrapf(currentAngle - lastAngle, -PI,PI)
			rotationSpeed = angle_diff/delta
			lastAngle = currentAngle
		else:
			rotationSpeed =0.0
		var newPosition = Vector2(currentPosition.x + reelSpeed * rotationSpeed,currentPosition.y)
		base_pos = newPosition
	else:
		tween = create_tween()
		tween.tween_property(self, "base_pos", player.position, castTime)
		tween.parallel().tween_property(self, "steer_offset", 0.0, castTime)
		tween.tween_callback(func(): thrown = false)
		tween.tween_callback(func(): hooking = false)
		tween.tween_callback(func(): ballTexture.visible = false)
