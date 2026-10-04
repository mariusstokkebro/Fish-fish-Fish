extends CharacterBody2D

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export_group("Movement")
@export var base_move_speed: float = 100.0
@export var sway_speed: float = 4.0
@export var sway_amount: float = 60.0

@export_group("Lifespan")
@export var min_invisible_time: float = 0.2
@export var max_invisible_time: float = 2.0
@export var min_active_time: float = 5.0 
@export var max_active_time: float = 15.0 

@export var powerup_type: String = "sardine"

var fish = true
var move_speed: float = 100.0
var dir = -1
var hooked = false
var was_hooked = false
var currentBait: Node2D
var is_flashing: bool = false
var fish_owner: int 
var time_alive: float = 0.0
var sway_offset: float = 0.0
var target_opacity: float = 1.0
var base_color: Color

var has_stunned_p1: bool = false
var has_stunned_p2: bool = false
var p1_node: Node2D
var p2_node: Node2D

var flash_tween: Tween 

@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_up: RayCast2D = $RayCastUp

func _ready() -> void:
	modulate.a = 0.0
	sway_offset = randf_range(0.0, 10.0)
	
	var root = get_tree().current_scene
	if root:
		p1_node = root.find_child("PorcupineBody", true, false)
		p2_node = root.find_child("PorcupineBody2", true, false)
		
		if p1_node: add_collision_exception_with(p1_node)
		if p2_node: add_collision_exception_with(p2_node)
	
	if powerup_type == "fly":
		move_speed = base_move_speed * 4.5
		sway_amount = 20.0
		target_opacity = 0.9 
		base_color = Color(1.0, 1.0, 1.0, target_opacity)
		modulate = Color(1.0, 1.0, 1.0, 0.0)
	else:
		move_speed = base_move_speed
		target_opacity = randf_range(0.15, 0.8)
		var shade = randf_range(0.2, 0.85)
		base_color = Color(shade, shade, shade, target_opacity)
		modulate = Color(shade, shade, shade, 0.0)
		
	run_lifecycle()

func run_lifecycle() -> void:
	var invisible_time = randf_range(min_invisible_time, max_invisible_time)
	await get_tree().create_timer(invisible_time).timeout
	
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate:a", target_opacity, 0.5)
	await fade_in.finished
	
	var weight = sqrt(randf())
	var active_time = lerp(min_active_time, max_active_time, weight)
	
	await get_tree().create_timer(active_time).timeout
	
	start_despawn_sequence()

func _physics_process(delta: float) -> void:
	if not hooked:
		if was_hooked:
			was_hooked = false
			modulate = base_color
			is_flashing = false
			start_despawn_sequence()
			
		time_alive += delta
		
		if ray_cast_down.is_colliding():
			dir = -1
		elif ray_cast_up.is_colliding():
			dir = 1
			
		velocity.y = dir * move_speed
		
		var current_sway = sway_amount
		if powerup_type != "fly":
			current_sway += randf_range(-15.0, 15.0) 
			
		velocity.x = sin(time_alive * sway_speed + sway_offset) * current_sway
		
		move_and_slide()
		
		if powerup_type == "fly" and modulate.a > 0.1:
			var stun_radius = 100.0 
			
			if p1_node and not has_stunned_p1 and global_position.distance_to(p1_node.global_position) < stun_radius:
				has_stunned_p1 = true
				if p1_node.has_method("apply_stun"):
					p1_node.apply_stun(2.0)
					
			if p2_node and not has_stunned_p2 and global_position.distance_to(p2_node.global_position) < stun_radius:
				has_stunned_p2 = true
				if p2_node.has_method("apply_stun"):
					p2_node.apply_stun(2.0)

func start_despawn_sequence() -> void:
	if is_flashing or hooked: return
	is_flashing = true
	
	flash_tween = create_tween().set_loops(3)
	flash_tween.tween_property(self, "modulate:a", 0.0, 0.0)
	flash_tween.tween_interval(0.2)
	flash_tween.tween_property(self, "modulate:a", target_opacity, 0.0)
	flash_tween.tween_interval(0.2)
	
	await flash_tween.finished
	
	if hooked: return 
	
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	
	if not hooked:
		queue_free()

func Hooked() -> void:
	if powerup_type == "fly": return
	
	hooked = true
	was_hooked = true
	modulate = Color(1.0, 1.0, 1.0, 1.0) 
	
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()

func getMoved(movement: Vector2, bait: Node2D) -> void:
	currentBait = bait
	global_position = movement
