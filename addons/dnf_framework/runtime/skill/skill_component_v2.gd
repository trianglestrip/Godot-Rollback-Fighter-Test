class_name DNFSkillComponentV2
extends Node

## 技能执行组件 — 驱动 FramePlayer + Phase 匹配 + 事件触发

signal skill_started(skill: Resource)
signal skill_ended(skill: Resource)
signal phase_entered(phase: Resource, frame: int)
signal phase_exited(phase: Resource, frame: int)
signal event_fired(event: Resource)

@export var frame_player_path: NodePath
@export var hitbox_component_path: NodePath

var _frame_player: Node  # DNFFramePlayer
var _hitbox_component: Node  # DNFHitboxComponent
var _active_skill: Resource  # DNFSkillDataV2
var _current_frame: int = 0
var _active_phases: Dictionary = {}
var _fired_events: Dictionary = {}
var _cooldowns: Dictionary = {}


func _ready() -> void:
	if frame_player_path:
		_frame_player = get_node_or_null(frame_player_path)
	if hitbox_component_path:
		_hitbox_component = get_node_or_null(hitbox_component_path)

	if _frame_player and _frame_player.has_signal("animation_finished"):
		_frame_player.animation_finished.connect(_on_animation_finished)


func play_skill(skill: Resource) -> bool:
	if skill == null:
		return false

	if _cooldowns.get(skill.skill_name, 0) > 0:
		return false

	_active_skill = skill
	_current_frame = 0
	_active_phases.clear()
	_fired_events.clear()

	if _frame_player and skill.animation:
		_frame_player.play(skill.animation)

	if skill.cooldown_frames > 0:
		_cooldowns[skill.skill_name] = skill.cooldown_frames

	skill_started.emit(skill)
	return true


func tick() -> void:
	_tick_cooldowns()

	if _active_skill == null:
		return

	if _frame_player:
		_frame_player.tick()
		_current_frame = _frame_player.get_current_frame_index()

	_match_phases(_current_frame)
	_match_movement(_current_frame)
	_fire_events(_current_frame)


func _match_phases(frame: int) -> void:
	if _active_skill == null or _hitbox_component == null:
		return

	var any_active := false
	for phase in _active_skill.phases:
		var phase_key := str(phase.start_frame) + "_" + str(phase.end_frame)
		if phase.contains_frame(frame):
			any_active = true
			if not _active_phases.has(phase_key):
				_active_phases[phase_key] = true
				phase_entered.emit(phase, frame)
			_hitbox_component.set_hitbox(phase.hitbox, phase.hit_behavior)
		else:
			if _active_phases.has(phase_key):
				_active_phases.erase(phase_key)
				phase_exited.emit(phase, frame)

	if not any_active:
		_hitbox_component.clear_all()


func _match_movement(frame: int) -> void:
	if _active_skill == null:
		return
	var character = get_parent()
	if character == null:
		return

	for mov in _active_skill.movement:
		if mov.contains_frame(frame):
			var vel: Vector2 = mov.velocity
			if mov.relative_to_facing and "facing_right" in character:
				if not character.facing_right:
					vel.x = -vel.x
			if "velocity" in character:
				character.velocity = vel


func _fire_events(frame: int) -> void:
	if _active_skill == null:
		return

	var events_list: Array = _active_skill.get_events_at_frame(frame)
	for ev in events_list:
		var ev_key := str(ev.frame) + "_" + str(ev.type)
		if _fired_events.has(ev_key):
			continue
		_fired_events[ev_key] = true
		event_fired.emit(ev)


func _on_animation_finished(_anim_name: String) -> void:
	if _active_skill:
		var skill = _active_skill
		interrupt()
		skill_ended.emit(skill)


func interrupt() -> void:
	_active_skill = null
	_active_phases.clear()
	_fired_events.clear()
	_current_frame = 0
	if _hitbox_component:
		_hitbox_component.clear_all()


func is_active() -> bool:
	return _active_skill != null


func get_active_skill():
	return _active_skill


func get_current_frame() -> int:
	return _current_frame


func _tick_cooldowns() -> void:
	var keys = _cooldowns.keys()
	for key in keys:
		_cooldowns[key] -= 1
		if _cooldowns[key] <= 0:
			_cooldowns.erase(key)


func is_on_cooldown(skill_name: String) -> bool:
	return _cooldowns.get(skill_name, 0) > 0


func _save_state() -> Dictionary:
	return {
		"skill": _active_skill.skill_name if _active_skill else "",
		"frame": _current_frame,
		"phases": _active_phases.duplicate(),
		"events": _fired_events.duplicate(),
		"cd": _cooldowns.duplicate(),
	}


func _load_state(state: Dictionary) -> void:
	_current_frame = state.get("frame", 0)
	_active_phases = state.get("phases", {})
	_fired_events = state.get("events", {})
	_cooldowns = state.get("cd", {})
	if state.get("skill", "") == "":
		_active_skill = null
