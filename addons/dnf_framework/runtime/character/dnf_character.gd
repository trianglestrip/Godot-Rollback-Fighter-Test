class_name DNFCharacter
extends "res://addons/dnf_framework/runtime/physics/frame_character_body2d.gd"

## DNF 风格角色基类，集成状态机、输入、动画

signal on_state_changed(new_state: int, old_state: int)
signal on_hit_received(behavior: DNFHitBehavior, direction: float)
signal on_hit_dealt(target: Node, behavior: DNFHitBehavior)

@export var move_speed: float = 5.0
@export var run_speed: float = 9.0
@export var jump_speed: float = -14.0
@export var dash_speed: float = 12.0
@export var land_frames: int = 4
@export var max_health: int = 100

var current_state: int = DNFStates.State.IDLE
var state_tick: int = 0
var facing_right: bool = true
var health: int = 100
var hitstop_remaining: int = 0
var _previous_state: int = DNFStates.State.IDLE
var _hitstun_duration: int = 12

var available_moves: Array[DNFMove] = []
var _current_move: DNFMove = null
var _has_hit_this_attack: bool = false
## 当前激活的取消窗口（由 SkillComponent 或外部设置）
var _active_cancel_windows: Array = []
## 当前技能帧（由 SkillComponent 同步）
var _skill_frame: int = -1


func _physics_process(_delta: float) -> void:
	if hitstop_remaining > 0:
		hitstop_remaining -= 1
		return

	_previous_state = current_state

	_state_input_check()
	_state_process()
	super._physics_process(_delta)
	_post_physics_check()

	state_tick += 1


func _state_input_check() -> void:
	if DNFStates.is_hit_state(current_state):
		return

	var dir := _get_move_direction()

	match current_state:
		DNFStates.State.IDLE, DNFStates.State.WALK, DNFStates.State.RUN:
			if _is_jump_pressed() and is_on_floor():
				_change_state(DNFStates.State.JUMP)
				velocity.y = jump_speed
				return
			if _is_dash_pressed() and is_on_floor():
				_change_state(DNFStates.State.DASH)
				velocity.x = (dash_speed if facing_right else -dash_speed)
				return

			if abs(dir) > 0.01:
				_update_facing(dir)
				if _is_run_held():
					velocity.x = dir * run_speed
					if current_state != DNFStates.State.RUN:
						_change_state(DNFStates.State.RUN)
				else:
					velocity.x = dir * move_speed
					if current_state != DNFStates.State.WALK:
						_change_state(DNFStates.State.WALK)
			else:
				velocity.x = 0.0
				if current_state != DNFStates.State.IDLE:
					_change_state(DNFStates.State.IDLE)

		DNFStates.State.JUMP, DNFStates.State.FALL:
			if abs(dir) > 0.01:
				velocity.x = dir * move_speed * 0.7
				_update_facing(dir)

		DNFStates.State.LAND:
			velocity.x = 0.0

		DNFStates.State.DASH:
			pass


func _state_process() -> void:
	match current_state:
		DNFStates.State.JUMP:
			if velocity.y >= 0:
				_change_state(DNFStates.State.FALL)

		DNFStates.State.LAND:
			if state_tick >= land_frames:
				_change_state(DNFStates.State.IDLE)

		DNFStates.State.DASH:
			if state_tick >= 10:
				_change_state(DNFStates.State.IDLE)
				velocity.x = 0.0

		DNFStates.State.HIT_STUN:
			velocity.x = lerpf(velocity.x, 0.0, 0.15)
			if state_tick >= _hitstun_duration:
				_change_state(DNFStates.State.IDLE)

		DNFStates.State.KNOCK_BACK:
			velocity.x = lerpf(velocity.x, 0.0, 0.1)
			if state_tick >= _hitstun_duration and is_on_floor():
				_change_state(DNFStates.State.IDLE)

		DNFStates.State.KNOCK_DOWN:
			if state_tick >= _hitstun_duration and is_on_floor():
				_change_state(DNFStates.State.GET_UP)

		DNFStates.State.AIR_BORNE:
			if is_on_floor() and state_tick > 5:
				_change_state(DNFStates.State.KNOCK_DOWN)

		DNFStates.State.GET_UP:
			velocity.x = 0.0
			if state_tick >= 20:
				_change_state(DNFStates.State.IDLE)


