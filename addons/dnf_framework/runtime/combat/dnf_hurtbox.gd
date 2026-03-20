class_name DNFHurtbox
extends Area2D

## 受击判定框

signal got_hit(hitbox: DNFHitbox)

@export var active: bool = true:
	set(value):
		active = value
		monitoring = value
		monitorable = value

var _owner_fighter: Node


func _ready() -> void:
	_owner_fighter = _find_fighter_ancestor()
	monitoring = active
	monitorable = active


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
