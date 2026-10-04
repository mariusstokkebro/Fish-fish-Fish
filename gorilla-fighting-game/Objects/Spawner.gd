extends Node2D

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

enum SpawnDirection {
	BOTTOM_TO_TOP,
	TOP_TO_BOTTOM,
	RANDOM
}

@export var spawner_owner: Player = Player.PLAYER_1
@export var spawn_direction: SpawnDirection = SpawnDirection.BOTTOM_TO_TOP
@export var spawn_interval: float = 4.0
@export var spawn_x_variance: float = 250.0
@export var spawn_y_variance: float = 150.0
@export var chaos_factor: float = 2.0 

var timer: float = 0.0
var spawn_pool: Array[Node] = []

func _ready() -> void:
	for child in get_children():
		spawn_pool.append(child)
		remove_child(child)

func _process(delta: float) -> void:
	if spawn_pool.is_empty(): return
		
	timer -= delta
	if timer <= 0.0:
		spawn_objects()
		timer = spawn_interval + randf_range(-chaos_factor, chaos_factor)
		if timer < 0.5: timer = 0.5 

func spawn_objects() -> void:
	var template = spawn_pool.pick_random()
	var spawned_obj = template.duplicate()
	add_child(spawned_obj)
	
	spawned_obj.fish_owner = spawner_owner as int
	
	if spawner_owner == Player.PLAYER_1:
		var sprite = spawned_obj.get_node("Sprite2D")
		sprite.flip_h = true
	
	var start_dir = -1
	match spawn_direction:
		SpawnDirection.BOTTOM_TO_TOP:
			start_dir = -1
		SpawnDirection.TOP_TO_BOTTOM:
			start_dir = 1
		SpawnDirection.RANDOM:
			start_dir = [-1, 1].pick_random()
			
	if "dir" in spawned_obj:
		spawned_obj.dir = start_dir
		
	if "move_speed" in spawned_obj:
		spawned_obj.move_speed += randf_range(-chaos_factor * 15, chaos_factor * 15)
	
	var random_x_offset = randf_range(-spawn_x_variance, spawn_x_variance)
	var random_y_offset = randf_range(-spawn_y_variance, spawn_y_variance)
	
	spawned_obj.global_position = global_position + Vector2(random_x_offset, random_y_offset)
