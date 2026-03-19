class_name DNFHitbox
extends Area2D

## 攻击判定框

const PRELOAD_HIT_BEHAVIOR = preload("res://addons/dnf_framework/combat/scripts/hit_behavior.gd")
const PRELOAD_CHARACTER = preload("res://addons/dnf_framework/state_machine/scripts/dnf_character.gd")

enum HitLevel {
	MID,
	LOW,
	OVERHEAD,
	UNBLOCKABLE,
}

signal hit_landed(target: Node, behavior: DNFHitBehavior)

@export var hit_behavior: DNFHitBehavior
@export var hit_level: HitLevel = HitLevel.MID
@export var active: bool = false:
	set(value):
		active = value
		monitoring = value
		monitorable = value
		_apply_visibility()

var _owner_fighter: Node


func _ready() -> void:
	_owner_fighter = _find_fighter_ancestor()
	monitoring = active
	monitorable = active
	_apply_visibility()


func activate() -> void:
	active = true


func deactivate() -> void:
	active = false


func _find_fighter_ancestor() -> Node:
	var p := get_parent()
	while p:
		if p is DNFCharacter:
			return p
		p = p.get_parent()
	return get_parent()


func get_fighter() -> Node:
	return _owner_fighter


func _apply_visibility() -> void:
	visible = active
