extends Node2D

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export var spawner_owner: Player = Player.PLAYER_1
@export var spawn_interval: float = 4.0
@export var spawn_y_variance: float = 150.0

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
		timer = spawn_interval + randf_range(-1.0, 1.0)

func spawn_objects() -> void:
	var template = spawn_pool.pick_random()
	var spawned_obj = template.duplicate()
	add_child(spawned_obj)
	
	spawned_obj.fish_owner = spawner_owner
	
	var random_y_offset = randf_range(-spawn_y_variance, spawn_y_variance)
	spawned_obj.global_position = global_position + Vector2(0, random_y_offset)
