extends Node2D
@export var ballTexture: Sprite2D
@export var collision: Area2D
 
@export var castTime: float = 1.0
@export var distanceMultiplier: float = 1.0
@export var steerSpeed: float = 150.0
@export var maxSteer: float = 80.0
@export var steerAxis: Vector2 = Vector2.DOWN  # direction the bait can be nudged
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
var base_pos := Vector2.ZERO 
var steer_offset := 0.0
var tween: Tween
func _ready() -> void:
	base_pos = position
	collision.body_entered.connect(onBodyEntered)
	collision.body_exited.connect(onBodyExited)
func _process(delta: float) -> void:
	if steering:
		var input := Input.get_axis("ui_up", "ui_down")
		steer_offset = clamp(steer_offset + input * steerSpeed * delta, -maxSteer, maxSteer)

	position = base_pos + steerAxis * steer_offset
	if current_player == Player.PLAYER_1:
		castRod(delta)
	if hooking == true:
		tween.kill()
		
		tween = create_tween()
		tween.tween_property(self, "base_pos", Vector2.ZERO, castTime)
		tween.parallel().tween_property(self, "steer_offset", 0.0, castTime)
		tween.tween_callback(func(): thrown = false)
		tween.tween_callback(func(): hooking = false)
		enemyBody.getMoved(get_global_position())
		
func castRod(delta: float) -> void:
	if thrown:
		return
	
	if Input.is_action_pressed("ui_accept"):
		distance += 100.0 * distanceMultiplier * delta
		ballTexture.visible = true

	if Input.is_action_just_released("ui_accept"):
		thrown = true
		steering = true
		var target := base_pos + Vector2(distance, 0)
		distance = 10.0

		tween = create_tween()
		tween.tween_property(self, "base_pos", target, castTime)
		tween.tween_interval(2.0) 
		tween.tween_callback(func(): steering = false)
		
		tween.tween_property(self, "base_pos", Vector2.ZERO, castTime)
		tween.parallel().tween_property(self, "steer_offset", 0.0, castTime)
		tween.tween_callback(func(): thrown = false)

func onBodyEntered(body: CharacterBody2D):
	if current_player == Player.PLAYER_1:
		if body.name == "PorcupineBody2":
			enemyBody = body
			hooking = true

func onBodyExited(body:CharacterBody2D):
	if current_player == Player.PLAYER_1:
		if body == enemyBody:
			hooking = false
