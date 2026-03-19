extends "res://addons/dnf_framework/state_machine/scripts/dnf_character.gd"

## 阶段三示例：带攻击和受击的角色

@export var attack_duration: int = 20
@export var attack_active_start: int = 5
@export var attack_active_end: int = 10

@onready var sprite: ColorRect = $BodyRect
@onready var state_label: Label = $StateLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var hitbox: DNFHitbox = $Hitbox

var _attack_hit_behavior_normal := DNFHitBehavior.new()
var _attack_hit_behavior_heavy := DNFHitBehavior.new()
var _current_attack_type: int = 0

const COLOR_IDLE := Color(0.2, 0.5, 0.8)
const COLOR_WALK := Color(0.3, 0.6, 0.8)
const COLOR_RUN := Color(0.2, 0.4, 0.9)
const COLOR_JUMP := Color(0.4, 0.7, 0.9)
const COLOR_ATTACK := Color(0.9, 0.3, 0.2)
const COLOR_HIT := Color(0.9, 0.8, 0.2)
const COLOR_KNOCK := Color(0.8, 0.5, 0.1)
const COLOR_DOWN := Color(0.5, 0.2, 0.1)
const COLOR_GETUP := Color(0.6, 0.6, 0.6)


func _ready() -> void:
	health = max_health

	_attack_hit_behavior_normal.damage = 8
	_attack_hit_behavior_normal.hit_type = DNFHitBehavior.HitType.NORMAL
	_attack_hit_behavior_normal.hitstun_frames = 15
	_attack_hit_behavior_normal.hitstop_frames = 4
	_attack_hit_behavior_normal.knockback_force = 4.0
	_attack_hit_behavior_normal.self_knockback = 1.5

	_attack_hit_behavior_heavy.damage = 20
	_attack_hit_behavior_heavy.hit_type = DNFHitBehavior.HitType.LAUNCH
	_attack_hit_behavior_heavy.hitstun_frames = 30
	_attack_hit_behavior_heavy.hitstop_frames = 6
	_attack_hit_behavior_heavy.knockback_force = 5.0
	_attack_hit_behavior_heavy.launch_force = -18.0
	_attack_hit_behavior_heavy.self_knockback = 2.0

	if hitbox:
		hitbox.deactivate()


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


func _state_input_check() -> void:
	if current_state == DNFStates.State.ATTACK:
		return
	super._state_input_check()
	if DNFStates.is_hit_state(current_state):
		return

	if current_state in [DNFStates.State.IDLE, DNFStates.State.WALK, DNFStates.State.RUN]:
		if Input.is_action_just_pressed("player1_punch"):
			_start_attack(0)
			return
		if Input.is_action_just_pressed("player1_kick") and Input.is_action_just_pressed("player1_punch"):
			_start_attack(1)
			return


func _start_attack(attack_type: int) -> void:
	_current_attack_type = attack_type
	_change_state(DNFStates.State.ATTACK)
	velocity.x = (2.0 if facing_right else -2.0)

	if hitbox:
		hitbox.hit_behavior = _attack_hit_behavior_normal if attack_type == 0 else _attack_hit_behavior_heavy


func _state_process() -> void:
	match current_state:
		DNFStates.State.ATTACK:
			if state_tick >= attack_active_start and state_tick < attack_active_end:
				if hitbox:
					hitbox.activate()
			else:
				if hitbox:
					hitbox.deactivate()
			if state_tick >= attack_duration:
				if hitbox:
					hitbox.deactivate()
				_change_state(DNFStates.State.IDLE)
				velocity.x = 0.0
			else:
				velocity.x = lerpf(velocity.x, 0.0, 0.1)
		_:
			if hitbox and hitbox.active:
				hitbox.deactivate()
			super._state_process()


func _on_state_enter(new_state: int, old_state: int) -> void:
	if hitbox and new_state != DNFStates.State.ATTACK:
		hitbox.deactivate()


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	_update_visuals()


func _update_visuals() -> void:
	if sprite:
		var c: Color
		match current_state:
			DNFStates.State.IDLE: c = COLOR_IDLE
			DNFStates.State.WALK: c = COLOR_WALK
			DNFStates.State.RUN: c = COLOR_RUN
			DNFStates.State.JUMP, DNFStates.State.FALL: c = COLOR_JUMP
			DNFStates.State.ATTACK: c = COLOR_ATTACK
			DNFStates.State.HIT_STUN: c = COLOR_HIT
			DNFStates.State.KNOCK_BACK: c = COLOR_KNOCK
			DNFStates.State.KNOCK_DOWN: c = COLOR_DOWN
			DNFStates.State.AIR_BORNE: c = COLOR_HIT
			DNFStates.State.GET_UP: c = COLOR_GETUP
			_: c = COLOR_IDLE
		sprite.color = c

	if state_label:
		state_label.text = get_state_name() + " [" + str(state_tick) + "]"
		if hitstop_remaining > 0:
			state_label.text += " HITSTOP"

	if health_bar:
		health_bar.value = float(health) / float(max_health) * 100.0
