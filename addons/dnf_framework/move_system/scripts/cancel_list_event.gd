class_name DNFCancelListEvent
extends "res://addons/dnf_framework/state_machine/scripts/state_event.gd"

## 在特定帧范围内开放取消，允许执行列表中的招式

## 可用的招式列表（招式名称）
@export var available_moves: Array[String] = []

## 是否仅在命中时才允许取消
@export var cancel_on_hit_only: bool = false


func activate(fighter: Node, _tick: int) -> void:
	if fighter.has_method("set_available_cancels"):
		fighter.set_available_cancels(available_moves, cancel_on_hit_only)
