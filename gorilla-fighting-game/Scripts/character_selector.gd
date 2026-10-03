extends Node

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export var current_player: Player = Player.PLAYER_1
@export var character_squares: Array[Sprite2D] = []

@export_group("Display Connections")
@export var hook_sprite: Sprite2D

@export_group("UI Connections")
@export var ready_indicator: CanvasItem
@export var play_button: CanvasItem

@export_group("Animation Settings")
@export var hover_rot_degrees: float = 8.0
@export var hooked_scale_mult: float = 1.5

@onready var fish1_sound: AudioStreamPlayer = $"Audio/fish1"
@onready var fish2_sound: AudioStreamPlayer = $"Audio/fish2"
@onready var fish3_sound: AudioStreamPlayer = $"Audio/fish3"
@onready var fish4_sound: AudioStreamPlayer = $"Audio/fish4"
@onready var fish5_sound: AudioStreamPlayer = $"Audio/fish5"
@onready var fish6_sound: AudioStreamPlayer = $"Audio/fish6"
@onready var sound_transition: AudioStreamPlayer = $Audio/Transition

var current_index: int = 0
var move_timer: float = 0.0
const MOVE_DELAY: float = 0.25
var has_confirmed: bool = false

var select_tween: Tween 
var hover_tween: Tween 

var original_scales: Array[Vector2] = []
var original_positions: Array[Vector2] = []

func _ready() -> void:
	add_to_group("player_selectors")
	
	Global.inMenu = true
	
	for square in character_squares:
		if square:
			original_scales.append(square.scale)
			original_positions.append(square.global_position)
			_set_sprite_variant(square, false)
		else:
			original_scales.append(Vector2.ONE)
			original_positions.append(Vector2.ZERO)
	
	if ready_indicator:
		ready_indicator.hide()
		
	if not character_squares.is_empty():
		update_selection(0, true)
		
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
			if ready_indicator:
				ready_indicator.hide()
			
			if select_tween and select_tween.is_valid():
				select_tween.kill()
				
			select_tween = create_tween().set_parallel(true)
			
			for i in range(character_squares.size()):
				if character_squares[i]:
					character_squares[i].modulate = Color(1, 1, 1, 1)
					if i != current_index:
						select_tween.tween_property(character_squares[i], "scale", original_scales[i], 0.2)
						select_tween.tween_property(character_squares[i], "rotation_degrees", 0.0, 0.2)
			
			if character_squares[current_index]:
				select_tween.tween_property(character_squares[current_index], "global_position", original_positions[current_index], 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				select_tween.tween_property(character_squares[current_index], "scale", original_scales[current_index], 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			update_selection(current_index, false)
			update_play_button_state()
			return
			
		elif Input.is_action_just_pressed(confirm):
			if check_all_players_ready():
				Global.inMenu = false
				var selectors = get_tree().get_nodes_in_group("player_selectors")
				for selector in selectors:
					var active_square = selector.character_squares[selector.current_index]
					var chosen_tex = active_square.texture
					
					var suffix = "_1" if selector.current_player == Player.PLAYER_1 else "_2"
					for child in active_square.get_children():
						if child is Sprite2D and child.name.ends_with(suffix):
							chosen_tex = child.texture
							break
					
					if selector.current_player == Player.PLAYER_1:
						Global.p1_texture = chosen_tex
					else:
						Global.p2_texture = chosen_tex
				
				get_tree().change_scene_to_file("res://level.tscn")
		return


	if Input.is_action_just_pressed(confirm):
		playFishSound(current_index)
		has_confirmed = true
		
		if hover_tween and hover_tween.is_valid():
			hover_tween.kill()
			
		for i in range(character_squares.size()):
			if i != current_index and character_squares[i]:
				character_squares[i].modulate = Color(0.3, 0.3, 0.3, 1)
				
		if ready_indicator:
			ready_indicator.show()
			
		update_play_button_state()
		
		if select_tween and select_tween.is_valid():
			select_tween.kill()
		select_tween = create_tween().set_parallel(true)
		
		if character_squares[current_index] and hook_sprite:
			var target_scale = original_scales[current_index] * hooked_scale_mult
			select_tween.tween_property(character_squares[current_index], "global_position", hook_sprite.global_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			select_tween.tween_property(character_squares[current_index], "scale", target_scale, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			select_tween.tween_property(character_squares[current_index], "rotation_degrees", 0.0, 0.4)
			
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
			update_selection(new_index, true)
			
		move_timer = MOVE_DELAY
	else:
		move_timer = 0.0


func playFishSound(int) -> void:
	if int == 0:
		fish1_sound.play()
	if int == 1:
		fish2_sound.play()
	if int == 2:
		fish3_sound.play()
	if int == 3:
		fish4_sound.play()
	if int == 4:
		fish5_sound.play()	
	if int == 5:
		fish6_sound.play()

func update_selection(new_index: int, is_new_movement: bool = false) -> void:
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
		
	var old_index = current_index
	var old_square = character_squares[old_index]
	
	if old_square:
		old_square.modulate = Color(1, 1, 1, 1)
		
		if not has_confirmed and is_new_movement:
			_set_sprite_variant(old_square, false)
			var reset_tween = create_tween().set_parallel(true)
			reset_tween.tween_property(old_square, "scale", original_scales[old_index], 0.15)
			reset_tween.tween_property(old_square, "rotation_degrees", 0.0, 0.15)
		
	current_index = new_index
	var selected_square = character_squares[current_index]
	
	if selected_square:
		selected_square.modulate = Color(1, 1, 1, 1)
		
		if not has_confirmed:
			_set_sprite_variant(selected_square, true)
			
			hover_tween = create_tween().set_loops()
			hover_tween.tween_property(selected_square, "rotation_degrees", hover_rot_degrees, 0.3).set_trans(Tween.TRANS_SINE)
			hover_tween.tween_property(selected_square, "rotation_degrees", -hover_rot_degrees, 0.3).set_trans(Tween.TRANS_SINE)

func _set_sprite_variant(square: Sprite2D, is_active: bool) -> void:
	var suffix = "_1" if current_player == Player.PLAYER_1 else "_2"
	
	for child in square.get_children():
		if child is Sprite2D:
			if child.name.ends_with("_1") or child.name.ends_with("_2"):
				child.visible = false 
				if is_active and child.name.ends_with(suffix):
					child.visible = true

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
