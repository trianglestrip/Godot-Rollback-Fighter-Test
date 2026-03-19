extends "res://addons/dnf_framework/state_machine/scripts/dnf_character.gd"

## 阶段四示例：连招取消系统
## J = 轻攻击（可取消到重攻击）
## K = 重攻击（可取消到上挑）
## J在攻击中 = 连段取消

@onready var body_rect: ColorRect = $BodyRect
@onready var state_label: Label = $StateLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var hitbox: DNFHitbox = $Hitbox
@onready var combo_label: Label = $ComboLabel

var _move_light: DNFMove
var _move_heavy: DNFMove
var _move_launcher: DNFMove

var _combo_count: int = 0
var _combo_timer: int = 0
const COMBO_TIMEOUT := 60

var _hit_light := DNFHitBehavior.new()
var _hit_heavy := DNFHitBehavior.new()
var _hit_launcher := DNFHitBehavior.new()

const COLOR_IDLE := Color(0.2, 0.5, 0.8)
const COLOR_WALK := Color(0.3, 0.6, 0.8)
const COLOR_RUN := Color(0.2, 0.4, 0.9)
const COLOR_JUMP := Color(0.4, 0.7, 0.9)
const COLOR_ATTACK := Color(0.9, 0.3, 0.2)
const COLOR_HIT := Color(0.9, 0.8, 0.2)


func _ready() -> void:
	health = max_health
	_setup_hit_behaviors()
	_setup_moves()
	if hitbox:
		hitbox.deactivate()


func _setup_hit_behaviors() -> void:
	_hit_light.damage = 5
	_hit_light.hit_type = DNFHitBehavior.HitType.NORMAL
	_hit_light.hitstun_frames = 12
	_hit_light.hitstop_frames = 3
	_hit_light.knockback_force = 2.0
	_hit_light.self_knockback = 1.0

	_hit_heavy.damage = 12
	_hit_heavy.hit_type = DNFHitBehavior.HitType.KNOCK_BACK
	_hit_heavy.hitstun_frames = 20
	_hit_heavy.hitstop_frames = 5
	_hit_heavy.knockback_force = 6.0
	_hit_heavy.self_knockback = 2.0

	_hit_launcher.damage = 15
	_hit_launcher.hit_type = DNFHitBehavior.HitType.LAUNCH
	_hit_launcher.hitstun_frames = 30
	_hit_launcher.hitstop_frames = 6
	_hit_launcher.knockback_force = 3.0
	_hit_launcher.launch_force = -20.0
	_hit_launcher.self_knockback = 2.0


func _setup_moves() -> void:
	var cond_punch := DNFInputEqualCheck.new()
	cond_punch.input_name = "punch"
	cond_punch.input_value = true

	var cond_kick := DNFInputEqualCheck.new()
	cond_kick.input_name = "kick"
	cond_kick.input_value = true

	_move_light = DNFMove.new()
	_move_light.move_name = "light_attack"
	_move_light.input_conditions = [cond_punch]
	_move_light.state = DNFStates.State.ATTACK
	_move_light.duration = 18
	_move_light.active_start = 4
	_move_light.active_end = 8
	_move_light.hit_behavior = _hit_light
	_move_light.forward_impulse = 2.0

	_move_heavy = DNFMove.new()
	_move_heavy.move_name = "heavy_attack"
	_move_heavy.input_conditions = [cond_kick]
	_move_heavy.state = DNFStates.State.ATTACK
	_move_heavy.duration = 25
	_move_heavy.active_start = 6
	_move_heavy.active_end = 12
	_move_heavy.hit_behavior = _hit_heavy
	_move_heavy.forward_impulse = 3.0

	_move_launcher = DNFMove.new()
	_move_launcher.move_name = "launcher"
	_move_launcher.input_conditions = [cond_punch]
	_move_launcher.state = DNFStates.State.ATTACK
	_move_launcher.duration = 30
	_move_launcher.active_start = 5
	_move_launcher.active_end = 10
	_move_launcher.hit_behavior = _hit_launcher
	_move_launcher.forward_impulse = 1.0

	available_moves = [_move_light, _move_heavy, _move_launcher]


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
	return false