func _post_physics_check() -> void:
	if is_on_floor() and _previous_state in [DNFStates.State.JUMP, DNFStates.State.FALL, DNFStates.State.AIR_BORNE]:
		_change_state(DNFStates.State.LAND)
		velocity.y = 0.0

	if not is_on_floor() and current_state == DNFStates.State.IDLE:
		_change_state(DNFStates.State.FALL)


func _change_state(new_state: int) -> void:
	if new_state == current_state:
		return
	var old := current_state
	current_state = new_state
	state_tick = 0
	on_state_changed.emit(new_state, old)
	_on_state_enter(new_state, old)


func _on_state_enter(_new_state: int, _old_state: int) -> void:
	_active_cancel_windows.clear()
	_skill_frame = -1
	if _new_state != DNFStates.State.ATTACK:
		_current_move = null
		_has_hit_this_attack = false


func state_transition(state_res: DNFFighterState) -> void:
	pass


func set_cancel_windows(windows: Array) -> void:
	_active_cancel_windows = windows


func set_skill_frame(frame: int) -> void:
	_skill_frame = frame


func try_cancel(input_dict: Dictionary) -> bool:
	if _active_cancel_windows.is_empty():
		return false
	for move in available_moves:
		if not move.check_input(input_dict):
			continue
		for cw in _active_cancel_windows:
			if not cw.contains_frame(_skill_frame):
				continue
			if cw.on_hit_only and not _has_hit_this_attack:
				continue
			if cw.is_skill_allowed(move.move_name):
				execute_move(move)
				return true
	return false


func execute_move(move: DNFMove) -> void:
	_current_move = move
	_has_hit_this_attack = false
	_change_state(move.state)
	velocity.x = (move.forward_impulse if facing_right else -move.forward_impulse)


func _get_move_direction() -> float:
	return 0.0

func _is_jump_pressed() -> bool:
	return false

func _is_run_held() -> bool:
	return false

func _is_dash_pressed() -> bool:
	return false


func _update_facing(dir: float) -> void:
	if dir > 0.01:
		facing_right = true
	elif dir < -0.01:
		facing_right = false


func receive_hit(behavior: DNFHitBehavior, attack_dir: float) -> void:
	health = maxi(health - behavior.damage, 0)
	_hitstun_duration = behavior.hitstun_frames
	hitstop_remaining = behavior.hitstop_frames

	var hit_state := behavior.get_hit_state()
	_change_state(hit_state)

	match hit_state:
		DNFStates.State.HIT_STUN:
			velocity.x = attack_dir * behavior.knockback_force
		DNFStates.State.KNOCK_BACK:
			velocity.x = attack_dir * behavior.knockback_force * 1.5
		DNFStates.State.KNOCK_DOWN:
			velocity.x = attack_dir * behavior.knockback_force
			velocity.y = -5.0
		DNFStates.State.AIR_BORNE:
			velocity.x = attack_dir * behavior.knockback_force * 0.8
			velocity.y = behavior.launch_force

	on_hit_received.emit(behavior, attack_dir)


func on_hit_landed(target: Node, behavior: DNFHitBehavior) -> void:
	hitstop_remaining = behavior.hitstop_frames
	velocity.x += (-1.0 if facing_right else 1.0) * behavior.self_knockback
	_has_hit_this_attack = true
	on_hit_dealt.emit(target, behavior)


func get_state_name() -> String:
	return DNFStates.state_name(current_state)


func _save_state() -> Dictionary:
	var base := super._save_state()
	base["cur_state"] = current_state
	base["s_tick"] = state_tick
	base["facing"] = facing_right
	base["hp"] = health
	base["hitstop"] = hitstop_remaining
	base["hitstun_dur"] = _hitstun_duration
	base["skill_frame"] = _skill_frame
	base["has_hit"] = _has_hit_this_attack
	return base


func _load_state(state: Dictionary) -> void:
	super._load_state(state)
	current_state = state.get("cur_state", DNFStates.State.IDLE)
	state_tick = state.get("s_tick", 0)
	facing_right = state.get("facing", true)
	health = state.get("hp", max_health)
	hitstop_remaining = state.get("hitstop", 0)
	_hitstun_duration = state.get("hitstun_dur", 12)
	_skill_frame = state.get("skill_frame", -1)
	_has_hit_this_attack = state.get("has_hit", false)
