class_name DNFSkillComponent
extends Node

## 技能组件：挂载到角色节点上，管理技能的注册、执行、帧推进和冷却
## 完全数据驱动，支持多段攻击、取消窗口、AI 调用

const PRELOAD_SKILL_DATA = preload("res://addons/dnf_framework/skill_system/scripts/skill_data.gd")
const PRELOAD_SKILL_EVENT = preload("res://addons/dnf_framework/skill_system/scripts/skill_event.gd")

signal skill_started(skill: DNFSkillData)
signal skill_finished(skill: DNFSkillData)
signal skill_cancelled(skill: DNFSkillData, by_skill: DNFSkillData)
signal skill_frame_advanced(skill: DNFSkillData, frame: int)

## 技能列表（在编辑器中配置）
@export var skills: Array[DNFSkillData] = []

var _active_skill: DNFSkillData = null
var _current_frame: int = 0
var _cooldowns: Dictionary = {}
var _owner_fighter: Node


func _ready() -> void:
	_owner_fighter = get_parent()


## 每帧由外部调用推进技能帧（帧驱动，非 delta 驱动）
func skill_process() -> void:
	if _active_skill == null:
		return

	_run_frame_events(_active_skill.frame_events, _current_frame)
	skill_frame_advanced.emit(_active_skill, _current_frame)
	_current_frame += 1

	if _current_frame >= _active_skill.total_frames:
		_finish_skill()


## 尝试执行技能（通过名称）
func try_execute(skill_name: String) -> bool:
	var skill: DNFSkillData = _find_skill(skill_name)
	if skill == null:
		return false
	return execute(skill)


## 执行技能（可由 AI 直接调用）
func execute(skill: DNFSkillData) -> bool:
	if not can_execute(skill):
		return false

	if _active_skill != null:
		if not _active_skill.is_in_cancel_window(_current_frame):
			return false
		if skill.priority < _active_skill.priority:
			return false
		_cancel_into(skill)
		return true

	_start_skill(skill)
	return true


## 检查技能是否可以执行
func can_execute(skill: DNFSkillData) -> bool:
	if skill == null:
		return false
	if _is_on_cooldown(skill.skill_name):
		return false
	if skill.ground_only and _owner_fighter is CharacterBody2D:
		if not (_owner_fighter as CharacterBody2D).is_on_floor():
			return false
	if not skill.air_usable and _owner_fighter is CharacterBody2D:
		if not (_owner_fighter as CharacterBody2D).is_on_floor():
			if not skill.ground_only:
				return false
	return true


## 强制中断当前技能
func interrupt() -> void:
	if _active_skill == null:
		return
	_deactivate_all_events(_active_skill)
	_run_end_events(_active_skill)
	var finished: DNFSkillData = _active_skill
	_active_skill = null
	_current_frame = 0
	skill_finished.emit(finished)


## 当前是否正在执行技能
func is_active() -> bool:
	return _active_skill != null


## 获取当前技能数据
func get_active_skill() -> DNFSkillData:
	return _active_skill


## 获取当前技能帧
func get_current_frame() -> int:
	return _current_frame


## 获取当前技能名称
func get_active_skill_name() -> String:
	if _active_skill:
		return _active_skill.skill_name
	return ""


## 根据名称查找技能
func get_skill(skill_name: String) -> DNFSkillData:
	return _find_skill(skill_name)


## 减少所有冷却计时
func tick_cooldowns() -> void:
	var expired: Array[String] = []
	for key in _cooldowns:
		_cooldowns[key] -= 1
		if _cooldowns[key] <= 0:
			expired.append(key)
	for key in expired:
		_cooldowns.erase(key)


func _start_skill(skill: DNFSkillData) -> void:
	_active_skill = skill
	_current_frame = 0
	_reset_events(skill)
	_run_start_events(skill)

	if _owner_fighter.has_method("change_skill_state"):
		_owner_fighter.change_skill_state(skill.enter_state)

	skill_started.emit(skill)


func _finish_skill() -> void:
	_deactivate_all_events(_active_skill)
	_run_end_events(_active_skill)

	if _active_skill.cooldown_frames > 0:
		_cooldowns[_active_skill.skill_name] = _active_skill.cooldown_frames

	var finished: DNFSkillData = _active_skill
	_active_skill = null
	_current_frame = 0
	skill_finished.emit(finished)


func _cancel_into(new_skill: DNFSkillData) -> void:
	_deactivate_all_events(_active_skill)
	_run_end_events(_active_skill)

	var old_skill: DNFSkillData = _active_skill
	skill_cancelled.emit(old_skill, new_skill)

	_start_skill(new_skill)


func _run_frame_events(events: Array[DNFSkillEvent], frame: int) -> void:
	for ev in events:
		if ev.should_activate(frame):
			ev.activate(_owner_fighter, frame)
		elif not _is_event_in_range(ev, frame):
			ev.deactivate(_owner_fighter)


func _run_start_events(skill: DNFSkillData) -> void:
	for ev in skill.start_events:
		ev.activate(_owner_fighter, 0)


func _run_end_events(skill: DNFSkillData) -> void:
	for ev in skill.end_events:
		ev.activate(_owner_fighter, _current_frame)


func _deactivate_all_events(skill: DNFSkillData) -> void:
	for ev in skill.frame_events:
		ev.deactivate(_owner_fighter)


func _reset_events(skill: DNFSkillData) -> void:
	for ev in skill.frame_events:
		ev.reset()
	for ev in skill.start_events:
		ev.reset()
	for ev in skill.end_events:
		ev.reset()


func _is_event_in_range(ev: DNFSkillEvent, frame: int) -> bool:
	return frame >= ev.frame_range.x and (ev.frame_range.y < 0 or frame < ev.frame_range.y)


func _find_skill(skill_name: String) -> DNFSkillData:
	for skill in skills:
		if skill.skill_name == skill_name:
			return skill
	return null


func _is_on_cooldown(skill_name: String) -> bool:
	return _cooldowns.has(skill_name) and _cooldowns[skill_name] > 0


func _save_state() -> Dictionary:
	return {
		"active": _active_skill,
		"frame": _current_frame,
		"cooldowns": _cooldowns.duplicate(),
	}


func _load_state(state: Dictionary) -> void:
	_active_skill = state.get("active")
	_current_frame = state.get("frame", 0)
	_cooldowns = state.get("cooldowns", {}).duplicate()
