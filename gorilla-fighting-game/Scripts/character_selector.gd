extends Node

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export var current_player: Player = Player.PLAYER_1
@export var character_squares: Array[Sprite2D] = []

@export_group("Display Connections")
@export var main_display_hex: Sprite2D
@export var hook_sprite: Sprite2D

@export_group("UI Connections")
@export var ready_indicator: CanvasItem
@export var play_button: CanvasItem

var current_index: int = 0
var move_timer: float = 0.0
const MOVE_DELAY: float = 0.25
var has_confirmed: bool = false

func _ready() -> void:
	add_to_group("player_selectors")
	
	if ready_indicator:
		ready_indicator.hide()
		
	if not character_squares.is_empty():
		update_selection(0)
		
	if main_display_hex and hook_sprite:
		main_display_hex.global_position = hook_sprite.global_position
		
	call_deferred("update_play_button_state")

func _process(delta: float) -> void:
	if character_squares.is_empty(): return

	var up = "p%d_move_up" % current_player
	var down = "p%d_move_down" % current_player
	var left = "p%d_move_left" % current_player
	var right = "p%d_move_right" % current_player
	var confirm = "p%d_confirm" % current_player

	if has_confirmed:
		if Input.is_action_just_pressed(right) or Input.is_action_just_pressed(left) or Input.is_action_just_pressed(up) or Input.is_action_just_pressed(down):
			has_confirmed = false
			if main_display_hex:
				main_display_hex.modulate = Color(1, 1, 1, 1)
			if ready_indicator:
				ready_indicator.hide()
			
			update_play_button_state()
			return
			
		elif Input.is_action_just_pressed(confirm):
			if check_all_players_ready():
				get_tree().change_scene_to_file("res://Scenes/level.tscn")
		return

	if Input.is_action_just_pressed(confirm):
		has_confirmed = true
		if main_display_hex:
			main_display_hex.modulate = Color(0.4, 0.4, 0.4, 1)
		if ready_indicator:
			ready_indicator.show()
			
		update_play_button_state()
		return

	move_timer -= delta
	if move_timer > 0.0:
		return

	var new_index = current_index
	var input_detected = false
	
	if Input.is_action_pressed(right) or Input.is_action_pressed(down):
		new_index += 1
		input_detected = true
	elif Input.is_action_pressed(left) or Input.is_action_pressed(up):
		new_index -= 1
		input_detected = true
		
	if input_detected:
		if new_index >= character_squares.size():
			new_index = 0
		elif new_index < 0:
			new_index = character_squares.size() - 1
				
		if new_index != current_index:
			update_selection(new_index)
			
		move_timer = MOVE_DELAY
	else:
		move_timer = 0.0

func update_selection(new_index: int) -> void:
	if character_squares[current_index]:
		character_squares[current_index].modulate = Color(1, 1, 1, 1)
		
	current_index = new_index
	var selected_square = character_squares[current_index]
	
	if selected_square:
		if current_player == Player.PLAYER_1:
			selected_square.modulate = Color(0, 1, 0, 1)
		else:
			selected_square.modulate = Color(1, 0, 0, 1)
			
		if main_display_hex:
			main_display_hex.texture = selected_square.texture

func check_all_players_ready() -> bool:
	var selectors = get_tree().get_nodes_in_group("player_selectors")
	for selector in selectors:
		if not selector.has_confirmed:
			return false
	return true

func update_play_button_state() -> void:
	var selectors = get_tree().get_nodes_in_group("player_selectors")
	for selector in selectors:
		if selector.play_button:
			if check_all_players_ready():
				selector.play_button.modulate = Color(1, 1, 1, 1)
			else:
				selector.play_button.modulate = Color(0.3, 0.3, 0.3, 1)
