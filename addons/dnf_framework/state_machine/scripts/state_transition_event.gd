class_name DNFStateTransitionEvent
extends "res://addons/dnf_framework/state_machine/scripts/state_event.gd"

## 状态切换事件：在指定帧跳转到另一个状态

const PRELOAD_FIGHTER_STATE = preload("res://addons/dnf_framework/state_machine/scripts/fighter_state.gd")

@export var target_state: DNFFighterState


func activate(fighter: Node, _tick: int) -> void:
	if target_state == null:
		return
	if fighter.has_method("state_transition"):
		fighter.state_transition(target_state)
