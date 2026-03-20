class_name DNFCombatManager
extends Node

## 战斗管理器：统一处理 Hitbox/Hurtbox 碰撞检测和伤害结算
## 支持 HitMode: ONCE / PER_FRAME / INTERVAL

signal hit_resolved(attacker: Node, defender: Node, behavior: DNFHitBehavior)

## 命中记录：key = "hitboxInstanceId_defenderInstanceId"
## value = { "count": int, "last_frame": int }
var _hit_tracker: Dictionary = {}
var _frame_counter: int = 0


func _physics_process(_delta: float) -> void:
	process_combat()
	_frame_counter += 1


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

			if _check_overlap(hitbox, hurtbox):
				_try_hit(attacker, defender, hitbox)


func _try_hit(attacker: Node, defender: Node, hitbox: DNFHitbox) -> void:
	var behavior: DNFHitBehavior = hitbox.hit_behavior
	if behavior == null:
		return

	var hit_key := str(hitbox.get_instance_id()) + "_" + str(defender.get_instance_id())

	if not _hit_tracker.has(hit_key):
		_hit_tracker[hit_key] = { "count": 0, "last_frame": -999 }

	var record: Dictionary = _hit_tracker[hit_key]
	var mode: DNFHitBehavior.HitMode = behavior.hit_mode

	match mode:
		DNFHitBehavior.HitMode.ONCE:
			if record.count >= 1:
				return
		DNFHitBehavior.HitMode.PER_FRAME:
			if record.last_frame == _frame_counter:
				return
			if behavior.max_hits > 0 and record.count >= behavior.max_hits:
				return
		DNFHitBehavior.HitMode.INTERVAL:
			if _frame_counter - record.last_frame < behavior.hit_interval:
				return
			if behavior.max_hits > 0 and record.count >= behavior.max_hits:
				return

	record.count += 1
	record.last_frame = _frame_counter
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


func get_hit_count(hitbox: DNFHitbox, defender: Node) -> int:
	var hit_key := str(hitbox.get_instance_id()) + "_" + str(defender.get_instance_id())
	if _hit_tracker.has(hit_key):
		return _hit_tracker[hit_key].count
	return 0


func _save_state() -> Dictionary:
	return {
		"tracker": _hit_tracker.duplicate(true),
		"fc": _frame_counter,
	}


func _load_state(state: Dictionary) -> void:
	_hit_tracker = state.get("tracker", {}).duplicate(true)
	_frame_counter = state.get("fc", 0)