func _is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("player1_bomb")


func _get_input_dict() -> Dictionary:
	return {
		"punch": Input.is_action_just_pressed("player1_punch"),
		"kick": Input.is_action_just_pressed("player1_kick"),
	}


func _state_input_check() -> void:
	if current_state == DNFStates.State.ATTACK and _current_move:
		var input_dict := _get_input_dict()
		if try_cancel(input_dict):
			return
		return

	super._state_input_check()

	if DNFStates.is_hit_state(current_state):
		return

	if current_state in [DNFStates.State.IDLE, DNFStates.State.WALK, DNFStates.State.RUN]:
		var input_dict := _get_input_dict()
		for move in available_moves:
			if move.move_name in ["light_attack", "heavy_attack"] and move.check_input(input_dict):
				execute_move(move)
				return


func _state_process() -> void:
	if current_state == DNFStates.State.ATTACK and _current_move:
		if state_tick >= _current_move.active_start and state_tick < _current_move.active_end:
			if hitbox:
				hitbox.hit_behavior = _current_move.hit_behavior
				hitbox.activate()
		else:
			if hitbox:
				hitbox.deactivate()

		_update_cancel_windows()

		if state_tick >= _current_move.duration:
			if hitbox:
				hitbox.deactivate()
			_current_move = null
			_change_state(DNFStates.State.IDLE)
			velocity.x = 0.0
		else:
			velocity.x = lerpf(velocity.x, 0.0, 0.08)
		return

	if hitbox and hitbox.active:
		hitbox.deactivate()
	super._state_process()


func _update_cancel_windows() -> void:
	if _current_move == null:
		return

	if _current_move.move_name == "light_attack":
		if state_tick >= 8 and state_tick < 16:
			available_cancels = ["heavy_attack", "launcher"]
		else:
			available_cancels.clear()

	elif _current_move.move_name == "heavy_attack":
		if state_tick >= 12 and state_tick < 22:
			available_cancels = ["launcher"]
		else:
			available_cancels.clear()

	elif _current_move.move_name == "launcher":
		available_cancels.clear()


func on_hit_landed(target: Node, behavior: DNFHitBehavior) -> void:
	super.on_hit_landed(target, behavior)
	_combo_count += 1
	_combo_timer = COMBO_TIMEOUT


func _on_state_enter(new_state: int, old_state: int) -> void:
	super._on_state_enter(new_state, old_state)
	if hitbox and new_state != DNFStates.State.ATTACK:
		hitbox.deactivate()


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)

	if _combo_timer > 0:
		_combo_timer -= 1
		if _combo_timer <= 0:
			_combo_count = 0

	_update_visuals()


func _update_visuals() -> void:
	if body_rect:
		var c: Color
		match current_state:
			DNFStates.State.IDLE: c = COLOR_IDLE
			DNFStates.State.WALK: c = COLOR_WALK
			DNFStates.State.RUN: c = COLOR_RUN
			DNFStates.State.JUMP, DNFStates.State.FALL: c = COLOR_JUMP
			DNFStates.State.ATTACK: c = COLOR_ATTACK
			_:
				if DNFStates.is_hit_state(current_state):
					c = COLOR_HIT
				else:
					c = COLOR_IDLE
		body_rect.color = c

	if state_label:
		var move_name := ""
		if _current_move:
			move_name = " (" + _current_move.move_name + ")"
		state_label.text = get_state_name() + move_name + " [" + str(state_tick) + "]"
		if not available_cancels.is_empty():
			state_label.text += " CAN CANCEL"
		if hitstop_remaining > 0:
			state_label.text += " HITSTOP"

	if health_bar:
		health_bar.value = float(health) / float(max_health) * 100.0

	if combo_label:
		if _combo_count > 1:
			combo_label.text = str(_combo_count) + " HITS!"
			combo_label.visible = true
		else:
			combo_label.visible = false
