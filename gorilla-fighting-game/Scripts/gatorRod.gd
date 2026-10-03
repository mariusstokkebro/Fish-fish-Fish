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
var fishList: Array
func _ready() -> void:
	base_pos = position
	
func _physics_process(delta: float) -> void:
	fishList = collision.get_overlapping_bodies()
			
func _process(delta: float) -> void:
	if steering:
		var up = "p%d_move_up" % current_player
		var down = "p%d_move_down" % current_player
		var input := Input.get_axis(up, down)
		steer_offset = clamp(steer_offset + input * steerSpeed * delta, -maxSteer, maxSteer)

	position = base_pos + steerAxis * steer_offset
	
	castRod(delta)
	
	if hooking == true:
		if tween:
			tween.kill()
			reelIn()
		
		if enemyBody:
			enemyBody.getMoved(get_global_position())
		
func castRod(delta: float) -> void:
	var confirm = "p%d_confirm" % current_player
	if thrown:
		if Input.is_action_pressed(confirm):
			reelIn()
			if fishList.is_empty() == false:
				hookFish(fishList[0])
		return
	
	if Input.is_action_pressed(confirm):
		distance += 100.0 * distanceMultiplier * delta
		if ballTexture:
			ballTexture.visible = true

	if Input.is_action_just_released(confirm):
		thrown = true
		steering = true
		var target := base_pos + Vector2(distance, 0)
		distance = 10.0

		tween = create_tween()
		tween.tween_property(self, "base_pos", target, castTime)
		tween.tween_interval(2.0) 
		tween.tween_callback(func(): steering = false)

func hookFish(body: Node2D):
	var confirm = "p%d_confirm" % current_player
	if body != get_parent():
		enemyBody = body
		if Input.is_action_pressed(confirm):
			
			hooking = true

func onBodyExited(body: Node2D):
	if body == enemyBody:
		hooking = false


func reelIn():
	tween = create_tween()
	tween.tween_property(self, "base_pos", Vector2.ZERO, castTime)
	tween.parallel().tween_property(self, "steer_offset", 0.0, castTime)
	tween.tween_callback(func(): thrown = false)
	tween.tween_callback(func(): hooking = false)
