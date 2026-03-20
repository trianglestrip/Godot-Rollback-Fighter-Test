class_name DNFCancelListEvent
extends "res://addons/dnf_framework/runtime/character/state_event.gd"

## 在特定帧范围内开放取消，允许执行列表中的招式

@export var cancel_window: Resource  ## DNFCancelWindow


func activate(fighter: Node, _tick: int) -> void:
	if fighter.has_method("set_cancel_windows") and cancel_window:
		fighter.set_cancel_windows([cancel_window])
