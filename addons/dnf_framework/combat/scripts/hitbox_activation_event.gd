class_name DNFHitboxActivationEvent
extends "res://addons/dnf_framework/state_machine/scripts/state_event.gd"

## 在 tick_range 范围内激活 hitbox，范围外自动关闭

const PRELOAD_HITBOX = preload("res://addons/dnf_framework/combat/scripts/dnf_hitbox.gd")

@export var hitbox_path: NodePath


func activate(fighter: Node, tick: int) -> void:
	var hitbox := fighter.get_node_or_null(hitbox_path) as DNFHitbox
	if hitbox == null:
		return
	if tick >= tick_range.x and (tick_range.y < 0 or tick < tick_range.y):
		hitbox.activate()
	else:
		hitbox.deactivate()
