extends "res://addons/dnf_framework/state_machine/scripts/dnf_character.gd"

## 阶段二示例：使用状态机的角色

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateLabel

var _anim_map: Dictionary = {}


func _ready() -> void:
	_anim_map = {
		DNFStates.State.IDLE: "idle",
		DNFStates.State.WALK: "walk",
		DNFStates.State.RUN: "run",
		DNFStates.State.JUMP: "jump",
		DNFStates.State.FALL: "fall",
		DNFStates.State.LAND: "land",
		DNFStates.State.DASH: "dash",
	}


func _get_move_direction() -> float:
	var dir := 0.0
	if Input.is_action_pressed("player1_right"):
		dir += 1.0
	if Input.is_action_pressed("player1_left"):
		dir -= 1.0
	return dir


func _is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("player1_up")


func _is_run_held() -> bool:
	return Input.is_action_pressed("player1_kick")


func _is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("player1_bomb")


func _on_state_enter(new_state: int, _old_state: int) -> void:
	_sync_animation(new_state)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	_update_sprite_flip()
	_update_label()


func _sync_animation(state: int) -> void:
	if not sprite or not sprite.sprite_frames:
		return
	var anim_name: String = _anim_map.get(state, "idle")
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	elif sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _update_sprite_flip() -> void:
	if sprite:
		sprite.flip_h = not facing_right


func _update_label() -> void:
	if not state_label:
		return
	state_label.text = get_state_name() + " [" + str(state_tick) + "]"
