extends CharacterBody2D
var fish = true
var speed = 100
var dir = -1
var hooked = false

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export_group("Movement")
@export var move_speed: float = 100.0
@export var sway_speed: float = 2.0
@export var sway_amount: float = 40.0

@export_group("Lifespan")
@export var min_invisible_time: float = 0.2
@export var max_invisible_time: float = 2.0
@export var min_active_time: float = 3.0
@export var max_active_time: float = 7.0

var is_flashing: bool = false
var fish_owner: Player

var time_alive: float = 0.0
var sway_offset: float = 0.0

@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_up: RayCast2D = $RayCastUp

func _ready() -> void:
	modulate.a = 0.0
	
	sway_offset = randf_range(0.0, 10.0)
	
	run_lifecycle()

func run_lifecycle() -> void:
	var invisible_time = randf_range(min_invisible_time, max_invisible_time)
	await get_tree().create_timer(invisible_time).timeout
	
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.5)
	await fade_in.finished
	
	var active_time = randf_range(min_active_time, max_active_time)
	await get_tree().create_timer(active_time).timeout
	
	start_despawn_sequence()

func _physics_process(delta: float) -> void:
	time_alive += delta
	
	if ray_cast_down.is_colliding():
		dir = -1
	elif ray_cast_up.is_colliding():
		dir = 1
		
	velocity.y = dir * move_speed
	
	velocity.x = sin(time_alive * sway_speed + sway_offset) * sway_amount
	
	move_and_slide()
	
	if modulate.a > 0.1:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider:
				var is_player_1 = collider.name == "PorcupineBody"
				var is_player_2 = collider.name == "PorcupineBody2"
				
				if is_player_1 and fish_owner == Player.PLAYER_2:
					print("Player 1 collected a fish!")
					queue_free()
					
				elif is_player_2 and fish_owner == Player.PLAYER_1:
					print("Player 2 collected a fish!")
					queue_free()

func start_despawn_sequence() -> void:
	if is_flashing: return
	is_flashing = true
	
	var flash_tween = create_tween().set_loops(3)
	flash_tween.tween_property(self, "modulate:a", 0.0, 0.0)
	flash_tween.tween_interval(0.2)
	flash_tween.tween_property(self, "modulate:a", 1.0, 0.0)
	flash_tween.tween_interval(0.2)
	
	await flash_tween.finished
	
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	
	queue_free()
