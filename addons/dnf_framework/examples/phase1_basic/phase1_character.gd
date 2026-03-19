extends "res://addons/dnf_framework/frame_physics/scripts/frame_character_body2d.gd"

## 阶段一示例角色：行走、跳跃、帧动画

@export var move_speed: float = 5.0
@export var jump_speed: float = -14.0
@export var run_speed: float = 9.0

@onready var anim_player: FrameAnimationPlayer = $FrameAnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var input_buf: InputBuffer = $InputBuffer
@onready var label: Label = $Label

var _facing_right: bool = true


func _physics_process(_delta: float) -> void:
	_collect_input()

	var dir := 0.0
	if Input.is_action_pressed("player1_right"):
		dir += 1.0
	if Input.is_action_pressed("player1_left"):
		dir -= 1.0

	var is_running := Input.is_action_pressed("player1_kick")

	velocity.x = dir * (run_speed if is_running else move_speed)

	if Input.is_action_just_pressed("player1_up") and is_on_floor():
		velocity.y = jump_speed

	super._physics_process(_delta)
	_update_animation(dir, is_running)
	_update_facing(dir)
	_update_label()


func _collect_input() -> void:
	if Input.is_action_just_pressed("player1_punch"):
		input_buf.add_input("punch")
	if Input.is_action_just_pressed("player1_kick"):
		input_buf.add_input("kick")
	if Input.is_action_just_pressed("player1_up"):
		input_buf.add_input("jump")


func _update_animation(dir: float, is_running: bool) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			_play_anim("jump")
		else:
			_play_anim("fall")
	elif abs(dir) > 0.01:
		if is_running:
			_play_anim("run")
		else:
			_play_anim("walk")
	else:
		_play_anim("idle")


func _play_anim(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


func _update_facing(dir: float) -> void:
	if dir > 0.01:
		_facing_right = true
		if sprite:
			sprite.flip_h = false
	elif dir < -0.01:
		_facing_right = false
		if sprite:
			sprite.flip_h = true


func _update_label() -> void:
	if not label:
		return
	var state_text := "IDLE"
	if not is_on_floor():
		state_text = "JUMP" if velocity.y < 0 else "FALL"
	elif abs(velocity.x) > run_speed - 1:
		state_text = "RUN"
	elif abs(velocity.x) > 0.5:
		state_text = "WALK"
	label.text = state_text + "\nFrame: " + str(get_frame_count())
