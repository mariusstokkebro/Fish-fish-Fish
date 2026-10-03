extends CharacterBody2D
var hooked = false
const SPEED = 300.0
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

		
@export var current_player: Player = Player.PLAYER_1
func _ready() -> void:
	startPosition = position
	if current_player == Player.PLAYER_1 and Global.p1_texture != null:
		sprite.texture = Global.p1_texture
	elif current_player == Player.PLAYER_2 and Global.p2_texture != null:
		sprite.texture = Global.p2_texture
func _physics_process(_delta: float) -> void:
	if WinManager.reset == true:
		tpBackToOrigin()
	var up = "p%d_move_up" % current_player
	var down = "p%d_move_down" % current_player
	var left = "p%d_move_left" % current_player
	var right = "p%d_move_right" % current_player

	var directionY := Input.get_axis(up, down)
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var directionX := Input.get_axis(left, right)
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if hooked:
		resist(_delta)
		

func _process(float) -> void:
	if velocity != Vector2(0.0, 0.0) && !sound_move.playing:
		sound_move.play()
	else: 
		if sound_move.playing && velocity == Vector2(0.0, 0.0):
			sound_move.stop()

func getMoved(movement:Vector2,bait:Node2D):
	currentBait = bait
	set_global_position(movement)
	
	
func tpBackToOrigin():
	if hooked == true:
		currentBait.hooking = false
		hooked = false
	set_position(startPosition)
		
	
func Hooked():
	sound_hooked.play()
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
	
