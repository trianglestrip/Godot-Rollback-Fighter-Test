class_name DNFCombatManager
extends Node

## 战斗管理器：统一处理 Hitbox/Hurtbox 碰撞检测和伤害结算

const PRELOAD_HITBOX = preload("res://addons/dnf_framework/combat/scripts/dnf_hitbox.gd")
const PRELOAD_HURTBOX = preload("res://addons/dnf_framework/combat/scripts/dnf_hurtbox.gd")
const PRELOAD_HIT_BEHAVIOR = preload("res://addons/dnf_framework/combat/scripts/hit_behavior.gd")

signal hit_resolved(attacker: Node, defender: Node, behavior: DNFHitBehavior)

## 已处理的攻击记录（防止同一攻击多次命中）
var _hit_tracker: Dictionary = {}


func _physics_process(_delta: float) -> void:
	process_combat()


func process_combat() -> void:
	var hitboxes := get_tree().get_nodes_in_group("dnf_hitbox")
	var hurtboxes := get_tree().get_nodes_in_group("dnf_hurtbox")

	for hitbox_node in hitboxes:
		if not hitbox_node is DNFHitbox:
			continue
		var hitbox: DNFHitbox = hitbox_node as DNFHitbox
		if not hitbox.active:
			continue

		var attacker: Node = hitbox.get_fighter()
		if attacker == null:
			continue

		for hurtbox_node in hurtboxes:
			if not hurtbox_node is DNFHurtbox:
				continue
			var hurtbox: DNFHurtbox = hurtbox_node as DNFHurtbox
			if not hurtbox.active:
				continue

			var defender: Node = hurtbox.get_fighter()
			if defender == null or defender == attacker:
				continue

			var hit_key := str(hitbox.get_instance_id()) + "_" + str(defender.get_instance_id())
			if _hit_tracker.has(hit_key):
				continue

			if _check_overlap(hitbox, hurtbox):
				_hit_tracker[hit_key] = true
				_resolve_hit(attacker, defender, hitbox)


func _check_overlap(hitbox: DNFHitbox, hurtbox: DNFHurtbox) -> bool:
	var hb_areas := hitbox.get_overlapping_areas()
	return hurtbox in hb_areas


func _resolve_hit(attacker: Node, defender: Node, hitbox: DNFHitbox) -> void:
	var behavior := hitbox.hit_behavior
	if behavior == null:
		return

	hitbox.hit_landed.emit(defender, behavior)

	if defender.has_method("receive_hit"):
		var attack_dir := 1.0 if attacker.global_position.x < defender.global_position.x else -1.0
		defender.receive_hit(behavior, attack_dir)

	if attacker.has_method("on_hit_landed"):
		attacker.on_hit_landed(defender, behavior)

	hit_resolved.emit(attacker, defender, behavior)


func clear_hit_tracker() -> void:
	_hit_tracker.clear()


func clear_hit_tracker_for(hitbox: DNFHitbox) -> void:
	var prefix := str(hitbox.get_instance_id()) + "_"
	var keys_to_remove: Array = []
	for key in _hit_tracker:
		if str(key).begins_with(prefix):
			keys_to_remove.append(key)
	for key in keys_to_remove:
		_hit_tracker.erase(key)
