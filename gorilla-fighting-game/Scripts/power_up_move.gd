extends Node2D

var speed = 100
var dir = -1
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_up: RayCast2D = $RayCastUp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += dir * speed * delta;

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)

func _physics_process(delta: float) -> void:
	if ray_cast_down.is_colliding():
		dir = 1
		
	if ray_cast_up.is_colliding():
		dir = -1
	
	print(dir)
