class_name DNFHurtboxActivationEvent
extends "res://addons/dnf_framework/state_machine/scripts/state_event.gd"

## 在 tick_range 范围内激活/关闭 hurtbox

const PRELOAD_HURTBOX = preload("res://addons/dnf_framework/combat/scripts/dnf_hurtbox.gd")

@export var hurtbox_path: NodePath
@export var enable: bool = true


func activate(fighter: Node, _tick: int) -> void:
	var hurtbox := fighter.get_node_or_null(hurtbox_path) as DNFHurtbox
	if hurtbox == null:
		return
	if enable:
		hurtbox.activate()
	else:
		hurtbox.deactivate()
