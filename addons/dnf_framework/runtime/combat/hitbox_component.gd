class_name DNFHitboxComponent
extends Node2D

## 碰撞体运行时管理 — 根据 HitboxData 动态创建/销毁 Area2D

signal hit_landed(target: Node, behavior: Resource)

var _active_area: Area2D
var _active_shape: CollisionShape2D
var _current_hitbox: Resource  # DNFHitboxData
var _current_behavior: Resource  # DNFHitBehavior
var _facing_right: bool = true


func set_hitbox(hitbox: Resource, behavior: Resource) -> void:
	if hitbox == null:
		clear_all()
		return

	_current_hitbox = hitbox
	_current_behavior = behavior

	if _active_area == null:
		_active_area = Area2D.new()
		_active_area.collision_layer = 0
		_active_area.collision_mask = 4
		_active_area.monitoring = true
		_active_area.monitorable = false
		add_child(_active_area)
		_active_area.add_to_group("dnf_hitbox_v2")

		_active_shape = CollisionShape2D.new()
		_active_area.add_child(_active_shape)

	var rect := RectangleShape2D.new()
	rect.size = hitbox.shape_size
	_active_shape.shape = rect

	var off: Vector2 = hitbox.offset
	if not _facing_right:
		off.x = -off.x
	_active_shape.position = off
	_active_area.monitoring = true


func clear_all() -> void:
	_current_hitbox = null
	_current_behavior = null
	if _active_area:
		_active_area.monitoring = false


func set_facing(right: bool) -> void:
	_facing_right = right
	if _current_hitbox:
		var off: Vector2 = _current_hitbox.offset
		if not _facing_right:
			off.x = -off.x
		if _active_shape:
			_active_shape.position = off


func is_active() -> bool:
	return _current_hitbox != null and _active_area != null and _active_area.monitoring


func get_active_area() -> Area2D:
	return _active_area


func get_current_behavior():
	return _current_behavior


func get_fighter() -> Node:
	return get_parent()


func _save_state() -> Dictionary:
	return {
		"active": is_active(),
		"facing": _facing_right,
	}


func _load_state(state: Dictionary) -> void:
	_facing_right = state.get("facing", true)
	if not state.get("active", false):
		clear_all()
