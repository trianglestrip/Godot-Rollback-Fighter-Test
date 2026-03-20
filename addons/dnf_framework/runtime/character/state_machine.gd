class_name DNFStateMachine
extends Node

## DNF 状态机：管理状态切换和 tick 推进

signal state_changed(new_state: DNFFighterState, old_state: DNFFighterState)
signal state_tick_advanced(state: DNFFighterState, tick: int)
signal state_loop_completed(state: DNFFighterState)

@export var initial_state: DNFFighterState

var current_state: DNFFighterState
var current_tick: int = 0
var _owner_node: Node


func _ready() -> void:
	_owner_node = get_parent()
	if initial_state:
		force_state(initial_state)


func state_process() -> void:
	if current_state == null:
		return

	for ev in current_state.state_events:
		if ev.should_activate(current_tick):
			ev.activate(_owner_node, current_tick)

	state_tick_advanced.emit(current_state, current_tick)
	current_tick += 1

	if current_state.state_length > 0 and current_tick >= current_state.state_length:
		if current_state.state_loop:
			current_tick = 0
			state_loop_completed.emit(current_state)


func transition_to(new_state: DNFFighterState) -> void:
	if new_state == null:
		return
	var old_state := current_state
	_exit_state(old_state)
	current_state = new_state
	current_tick = 0
	_enter_state(new_state)
	state_changed.emit(new_state, old_state)


func force_state(new_state: DNFFighterState) -> void:
	transition_to(new_state)


func _enter_state(state: DNFFighterState) -> void:
	if state == null:
		return
	for ev in state.state_events:
		ev.reset()
	for ev in state.state_enter_events:
		ev.activate(_owner_node, 0)


func _exit_state(state: DNFFighterState) -> void:
	if state == null:
		return
	for ev in state.state_exit_events:
		ev.activate(_owner_node, current_tick)


func get_state_name() -> String:
	if current_state:
		return current_state.state_name
	return ""


func get_anim_name() -> String:
	if current_state:
		return current_state.anim_name
	return ""


func is_in_state(state: DNFFighterState) -> bool:
	return current_state == state


func is_state_finished() -> bool:
	if current_state == null:
		return true
	if current_state.state_length < 0:
		return false
	return current_tick >= current_state.state_length


func _save_state() -> Dictionary:
	return {
		"state": current_state,
		"tick": current_tick,
	}


func _load_state(state: Dictionary) -> void:
	var new_st: DNFFighterState = state.get("state")
	if new_st != current_state:
		current_state = new_st
	current_tick = state.get("tick", 0)
