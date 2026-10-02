extends Node2D
@export var ballTexture: Sprite2D
@export var player: CharacterBody2D
@export var collider: CollisionShape2D
@export var castTime: float
@export var distanceMultiplier: float
var distance = 10
var thrown: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	castRod()
	realIn()

func castRod():
	if thrown == false:
		if Input.is_action_pressed("ui_accept"):
			distance += 1 * distanceMultiplier
			ballTexture.visible = true
		if Input.is_action_just_released("ui_accept"):
			var timer = 0.0
			var originalPosition = get_position()
			while timer < castTime:
				var newPosition = lerp(originalPosition.x,originalPosition.x + distance,timer/castTime)
				set_position(Vector2(newPosition,0))
				timer += get_process_delta_time()		
			distance = 10		
			thrown = true	
			
func realIn():
	if thrown == true:
		print_debug(thrown)
		await get_tree().create_timer(2).timeout
		set_position(Vector2(0,0))
		thrown = false
	
