class_name DNFHurtboxComponent
extends Area2D

## 受击碰撞体 — 配置 collision_layer 使其能被 HitboxComponent 检测

var _active: bool = true


func _ready() -> void:
	collision_layer = 4  # Hurtbox layer
	collision_mask = 0
	monitoring = false
	monitorable = true
	add_to_group("dnf_hurtbox_v2")


func activate() -> void:
	_active = true
	monitorable = true


func deactivate() -> void:
	_active = false
	monitorable = false


func is_active_hurtbox() -> bool:
	return _active


func get_fighter() -> Node:
	return get_parent()
