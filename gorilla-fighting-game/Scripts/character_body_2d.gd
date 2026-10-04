extends CharacterBody2D
var hooked = false
var speed: float = 300.0
var wobble_time: float = 0.0
var is_stunned: bool = false
var startPosition
var rotationSpeed: float = 0.0
var lastAngle: float = 0.0
var resistSpeed: float = 0.2
var currentBait: Node2D
var fish = true
enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var sound_hooked: AudioStreamPlayer2D = $Audio/HookedSound
@onready var sound_move: AudioStreamPlayer2D = $Audio/MoveSound
var playedHookSound: bool = false

@export var current_player: Player = Player.PLAYER_1

func _ready() -> void:
	Global.inMenu = false
	startPosition = position
	if current_player == Player.PLAYER_1 and Global.p1_texture != null:
		sprite.texture = Global.p1_texture
	elif current_player == Player.PLAYER_2 and Global.p2_texture != null:
		sprite.texture = Global.p2_texture

func _physics_process(_delta: float) -> void:
	if WinManager.reset == true:
		tpBackToOrigin()
		
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var up = "p%d_move_up" % current_player
	var down = "p%d_move_down" % current_player
	var left = "p%d_move_left" % current_player
	var right = "p%d_move_right" % current_player

	var directionY := Input.get_axis(up, down)
	if directionY:
		velocity.y = directionY * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	var directionX := Input.get_axis(left, right)
	if directionX:
		velocity.x = directionX * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	if hooked:
		resist(_delta)

func _process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		wobble_time += delta * 15.0
		sprite.rotation = sin(wobble_time) * 0.1
		if !sound_move.playing:
			sound_move.play()
	else:
		sprite.rotation = 0.0
		if sound_move.playing:
			sound_move.stop()

func apply_stun(duration: float) -> void:
	if is_stunned: return
	is_stunned = true
	await get_tree().create_timer(duration).timeout
	is_stunned = false

func getMoved(movement:Vector2,bait:Node2D):
	currentBait = bait
	set_global_position(movement)
	
func tpBackToOrigin():
	if hooked == true:
		currentBait.hooking = false
		hooked = false
		playedHookSound = false
	set_position(startPosition)
		
func Hooked():
	if !playedHookSound:
		sound_hooked.play()
		playedHookSound = true
	hooked = true

func resist(delta):
	var currentPosition = currentBait.base_pos
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
	var newPosition = Vector2(currentPosition.x + resistSpeed * rotationSpeed,currentPosition.y)
	currentBait.base_pos = newPosition
