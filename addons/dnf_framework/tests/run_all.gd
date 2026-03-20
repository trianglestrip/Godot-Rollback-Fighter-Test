extends Node

## DNF Framework 自动化测试运行器
## 用法: godot --headless --path <project> res://addons/dnf_framework/tests/run_all.tscn

const P_HitboxData = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")
const P_FrameEvent = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")
const P_AttackPhase = preload("res://addons/dnf_framework/resources/skill/attack_phase.gd")
const P_MovementPhase = preload("res://addons/dnf_framework/resources/skill/movement_phase.gd")
const P_SkillData = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const P_SkillUIData = preload("res://addons/dnf_framework/resources/skill/skill_ui_data.gd")
const P_InputCondition = preload("res://addons/dnf_framework/resources/skill/input_condition.gd")
const P_CharStats = preload("res://addons/dnf_framework/resources/character/character_stats.gd")
const P_CharData = preload("res://addons/dnf_framework/resources/character/character_data.gd")
const P_HitboxComp = preload("res://addons/dnf_framework/runtime/combat/hitbox_component.gd")
const P_HurtboxComp = preload("res://addons/dnf_framework/runtime/combat/hurtbox_component.gd")
const P_SkillComp = preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd")
const P_HitboxTemplates = preload("res://addons/dnf_framework/editor/templates/hitbox_templates.gd")
const P_AnimSprite = preload("res://addons/dnf_framework/runtime/frame/animated_sprite.gd")
const P_CancelWindow = preload("res://addons/dnf_framework/resources/skill/cancel_window.gd")

var _pass_count: int = 0
var _fail_count: int = 0
var _test_name: String = ""
var _suite_name: String = ""


func _ready() -> void:
	print("")
	print("========================================================")
	print("  DNF Framework -- Automated Test Suite")
	print("========================================================")

	_run_suite("Phase1_Basics", [
		"_test_input_buffer_add_has",
		"_test_input_buffer_consume",
		"_test_input_buffer_expiry",
		"_test_input_buffer_combo",
		"_test_input_buffer_sequence",
		"_test_input_buffer_save_load",
		"_test_input_buffer_direction",
		"_test_frame_body_save_load",
	])

	_run_suite("Phase2_States", [
		"_test_dnf_states_helpers",
		"_test_dnf_states_name_map",
		"_test_dnf_character_initial",
		"_test_dnf_character_change_state",
		"_test_dnf_character_receive_hit",
		"_test_dnf_character_hitstop_freeze",
		"_test_dnf_character_save_load",
		"_test_dnf_character_dash_auto_end",
		"_test_dnf_character_hitstun_recovery",
	])

	_run_suite("Phase3_Combat", [
		"_test_hit_behavior_type_mapping",
		"_test_hit_behavior_defaults_custom",
		"_test_dnf_hitbox",
		"_test_dnf_hitbox_find_fighter",
		"_test_dnf_hurtbox",
		"_test_combat_manager_tracker",
		"_test_combat_manager_selective_clear",
		"_test_character_all_hit_types",
	])

	_run_suite("Phase4_Moves", [
		"_test_input_type_base",
		"_test_input_equal_check",
		"_test_input_equal_check_missing",
		"_test_input_type_auto_flags",
		"_test_move_check_input",
		"_test_move_no_conditions",
		"_test_move_hit_behavior_link",
		"_test_character_execute_move",
		"_test_character_cancel_system",
		"_test_character_cancel_on_hit_only",
	])

	_run_suite("Phase5_Integration", [
		"_test_integration_two_fighters",
		"_test_integration_attack_damages",
		"_test_integration_combo_sequence",
		"_test_integration_hitstop_symmetry",
		"_test_knockout",
		"_test_state_flow_cycle",
		"_test_save_load_mid_fight",
	])

	_run_suite("Phase6_DataLayer", [
		"_test_hitbox_data_resource",
		"_test_frame_event_resource",
		"_test_attack_phase_resource",
		"_test_movement_phase_resource",
		"_test_skill_data_resource",
		"_test_skill_data_phase_query",
		"_test_skill_data_event_query",
		"_test_input_condition_resource",
		"_test_character_stats_resource",
		"_test_character_data_resource",
		"_test_native_sprite_frames",
		"_test_hitbox_component_basic",
		"_test_skill_component_basic",
		"_test_hit_behavior_expanded",
	])

	_run_suite("Phase10_Editor", [
		"_test_editor_scripts_load",
		"_test_hitbox_templates",
		"_test_inspector_plugin_load",
	])

	_run_suite("Phase11_Panels", [
		"_test_skill_editor_load",
		"_test_character_editor_load",
		"_test_effect_editor_load",
	])

	_run_suite("Phase13_AnimatedSprite", [
		"_test_anim_sprite_init",
		"_test_anim_sprite_set_sprite_frames",
		"_test_anim_sprite_set_animation",
		"_test_anim_sprite_play_tick",
		"_test_anim_sprite_loop",
		"_test_anim_sprite_no_loop_finish",
		"_test_anim_sprite_play_backwards",
		"_test_anim_sprite_stop_pause",
		"_test_anim_sprite_save_load",
		"_test_anim_sprite_has_animation",
	])

	_run_suite("Phase14_ArchFixes", [
		"_test_attack_phase_no_events",
		"_test_hit_behavior_hit_mode",
		"_test_hit_behavior_hit_mode_defaults",
		"_test_movement_phase_curve",
		"_test_movement_phase_constant_get_velocity",
		"_test_cancel_window_resource",
		"_test_cancel_window_skill_filter",
		"_test_cancel_window_on_hit_only",
		"_test_skill_data_cancel_windows",
		"_test_combat_manager_hit_mode_once",
		"_test_combat_manager_hit_mode_per_frame",
		"_test_combat_manager_hit_mode_interval",
		"_test_combat_manager_save_load",
	])

	var total := _pass_count + _fail_count
	print("")
	print("========================================================")
	print("  GRAND TOTAL: ", _pass_count, "/", total, " tests passed")
	if _fail_count == 0:
		print("  RESULT: ALL TESTS PASSED")
	else:
		print("  RESULT: ", _fail_count, " FAILURES")
	print("========================================================")
	print("")

	get_tree().quit(1 if _fail_count > 0 else 0)


func _run_suite(suite: String, methods: Array) -> void:
	_suite_name = suite
	print("\n-- Suite: ", suite, " --")
	for m in methods:
		call(m)


# ── Assert Helpers ──

func _ok(condition: bool, desc: String) -> void:
	if condition:
		_pass_count += 1
		print("  [PASS] ", _test_name, " | ", desc)
	else:
		_fail_count += 1
		print("  [FAIL] ", _test_name, " | ", desc)


func _eq(a, b, desc: String) -> void:
	if a == b:
		_pass_count += 1
		print("  [PASS] ", _test_name, " | ", desc)
	else:
		_fail_count += 1
		print("  [FAIL] ", _test_name, " | ", desc, " (got: ", a, ", expected: ", b, ")")


func _approx(a: float, b: float, epsilon: float, desc: String) -> void:
	_ok(absf(a - b) < epsilon, desc)


func _begin(name: String) -> void:
	_test_name = name


# ====================================================================
# Phase 1: Input + Physics
# ====================================================================

func _test_input_buffer_add_has() -> void:
	_begin("InputBuffer: add/has")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.add_input("punch")
	_ok(ib.has_input("punch"), "punch in buffer")
	_ok(not ib.has_input("kick"), "kick not in buffer")
	_eq(ib.get_buffer_size(), 1, "size=1")
	ib.queue_free()


func _test_input_buffer_consume() -> void:
	_begin("InputBuffer: consume")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.add_input("punch")
	_ok(ib.consume_input("punch"), "consume success")
	_ok(not ib.has_input("punch"), "consumed")
	_ok(not ib.consume_input("punch"), "double consume fails")
	ib.queue_free()


func _test_input_buffer_expiry() -> void:
	_begin("InputBuffer: expiry")
	var ib := InputBuffer.new()
	ib.buffer_size = 2
	add_child(ib)
	ib.add_input("punch")
	_ok(ib.has_input("punch"), "in buffer at f0")
	for i in 3:
		ib._frame_count += 1
		ib._clean_expired_inputs()
	_ok(not ib.has_input("punch"), "expired after 3 frames")
	ib.queue_free()


func _test_input_buffer_combo() -> void:
	_begin("InputBuffer: combo")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.add_input("down")
	ib.add_input("down_forward")
	ib.add_input("forward")
	ib.add_input("punch")
	_ok(ib.has_input_sequence(["down", "down_forward", "forward", "punch"]), "fireball detected")
	ib.queue_free()


func _test_input_buffer_sequence() -> void:
	_begin("InputBuffer: sequence")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.add_input("A")
	ib.add_input("B")
	ib.add_input("C")
	_ok(ib.has_input_sequence(["A", "B", "C"]), "ABC found")
	_ok(ib.has_input_sequence(["A", "B"]), "AB found")
	_ok(not ib.has_input_sequence(["C", "A"]), "CA not found")
	ib.queue_free()


func _test_input_buffer_save_load() -> void:
	_begin("InputBuffer: save/load")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.add_input("punch")
	ib.add_input("kick")
	ib._frame_count += 1
	ib._clean_expired_inputs()
	var state = ib._save_state()
	_eq(state["frame"], 1, "saved frame")

	var ib2 := InputBuffer.new()
	add_child(ib2)
	ib2._load_state(state)
	_eq(ib2._frame_count, 1, "restored frame")
	_ok(ib2.has_input("punch"), "restored punch")
	_ok(ib2.has_input("kick"), "restored kick")
	ib.queue_free(); ib2.queue_free()


func _test_input_buffer_direction() -> void:
	_begin("InputBuffer: direction history")
	var ib := InputBuffer.new()
	add_child(ib)
	ib.record_direction("down")
	ib.record_direction("down_forward")
	ib.record_direction("forward")
	_eq(ib.get_input_history().size(), 3, "3 entries")
	_eq(ib.get_input_history()[0].direction, "down", "first=down")
	ib.queue_free()


func _test_frame_body_save_load() -> void:
	_begin("FrameCharacterBody2D: save/load")
	var body := FrameCharacterBody2D.new()
	add_child(body)
	body.position = Vector2(100, 200)
	body.process_frame()
	var state = body._save_state()
	_eq(state["pos_x"], 100.0, "saved pos_x")
	_eq(state["frame"], 1, "saved frame")

	var body2 := FrameCharacterBody2D.new()
	add_child(body2)
	body2._load_state(state)
	_eq(body2.position.x, 100.0, "loaded pos_x")
	_eq(body2.get_frame_count(), 1, "loaded frame")
	body.queue_free(); body2.queue_free()


# ====================================================================
# Phase 2: States + Character
# ====================================================================

func _test_dnf_states_helpers() -> void:
	_begin("DNFStates: helpers")
	_ok(DNFStates.is_actionable(DNFStates.State.IDLE), "IDLE actionable")
	_ok(DNFStates.is_actionable(DNFStates.State.WALK), "WALK actionable")
	_ok(not DNFStates.is_actionable(DNFStates.State.ATTACK), "ATTACK not actionable")
	_ok(DNFStates.is_hit_state(DNFStates.State.HIT_STUN), "HIT_STUN is hit")
	_ok(DNFStates.is_hit_state(DNFStates.State.KNOCK_DOWN), "KNOCK_DOWN is hit")
	_ok(not DNFStates.is_hit_state(DNFStates.State.IDLE), "IDLE not hit")
	_ok(DNFStates.is_airborne(DNFStates.State.JUMP), "JUMP airborne")
	_ok(not DNFStates.is_airborne(DNFStates.State.IDLE), "IDLE not airborne")
	_ok(DNFStates.is_attacking(DNFStates.State.ATTACK), "ATTACK attacking")
	_ok(not DNFStates.is_attacking(DNFStates.State.IDLE), "IDLE not attacking")


func _test_dnf_states_name_map() -> void:
	_begin("DNFStates: name mapping")
	_eq(DNFStates.state_name(DNFStates.State.IDLE), "IDLE", "IDLE")
	_eq(DNFStates.state_name(DNFStates.State.KNOCK_DOWN), "KNOCK_DOWN", "KNOCK_DOWN")
	_eq(DNFStates.state_name(DNFStates.State.BACK_DASH), "BACK_DASH", "BACK_DASH")


func _test_dnf_character_initial() -> void:
	_begin("DNFCharacter: initial")
	var ch := DNFCharacter.new()
	add_child(ch)
	_eq(ch.current_state, DNFStates.State.IDLE, "starts IDLE")
	_eq(ch.state_tick, 0, "tick=0")
	_eq(ch.health, 100, "hp=100")
	_ok(ch.facing_right, "facing right")
	ch.queue_free()


func _test_dnf_character_change_state() -> void:
	_begin("DNFCharacter: _change_state")
	var ch := DNFCharacter.new()
	add_child(ch)
	var counter: Array = [0]
	ch.on_state_changed.connect(func(_o, _n): counter[0] += 1)
	ch._change_state(DNFStates.State.WALK)
	_eq(ch.current_state, DNFStates.State.WALK, "to WALK")
	_eq(ch.state_tick, 0, "tick reset")
	_eq(counter[0], 1, "signal x1")
	ch._change_state(DNFStates.State.WALK)
	_eq(counter[0], 1, "no dup signal")
	ch._change_state(DNFStates.State.JUMP)
	_eq(ch.current_state, DNFStates.State.JUMP, "to JUMP")
	ch.queue_free()


func _test_dnf_character_receive_hit() -> void:
	_begin("DNFCharacter: receive_hit")
	var ch := DNFCharacter.new()
	add_child(ch)
	var hb := DNFHitBehavior.new()
	hb.damage = 20
	hb.hit_type = DNFHitBehavior.HitType.NORMAL
	hb.hitstun_frames = 10
	hb.knockback_force = 5.0
	ch.receive_hit(hb, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "HIT_STUN")
	_eq(ch.health, 80, "hp=80")
	_eq(ch.hitstop_remaining, 3, "hitstop=3")
	_ok(abs(ch.velocity.x) > 0, "knockback applied")

	hb.hit_type = DNFHitBehavior.HitType.LAUNCH
	hb.damage = 10
	hb.launch_force = -15.0
	ch.receive_hit(hb, 1.0)
	_eq(ch.current_state, DNFStates.State.AIR_BORNE, "AIR_BORNE")
	_eq(ch.health, 70, "hp=70")
	_ok(ch.velocity.y < 0, "launched up")
	ch.queue_free()


func _test_dnf_character_hitstop_freeze() -> void:
	_begin("DNFCharacter: hitstop freeze")
	var ch := DNFCharacter.new()
	add_child(ch)
	ch.hitstop_remaining = 3
	ch._change_state(DNFStates.State.HIT_STUN)
	var t0 := ch.state_tick
	ch._physics_process(0)
	_eq(ch.state_tick, t0, "tick frozen")
	_eq(ch.hitstop_remaining, 2, "hitstop--")
	ch.queue_free()


func _test_dnf_character_save_load() -> void:
	_begin("DNFCharacter: save/load")
	var ch := DNFCharacter.new()
	add_child(ch)
	ch._change_state(DNFStates.State.ATTACK)
	ch.health = 75
	ch.facing_right = false
	ch._has_hit_this_attack = true
	var state = ch._save_state()
	_eq(state["cur_state"], DNFStates.State.ATTACK, "saved ATTACK")
	_eq(state["hp"], 75, "saved hp")

	var ch2 := DNFCharacter.new()
	add_child(ch2)
	ch2._load_state(state)
	_eq(ch2.current_state, DNFStates.State.ATTACK, "loaded ATTACK")
	_eq(ch2.health, 75, "loaded hp")
	_ok(not ch2.facing_right, "loaded facing")
	_ok(ch2._has_hit_this_attack, "loaded has_hit")
	ch.queue_free(); ch2.queue_free()


func _test_dnf_character_dash_auto_end() -> void:
	_begin("DNFCharacter: DASH auto end")
	var ch := DNFCharacter.new()
	add_child(ch)
	ch._change_state(DNFStates.State.DASH)
	for i in 20:
		ch._physics_process(0)
	_ok(ch.current_state != DNFStates.State.DASH, "DASH ended")
	ch.queue_free()


func _test_dnf_character_hitstun_recovery() -> void:
	_begin("DNFCharacter: HIT_STUN recovery")
	var ch := DNFCharacter.new()
	add_child(ch)
	ch._change_state(DNFStates.State.HIT_STUN)
	ch._hitstun_duration = 5
	for i in 10:
		ch._physics_process(0)
	_ok(ch.current_state != DNFStates.State.HIT_STUN, "HIT_STUN ended")
	ch.queue_free()


# ====================================================================
# Phase 3: Combat
# ====================================================================

func _test_hit_behavior_type_mapping() -> void:
	_begin("HitBehavior: type mapping")
	var hb := DNFHitBehavior.new()
	hb.hit_type = DNFHitBehavior.HitType.NORMAL
	_eq(hb.get_hit_state(), DNFStates.State.HIT_STUN, "NORMAL->HIT_STUN")
	hb.hit_type = DNFHitBehavior.HitType.KNOCK_BACK
	_eq(hb.get_hit_state(), DNFStates.State.KNOCK_BACK, "KNOCK_BACK")
	hb.hit_type = DNFHitBehavior.HitType.KNOCK_DOWN
	_eq(hb.get_hit_state(), DNFStates.State.KNOCK_DOWN, "KNOCK_DOWN")
	hb.hit_type = DNFHitBehavior.HitType.LAUNCH
	_eq(hb.get_hit_state(), DNFStates.State.AIR_BORNE, "LAUNCH->AIR_BORNE")


func _test_hit_behavior_defaults_custom() -> void:
	_begin("HitBehavior: defaults + custom")
	var hb := DNFHitBehavior.new()
	_eq(hb.damage, 10, "default dmg=10")
	_eq(hb.hitstun_frames, 12, "default hitstun=12")
	hb.damage = 50
	hb.knockback_force = 10.0
	_eq(hb.damage, 50, "custom dmg=50")
	_eq(hb.knockback_force, 10.0, "custom kb_force")


func _test_dnf_hitbox() -> void:
	_begin("DNFHitbox: activate/deactivate")
	var hb := DNFHitbox.new()
	add_child(hb)
	_ok(not hb.active, "starts inactive")
	hb.activate()
	_ok(hb.active, "active after activate()")
	_ok(hb.monitoring, "monitoring on")
	hb.deactivate()
	_ok(not hb.active, "deactivated")
	hb.queue_free()


func _test_dnf_hitbox_find_fighter() -> void:
	_begin("DNFHitbox: find fighter")
	var ch := DNFCharacter.new()
	var hb := DNFHitbox.new()
	ch.add_child(hb)
	add_child(ch)
	_eq(hb.get_fighter(), ch, "finds parent DNFCharacter")
	ch.queue_free()


func _test_dnf_hurtbox() -> void:
	_begin("DNFHurtbox: activate/deactivate")
	var hb := DNFHurtbox.new()
	add_child(hb)
	_ok(hb.active, "starts active")
	hb.deactivate()
	_ok(not hb.active, "deactivated")
	hb.activate()
	_ok(hb.active, "re-activated")
	hb.queue_free()


func _test_combat_manager_tracker() -> void:
	_begin("CombatManager: tracker")
	var cm := DNFCombatManager.new()
	add_child(cm)
	_eq(cm._hit_tracker.size(), 0, "starts empty")
	cm._hit_tracker["a_b"] = { "count": 1, "last_frame": 0 }
	_eq(cm._hit_tracker.size(), 1, "recorded")
	cm.clear_hit_tracker()
	_eq(cm._hit_tracker.size(), 0, "cleared")
	cm.queue_free()


func _test_combat_manager_selective_clear() -> void:
	_begin("CombatManager: selective clear")
	var cm := DNFCombatManager.new()
	add_child(cm)
	var hitbox := DNFHitbox.new()
	add_child(hitbox)
	var hid := str(hitbox.get_instance_id())
	cm._hit_tracker[hid + "_100"] = { "count": 1, "last_frame": 0 }
	cm._hit_tracker[hid + "_200"] = { "count": 2, "last_frame": 1 }
	cm._hit_tracker["other_300"] = { "count": 1, "last_frame": 0 }
	_eq(cm._hit_tracker.size(), 3, "3 before")
	cm.clear_hit_tracker_for(hitbox)
	_eq(cm._hit_tracker.size(), 1, "1 after selective clear")
	_ok(cm._hit_tracker.has("other_300"), "unrelated kept")
	hitbox.queue_free()
	cm.queue_free()


func _test_character_all_hit_types() -> void:
	_begin("DNFCharacter: all hit types")
	var ch := DNFCharacter.new()
	add_child(ch)
	var hb := DNFHitBehavior.new()
	hb.damage = 10
	hb.hit_type = DNFHitBehavior.HitType.NORMAL
	ch.receive_hit(hb, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "NORMAL->HIT_STUN")
	_eq(ch.health, 90, "hp=90")

	ch._change_state(DNFStates.State.IDLE)
	hb.hit_type = DNFHitBehavior.HitType.KNOCK_BACK
	hb.knockback_force = 10.0
	ch.receive_hit(hb, -1.0)
	_eq(ch.current_state, DNFStates.State.KNOCK_BACK, "KNOCK_BACK")
	_ok(ch.velocity.x < 0, "knocked left")

	ch._change_state(DNFStates.State.IDLE)
	hb.hit_type = DNFHitBehavior.HitType.LAUNCH
	hb.launch_force = -15.0
	ch.receive_hit(hb, 1.0)
	_eq(ch.current_state, DNFStates.State.AIR_BORNE, "LAUNCH->AIR_BORNE")
	_ok(ch.velocity.y < 0, "launched up")
	ch.queue_free()


# ====================================================================
# Phase 4: Moves + Cancel
# ====================================================================

func _test_input_type_base() -> void:
	_begin("DNFInputType: base")
	var it := DNFInputType.new()
	_ok(not it.check_valid({}), "base returns false")


func _test_input_equal_check() -> void:
	_begin("DNFInputEqualCheck: match")
	var ec := DNFInputEqualCheck.new()
	ec.input_name = "punch"
	ec.input_value = true
	_ok(ec.check_valid({"punch": true}), "punch=true OK")
	_ok(not ec.check_valid({"punch": false}), "punch=false FAIL")
	_ok(not ec.check_valid({"kick": true}), "wrong key FAIL")


func _test_input_equal_check_missing() -> void:
	_begin("DNFInputEqualCheck: missing key")
	var ec := DNFInputEqualCheck.new()
	ec.input_name = "punch"
	ec.input_value = true
	_ok(not ec.check_valid({}), "empty dict FAIL")


func _test_input_type_auto_flags() -> void:
	_begin("DNFInputType: auto flags")
	var auto_v := DNFInputType.new()
	auto_v.auto_valid = true
	_ok(auto_v.check_valid({}), "auto_valid=true")
	var auto_r := DNFInputType.new()
	auto_r.auto_reject = true
	_ok(not auto_r.check_valid({}), "auto_reject=true")


func _test_move_check_input() -> void:
	_begin("DNFMove: check_input")
	var m := DNFMove.new()
	var ec := DNFInputEqualCheck.new()
	ec.input_name = "punch"
	ec.input_value = true
	m.input_conditions = [ec]
	_ok(m.check_input({"punch": true}), "punch OK")
	_ok(not m.check_input({"punch": false}), "false FAIL")
	_ok(not m.check_input({"kick": true}), "wrong key FAIL")


func _test_move_no_conditions() -> void:
	_begin("DNFMove: no conditions")
	var m := DNFMove.new()
	_ok(not m.check_input({}), "no conds -> false")


func _test_move_hit_behavior_link() -> void:
	_begin("DNFMove: hit_behavior link")
	var m := DNFMove.new()
	var hb := DNFHitBehavior.new()
	hb.damage = 15
	m.hit_behavior = hb
	_eq(m.hit_behavior.damage, 15, "linked dmg=15")


func _test_character_execute_move() -> void:
	_begin("DNFCharacter: execute_move")
	var ch := DNFCharacter.new()
	add_child(ch)
	var m := DNFMove.new()
	m.move_name = "punch"
	m.duration = 10
	var hb := DNFHitBehavior.new()
	hb.damage = 15
	m.hit_behavior = hb
	m.forward_impulse = 3.0
	ch.execute_move(m)
	_eq(ch.current_state, DNFStates.State.ATTACK, "ATTACK")
	_eq(ch._current_move, m, "move set")
	_ok(not ch._has_hit_this_attack, "has_hit=false")
	_eq(ch.velocity.x, 3.0, "impulse applied")
	ch.queue_free()


func _test_character_cancel_system() -> void:
	_begin("DNFCharacter: cancel system (CancelWindow)")
	var ch := DNFCharacter.new()
	add_child(ch)
	var ec := DNFInputEqualCheck.new()
	ec.input_name = "heavy"
	ec.input_value = true
	var m1 := DNFMove.new()
	m1.move_name = "light"
	m1.duration = 10
	var m2 := DNFMove.new()
	m2.move_name = "heavy"
	m2.duration = 15
	m2.input_conditions = [ec]
	ch.available_moves = [m1, m2]
	ch.execute_move(m1)
	ch._has_hit_this_attack = true
	var cw := DNFCancelWindow.new()
	cw.start_frame = 0
	cw.end_frame = 8
	cw.allowed_skills = ["heavy"]
	ch.set_cancel_windows([cw])
	ch.set_skill_frame(3)
	var ok := ch.try_cancel({"heavy": true})
	_ok(ok, "cancel succeeded")
	_eq(ch._current_move.move_name, "heavy", "switched to heavy")
	_eq(ch.state_tick, 0, "tick reset")
	ch.queue_free()


func _test_character_cancel_on_hit_only() -> void:
	_begin("DNFCharacter: cancel_on_hit_only (CancelWindow)")
	var ch := DNFCharacter.new()
	add_child(ch)
	var ec := DNFInputEqualCheck.new()
	ec.input_name = "heavy"
	ec.input_value = true
	var m1 := DNFMove.new()
	m1.move_name = "light"
	m1.duration = 10
	var m2 := DNFMove.new()
	m2.move_name = "heavy"
	m2.duration = 15
	m2.input_conditions = [ec]
	ch.available_moves = [m1, m2]
	ch.execute_move(m1)
	var cw := DNFCancelWindow.new()
	cw.start_frame = 0
	cw.end_frame = 8
	cw.allowed_skills = ["heavy"]
	cw.on_hit_only = true
	ch.set_cancel_windows([cw])
	ch.set_skill_frame(3)
	_ok(not ch.try_cancel({"heavy": true}), "blocked without hit")
	ch._has_hit_this_attack = true
	_ok(ch.try_cancel({"heavy": true}), "allowed after hit")
	ch.queue_free()


# ====================================================================
# Phase 5: Integration
# ====================================================================

func _mk_fighter(p_name: String, facing: bool) -> DNFCharacter:
	var ch := DNFCharacter.new()
	ch.name = p_name
	ch.facing_right = facing
	add_child(ch)
	return ch


func _test_integration_two_fighters() -> void:
	_begin("Integration: 2 fighters init")
	var p1 := _mk_fighter("P1", true)
	var p2 := _mk_fighter("P2", false)
	_eq(p1.current_state, DNFStates.State.IDLE, "P1 IDLE")
	_eq(p2.current_state, DNFStates.State.IDLE, "P2 IDLE")
	_ok(p1.facing_right, "P1 right")
	_ok(not p2.facing_right, "P2 left")
	p1.queue_free(); p2.queue_free()


func _test_integration_attack_damages() -> void:
	_begin("Integration: attack damages")
	var p1 := _mk_fighter("P1", true)
	var p2 := _mk_fighter("P2", false)
	var hb := DNFHitBehavior.new()
	hb.damage = 10
	hb.hit_type = DNFHitBehavior.HitType.NORMAL
	p2.receive_hit(hb, 1.0)
	p1._has_hit_this_attack = true
	p1.hitstop_remaining = 3
	_eq(p2.health, 90, "P2 hp=90")
	_eq(p2.current_state, DNFStates.State.HIT_STUN, "P2 HIT_STUN")
	_eq(p1.hitstop_remaining, 3, "P1 hitstop=3")
	_ok(p1._has_hit_this_attack, "P1 has_hit")
	p1.queue_free(); p2.queue_free()


func _test_integration_combo_sequence() -> void:
	_begin("Integration: combo sequence")
	var p1 := _mk_fighter("P1", true)
	var p2 := _mk_fighter("P2", false)
	var hb1 := DNFHitBehavior.new()
	hb1.damage = 10; hb1.hit_type = DNFHitBehavior.HitType.NORMAL
	p2.receive_hit(hb1, 1.0)
	_eq(p2.health, 90, "hit1 hp=90")
	for i in 15: p2._physics_process(0)
	p2.receive_hit(hb1, 1.0)
	_eq(p2.health, 80, "hit2 hp=80")
	for i in 15: p2._physics_process(0)
	var hb2 := DNFHitBehavior.new()
	hb2.damage = 20; hb2.hit_type = DNFHitBehavior.HitType.LAUNCH
	hb2.launch_force = -15.0
	p2.receive_hit(hb2, 1.0)
	_eq(p2.health, 60, "launch hp=60")
	_eq(p2.current_state, DNFStates.State.AIR_BORNE, "AIR_BORNE")
	p1.queue_free(); p2.queue_free()


func _test_integration_hitstop_symmetry() -> void:
	_begin("Integration: hitstop symmetry")
	var p1 := _mk_fighter("P1", true)
	var p2 := _mk_fighter("P2", false)
	var hb := DNFHitBehavior.new()
	hb.damage = 5; hb.hit_type = DNFHitBehavior.HitType.NORMAL
	p1._change_state(DNFStates.State.ATTACK)
	p1.hitstop_remaining = 3
	p2.receive_hit(hb, 1.0)
	_eq(p1.hitstop_remaining, p2.hitstop_remaining, "symmetric hitstop")
	var t0 := p1.state_tick
	p1._physics_process(0)
	_eq(p1.state_tick, t0, "P1 frozen")
	p1.queue_free(); p2.queue_free()


func _test_knockout() -> void:
	_begin("Integration: KO")
	var p := _mk_fighter("P", true)
	var hb := DNFHitBehavior.new()
	hb.damage = 9999; hb.hit_type = DNFHitBehavior.HitType.KNOCK_DOWN
	p.receive_hit(hb, 1.0)
	_eq(p.health, 0, "hp clamped to 0")
	_eq(p.current_state, DNFStates.State.KNOCK_DOWN, "KO KNOCK_DOWN")
	p.queue_free()


func _test_state_flow_cycle() -> void:
	_begin("Integration: state flow cycle")
	var ch := _mk_fighter("C", true)
	var hb := DNFHitBehavior.new()
	hb.damage = 5; hb.hit_type = DNFHitBehavior.HitType.NORMAL; hb.hitstun_frames = 5
	ch.receive_hit(hb, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "hit -> HIT_STUN")
	for i in 20: ch._physics_process(0)
	_ok(ch.current_state != DNFStates.State.HIT_STUN, "HIT_STUN ended")

	var visited := {}
	ch._change_state(DNFStates.State.WALK); visited[ch.current_state] = true
	ch._change_state(DNFStates.State.ATTACK); visited[ch.current_state] = true
	ch._change_state(DNFStates.State.HIT_STUN); visited[ch.current_state] = true
	ch._change_state(DNFStates.State.IDLE); visited[ch.current_state] = true
	_ok(visited.has(DNFStates.State.WALK), "visited WALK")
	_ok(visited.has(DNFStates.State.ATTACK), "visited ATTACK")
	_ok(visited.has(DNFStates.State.HIT_STUN), "visited HIT_STUN")
	_eq(ch.current_state, DNFStates.State.IDLE, "returned IDLE")
	ch.queue_free()


func _test_save_load_mid_fight() -> void:
	_begin("Integration: save/load mid-fight")
	var p1 := _mk_fighter("P1", true)
	var p2 := _mk_fighter("P2", false)
	p1._change_state(DNFStates.State.ATTACK)
	p1._has_hit_this_attack = true
	for i in 7: p1._physics_process(0)
	var hb := DNFHitBehavior.new()
	hb.damage = 10; hb.hit_type = DNFHitBehavior.HitType.NORMAL
	p2.receive_hit(hb, 1.0)

	var s1 = p1._save_state(); var s2 = p2._save_state()
	p1.queue_free(); p2.queue_free()

	var r1 := DNFCharacter.new(); var r2 := DNFCharacter.new()
	add_child(r1); add_child(r2)
	r1._load_state(s1); r2._load_state(s2)

	_eq(r1.current_state, DNFStates.State.ATTACK, "P1 restored ATTACK")
	_eq(r1.state_tick, 7, "P1 tick=7")
	_ok(r1._has_hit_this_attack, "P1 has_hit")
	_eq(r2.current_state, DNFStates.State.HIT_STUN, "P2 restored HIT_STUN")
	_eq(r2.health, 90, "P2 hp=90")

	p1 = r1; p2 = r2
	r1.queue_free(); r2.queue_free()


# ====================================================================
# Phase 6: Data Layer + Phase 系统
# ====================================================================

func _test_hitbox_data_resource() -> void:
	_begin("HitboxData: create + levels")
	var hd = P_HitboxData.new()
	hd.shape_size = Vector2(50, 80)
	hd.offset = Vector2(25, 0)
	hd.hit_level = P_HitboxData.HitLevel.OVERHEAD
	_eq(hd.shape_size, Vector2(50, 80), "shape")
	_eq(hd.offset, Vector2(25, 0), "offset")
	_eq(hd.hit_level, P_HitboxData.HitLevel.OVERHEAD, "overhead")


func _test_frame_event_resource() -> void:
	_begin("FrameEvent: create + types")
	var ev = P_FrameEvent.new()
	ev.frame = 5
	ev.type = P_FrameEvent.EventType.PLAY_SOUND
	ev.data = {"audio": "slash.ogg"}
	_eq(ev.frame, 5, "frame=5")
	_eq(ev.type, P_FrameEvent.EventType.PLAY_SOUND, "PLAY_SOUND")
	_eq(ev.data.get("audio"), "slash.ogg", "audio param")


func _test_attack_phase_resource() -> void:
	_begin("AttackPhase: contains_frame")
	var phase = P_AttackPhase.new()
	phase.start_frame = 3
	phase.end_frame = 7
	_ok(not phase.contains_frame(2), "frame 2 out")
	_ok(phase.contains_frame(3), "frame 3 in")
	_ok(phase.contains_frame(5), "frame 5 in")
	_ok(phase.contains_frame(7), "frame 7 in")
	_ok(not phase.contains_frame(8), "frame 8 out")


func _test_movement_phase_resource() -> void:
	_begin("MovementPhase: contains_frame + velocity")
	var mp = P_MovementPhase.new()
	mp.start_frame = 1
	mp.end_frame = 4
	mp.velocity = Vector2(5, 0)
	_ok(mp.contains_frame(2), "frame 2 in")
	_ok(not mp.contains_frame(5), "frame 5 out")
	_eq(mp.velocity, Vector2(5, 0), "velocity")
	_eq(mp.get_velocity_at_frame(2), Vector2(5, 0), "constant vel at frame 2")
	_eq(mp.get_velocity_at_frame(5), Vector2.ZERO, "out of range = zero")


func _test_skill_data_resource() -> void:
	_begin("SkillData: create with phases")
	var skill = _mk_test_skill()
	_eq(skill.skill_name, "test_slash", "name")
	_eq(skill.phases.size(), 1, "1 phase")
	_eq(skill.events.size(), 1, "1 event")
	_eq(skill.movement.size(), 1, "1 movement")
	_eq(skill.get_total_frames(), 3, "total frames")


func _test_skill_data_phase_query() -> void:
	_begin("SkillData: phase query by frame")
	var skill = _mk_test_skill()
	_eq(skill.get_phases_at_frame(0).size(), 0, "frame 0 no phase")
	_eq(skill.get_phases_at_frame(1).size(), 1, "frame 1 has phase")
	_eq(skill.get_phases_at_frame(2).size(), 1, "frame 2 has phase")
	_eq(skill.get_movement_at_frame(0).size(), 1, "frame 0 has movement")
	_eq(skill.get_movement_at_frame(2).size(), 0, "frame 2 no movement")


func _test_skill_data_event_query() -> void:
	_begin("SkillData: event query by frame")
	var skill = _mk_test_skill()
	_eq(skill.get_events_at_frame(1).size(), 1, "frame 1 has event")
	_eq(skill.get_events_at_frame(0).size(), 0, "frame 0 no event")


func _test_input_condition_resource() -> void:
	_begin("InputCondition: equal check")
	var cond = P_InputCondition.new()
	cond.condition_type = P_InputCondition.ConditionType.EQUAL_CHECK
	cond.input_name = "punch"
	cond.input_value = true
	_ok(cond.check_valid({"punch": true}), "punch=true passes")
	_ok(not cond.check_valid({"punch": false}), "punch=false fails")
	_ok(not cond.check_valid({"kick": true}), "missing key fails")


func _test_character_stats_resource() -> void:
	_begin("CharacterStats: defaults")
	var stats = P_CharStats.new()
	_eq(stats.max_hp, 1000, "hp=1000")
	_eq(stats.max_mp, 500, "mp=500")
	_eq(stats.strength, 100, "str=100")
	_ok(stats.physical_crit > 0.0, "crit > 0")


func _test_character_data_resource() -> void:
	_begin("CharacterData: skill lookup")
	var cd = P_CharData.new()
	cd.character_name = "warrior"
	var skill = _mk_test_skill()
	cd.skills = [skill]
	_eq(cd.get_skill_by_name("test_slash").skill_name, "test_slash", "found skill")
	_eq(cd.get_skill_by_name("missing"), null, "not found returns null")


func _test_native_sprite_frames() -> void:
	_begin("SpriteFrames: native API")
	var sf := SpriteFrames.new()
	_ok(sf.has_animation("default"), "has default")

	sf.add_animation("walk")
	_ok(sf.has_animation("walk"), "has walk")

	sf.rename_animation("walk", "run")
	_ok(not sf.has_animation("walk"), "walk gone")
	_ok(sf.has_animation("run"), "run exists")

	var tex := PlaceholderTexture2D.new()
	tex.size = Vector2(16, 16)
	sf.add_frame("run", tex)
	_eq(sf.get_frame_count("run"), 1, "1 frame")
	_ok(sf.get_frame_texture("run", 0) != null, "frame tex set")

	sf.set_animation_loop("run", true)
	_ok(sf.get_animation_loop("run"), "loop=true")

	sf.set_animation_speed("run", 24)
	_approx(sf.get_animation_speed("run"), 24.0, 0.01, "speed=24")

	sf.remove_animation("run")
	_ok(not sf.has_animation("run"), "run removed")


func _test_hitbox_component_basic() -> void:
	_begin("HitboxComponent: set + clear")
	var hc = P_HitboxComp.new()
	add_child(hc)
	var hd = P_HitboxData.new()
	hd.shape_size = Vector2(40, 60)
	hd.offset = Vector2(20, 0)
	var hb := DNFHitBehavior.new()
	hb.damage = 10

	hc.set_hitbox(hd, hb)
	_ok(hc.is_active(), "active after set")
	_eq(hc.get_current_behavior().damage, 10, "behavior damage=10")

	hc.clear_all()
	_ok(not hc.is_active(), "inactive after clear")
	hc.queue_free()


func _test_skill_component_basic() -> void:
	_begin("SkillComponent: play_skill + tick")
	var sf := _mk_test_native_sprite_frames()
	sf.add_animation("test_slash")
	sf.set_animation_speed("test_slash", 12)
	sf.set_animation_loop("test_slash", false)
	for i in 3:
		sf.add_frame("test_slash", PlaceholderTexture2D.new())
	var skill = _mk_test_skill()

	var spr = P_AnimSprite.new()
	spr.sprite_frames = sf
	add_child(spr)

	var hc = P_HitboxComp.new()
	add_child(hc)

	var sc = P_SkillComp.new()
	sc.animated_sprite_path = spr.get_path()
	sc.hitbox_component_path = hc.get_path()
	add_child(sc)

	_ok(sc.play_skill(skill), "play_skill returns true")
	_ok(sc.is_active(), "active after play")
	_eq(sc.get_active_skill().skill_name, "test_slash", "active skill name")

	for i in 3:
		sc.tick()
	_eq(sc.get_current_frame(), spr.frame, "frame synced")

	sc.interrupt()
	_ok(not sc.is_active(), "inactive after interrupt")

	spr.queue_free(); hc.queue_free(); sc.queue_free()


func _test_hit_behavior_expanded() -> void:
	_begin("HitBehavior: expanded fields")
	var hb := DNFHitBehavior.new()
	_eq(hb.damage_type, DNFHitBehavior.DamageType.PHYSICAL_PERCENT, "default type physical")
	_eq(hb.element, DNFHitBehavior.Element.NEUTRAL, "default element neutral")
	_approx(hb.skill_coefficient, 1.0, 0.01, "default coefficient 1.0")
	_eq(hb.fixed_damage, 0, "default fixed_damage 0")

	hb.damage_type = DNFHitBehavior.DamageType.INDEPENDENT
	hb.element = DNFHitBehavior.Element.FIRE
	hb.skill_coefficient = 2.5
	hb.fixed_damage = 500
	_eq(hb.damage_type, DNFHitBehavior.DamageType.INDEPENDENT, "set independent")
	_eq(hb.element, DNFHitBehavior.Element.FIRE, "set fire")
	_approx(hb.skill_coefficient, 2.5, 0.01, "set coefficient 2.5")
	_eq(hb.fixed_damage, 500, "set fixed 500")


# ====================================================================
# Phase 10: Editor — Timeline + Preview + Inspector
# ====================================================================

func _test_editor_scripts_load() -> void:
	_begin("Editor: timeline scripts load")
	var timeline = load("res://addons/dnf_framework/editor/timeline/timeline_root.gd")
	_ok(timeline != null, "timeline_root.gd loads")
	var ruler = load("res://addons/dnf_framework/editor/timeline/frame_ruler.gd")
	_ok(ruler != null, "frame_ruler.gd loads")
	var phase_track = load("res://addons/dnf_framework/editor/timeline/phase_track.gd")
	_ok(phase_track != null, "phase_track.gd loads")
	var event_track = load("res://addons/dnf_framework/editor/timeline/event_track.gd")
	_ok(event_track != null, "event_track.gd loads")
	var move_track = load("res://addons/dnf_framework/editor/timeline/movement_track.gd")
	_ok(move_track != null, "movement_track.gd loads")
	var armor_track = load("res://addons/dnf_framework/editor/timeline/armor_track.gd")
	_ok(armor_track != null, "armor_track.gd loads")
	var sprite_prev = load("res://addons/dnf_framework/editor/preview/sprite_preview.gd")
	_ok(sprite_prev != null, "sprite_preview.gd loads")
	var hitbox_prev = load("res://addons/dnf_framework/editor/preview/hitbox_preview.gd")
	_ok(hitbox_prev != null, "hitbox_preview.gd loads")


func _test_hitbox_templates() -> void:
	_begin("Editor: hitbox templates")
	var names = P_HitboxTemplates.get_template_names()
	_eq(names.size(), 6, "6 templates")
	_ok("前方横斩" in names, "slash template exists")
	_ok("弹道碰撞" in names, "projectile template exists")

	var templates = P_HitboxTemplates.get_templates()
	_eq(templates.size(), 6, "6 template instances")

	var slash = P_HitboxTemplates.create_from_template("前方横斩")
	_ok(slash != null, "create_from_template works")
	_eq(slash.shape_size, Vector2(80, 60), "slash shape")

	var missing = P_HitboxTemplates.create_from_template("不存在")
	_ok(missing == null, "missing returns null")


func _test_inspector_plugin_load() -> void:
	_begin("Editor: inspector plugin load")
	var script = load("res://addons/dnf_framework/editor/inspectors/dnf_inspector_plugin.gd")
	_ok(script != null, "inspector plugin loads")


# ====================================================================
# Phase 11: Editor Panels — Skill / Character / Effect
# ====================================================================

func _test_skill_editor_load() -> void:
	_begin("Editor: skill_editor.gd loads")
	var script = load("res://addons/dnf_framework/editor/panels/skill_editor.gd")
	_ok(script != null, "skill_editor.gd loads")


func _test_character_editor_load() -> void:
	_begin("Editor: character_editor.gd loads")
	var script = load("res://addons/dnf_framework/editor/panels/character_editor.gd")
	_ok(script != null, "character_editor.gd loads")


func _test_effect_editor_load() -> void:
	_begin("Editor: effect_editor.gd loads")
	var script = load("res://addons/dnf_framework/editor/panels/effect_editor.gd")
	_ok(script != null, "effect_editor.gd loads")


# ====================================================================
# Phase 13: DNFAnimatedSprite2D — AnimatedSprite2D + tick() 回滚
# ====================================================================

func _mk_test_native_sprite_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	# default animation: 4 frames, loop
	sf.set_animation_speed("default", 12)
	sf.set_animation_loop("default", true)
	for i in 4:
		sf.add_frame("default", PlaceholderTexture2D.new())

	# attack animation: 3 frames, no loop
	sf.add_animation("attack")
	sf.set_animation_speed("attack", 12)
	sf.set_animation_loop("attack", false)
	for i in 3:
		sf.add_frame("attack", PlaceholderTexture2D.new())
	return sf


func _test_anim_sprite_init() -> void:
	_begin("AnimSprite: init")
	var spr := P_AnimSprite.new()
	add_child(spr)
	_ok(spr.sprite_frames == null, "no sprite_frames")
	_ok(not spr.is_tick_playing(), "not tick playing")
	spr.queue_free()


func _test_anim_sprite_set_sprite_frames() -> void:
	_begin("AnimSprite: set sprite_frames")
	var spr := P_AnimSprite.new()
	add_child(spr)
	var sf := _mk_test_native_sprite_frames()
	spr.sprite_frames = sf
	_ok(spr.sprite_frames == sf, "sf assigned")
	spr.queue_free()


func _test_anim_sprite_set_animation() -> void:
	_begin("AnimSprite: set animation")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.animation = "attack"
	_eq(spr.animation, &"attack", "switched to attack")
	_eq(spr.sprite_frames.get_frame_count("attack"), 3, "attack has 3 frames")

	spr.animation = "default"
	_eq(spr.animation, &"default", "switched to default")
	_eq(spr.sprite_frames.get_frame_count("default"), 4, "default has 4 frames")
	spr.queue_free()


func _test_anim_sprite_play_tick() -> void:
	_begin("AnimSprite: play + tick")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.tick_play("attack")
	_ok(spr.is_tick_playing(), "tick playing after tick_play()")
	_eq(spr.animation, &"attack", "anim = attack")
	_eq(spr.frame, 0, "starts at 0")

	spr.tick()
	_eq(spr.frame, 1, "tick -> frame 1")
	spr.tick()
	_eq(spr.frame, 2, "tick -> frame 2")
	spr.tick()
	_ok(not spr.is_tick_playing(), "finished (no loop)")
	_eq(spr.frame, 2, "stays at last")
	spr.queue_free()


func _test_anim_sprite_loop() -> void:
	_begin("AnimSprite: loop")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.tick_play("default")

	for i in range(4):
		spr.tick()
	_eq(spr.frame, 0, "looped back to 0")
	_ok(spr.is_tick_playing(), "still tick playing (loop)")
	spr.queue_free()


func _test_anim_sprite_no_loop_finish() -> void:
	_begin("AnimSprite: no loop finish")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	var result: Array = [false]
	spr.animation_finished.connect(func(): result[0] = true)
	spr.tick_play("attack")

	for i in range(10):
		spr.tick()
	_ok(not spr.is_tick_playing(), "stopped")
	_ok(result[0], "finished signal emitted")
	spr.queue_free()


func _test_anim_sprite_play_backwards() -> void:
	_begin("AnimSprite: play backwards")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.tick_play_backwards("attack")
	_ok(spr.is_tick_playing(), "tick playing backwards")
	_eq(spr.frame, 2, "starts at last frame")

	spr.tick()
	_eq(spr.frame, 1, "tick -> 1")
	spr.tick()
	_eq(spr.frame, 0, "tick -> 0")
	spr.tick()
	_ok(not spr.is_tick_playing(), "finished backwards")
	spr.queue_free()


func _test_anim_sprite_stop_pause() -> void:
	_begin("AnimSprite: stop/pause")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.tick_play("default")
	spr.tick()
	_eq(spr.frame, 1, "at frame 1")

	spr.tick_pause()
	_ok(not spr.is_tick_playing(), "paused")
	_eq(spr.frame, 1, "frame preserved")

	spr.tick_stop()
	_ok(not spr.is_tick_playing(), "stopped")
	spr.queue_free()


func _test_anim_sprite_save_load() -> void:
	_begin("AnimSprite: save/load")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	spr.tick_play("attack")
	spr.tick()
	spr.tick()

	var state: Dictionary = spr._save_state()
	_eq(state.fi, 2, "saved frame=2")
	_ok(state.pl, "saved playing=true")
	_eq(state.an, "attack", "saved anim=attack")

	spr.tick_stop()
	spr.animation = "default"
	spr.frame = 0
	_eq(spr.frame, 0, "reset to 0")

	spr._load_state(state)
	_eq(spr.frame, 2, "restored frame=2")
	_ok(spr.is_tick_playing(), "restored playing")
	_eq(spr.animation, &"attack", "restored anim")
	spr.queue_free()


func _test_anim_sprite_has_animation() -> void:
	_begin("AnimSprite: has_animation")
	var spr := P_AnimSprite.new()
	add_child(spr)
	spr.sprite_frames = _mk_test_native_sprite_frames()
	_ok(spr.sprite_frames.has_animation("default"), "has default")
	_ok(spr.sprite_frames.has_animation("attack"), "has attack")
	_ok(not spr.sprite_frames.has_animation("jump"), "no jump")
	var names: PackedStringArray = spr.sprite_frames.get_animation_names()
	_ok(names.size() >= 2, "at least 2 names")
	spr.queue_free()


# -- Helpers --

func _mk_test_skill():
	var skill = P_SkillData.new()
	skill.skill_name = "test_slash"
	skill.display_name = "Test Slash"
	skill.animation_name = "test_slash"
	skill.total_frames = 3

	var hd = P_HitboxData.new()
	hd.shape_size = Vector2(50, 80)
	hd.offset = Vector2(30, 0)

	var hb := DNFHitBehavior.new()
	hb.damage = 15

	var phase = P_AttackPhase.new()
	phase.start_frame = 1
	phase.end_frame = 2
	phase.hitbox = hd
	phase.hit_behavior = hb
	skill.phases = [phase]

	var ev = P_FrameEvent.new()
	ev.frame = 1
	ev.type = P_FrameEvent.EventType.PLAY_SOUND
	ev.data = {"audio": "slash.ogg"}
	skill.events = [ev]

	var mov = P_MovementPhase.new()
	mov.start_frame = 0
	mov.end_frame = 1
	mov.velocity = Vector2(5, 0)
	skill.movement = [mov]

	return skill


# ====================================================================
# Phase 14: Architecture Fixes (Events, HitMode, CancelWindow, Curve)
# ====================================================================

func _test_attack_phase_no_events() -> void:
	_begin("AttackPhase: no events property")
	var phase := P_AttackPhase.new()
	phase.start_frame = 2
	phase.end_frame = 6
	var props := phase.get_property_list()
	var has_events := false
	for p in props:
		if p.name == "events":
			has_events = true
			break
	_ok(not has_events, "events removed from AttackPhase")
	_ok(phase.contains_frame(4), "contains_frame works")


func _test_hit_behavior_hit_mode() -> void:
	_begin("HitBehavior: HitMode enum")
	var hb := DNFHitBehavior.new()
	_eq(hb.hit_mode, DNFHitBehavior.HitMode.ONCE, "default ONCE")
	_eq(hb.max_hits, 1, "default max_hits=1")
	_eq(hb.hit_interval, 3, "default hit_interval=3")

	hb.hit_mode = DNFHitBehavior.HitMode.PER_FRAME
	_eq(hb.hit_mode, DNFHitBehavior.HitMode.PER_FRAME, "set PER_FRAME")

	hb.hit_mode = DNFHitBehavior.HitMode.INTERVAL
	hb.hit_interval = 5
	hb.max_hits = 3
	_eq(hb.hit_mode, DNFHitBehavior.HitMode.INTERVAL, "set INTERVAL")
	_eq(hb.hit_interval, 5, "interval=5")
	_eq(hb.max_hits, 3, "max_hits=3")


func _test_hit_behavior_hit_mode_defaults() -> void:
	_begin("HitBehavior: default ONCE backward compat")
	var hb := DNFHitBehavior.new()
	hb.damage = 10
	_eq(hb.hit_mode, DNFHitBehavior.HitMode.ONCE, "ONCE by default")
	_eq(hb.max_hits, 1, "max_hits=1")
	_eq(hb.get_hit_state(), DNFStates.State.HIT_STUN, "HIT_STUN default")


func _test_movement_phase_curve() -> void:
	_begin("MovementPhase: curve mode")
	var mp := P_MovementPhase.new()
	mp.start_frame = 0
	mp.end_frame = 9
	mp.motion_type = DNFMovementPhase.MotionType.CURVE
	mp.distance = 100.0
	mp.curve_direction = Vector2(1, 0)

	var c := Curve.new()
	c.add_point(Vector2(0, 1))
	c.add_point(Vector2(1, 0))
	mp.curve = c

	var vel_start := mp.get_velocity_at_frame(0)
	var vel_end := mp.get_velocity_at_frame(9)
	_ok(vel_start.x > vel_end.x, "curve: start faster than end")
	_ok(vel_start.x > 0, "curve: start > 0")

	var vel_out := mp.get_velocity_at_frame(10)
	_eq(vel_out, Vector2.ZERO, "curve: out of range = zero")


func _test_movement_phase_constant_get_velocity() -> void:
	_begin("MovementPhase: constant get_velocity_at_frame")
	var mp := P_MovementPhase.new()
	mp.start_frame = 2
	mp.end_frame = 5
	mp.motion_type = DNFMovementPhase.MotionType.CONSTANT
	mp.velocity = Vector2(10, -3)
	_eq(mp.get_velocity_at_frame(3), Vector2(10, -3), "constant vel")
	_eq(mp.get_velocity_at_frame(0), Vector2.ZERO, "outside = zero")
	_eq(mp.get_duration(), 4, "duration = 4")


func _test_cancel_window_resource() -> void:
	_begin("CancelWindow: basic")
	var cw := P_CancelWindow.new()
	cw.start_frame = 5
	cw.end_frame = 10
	_ok(cw.contains_frame(5), "frame 5 in")
	_ok(cw.contains_frame(10), "frame 10 in")
	_ok(not cw.contains_frame(4), "frame 4 out")
	_ok(not cw.contains_frame(11), "frame 11 out")


func _test_cancel_window_skill_filter() -> void:
	_begin("CancelWindow: skill filter")
	var cw := P_CancelWindow.new()
	cw.start_frame = 0
	cw.end_frame = 10
	cw.allowed_skills = ["heavy_attack", "launcher"]
	_ok(cw.is_skill_allowed("heavy_attack"), "heavy allowed")
	_ok(cw.is_skill_allowed("launcher"), "launcher allowed")
	_ok(not cw.is_skill_allowed("light_attack"), "light not allowed")

	var cw2 := P_CancelWindow.new()
	cw2.allowed_skills = []
	_ok(cw2.is_skill_allowed("anything"), "empty = allow all")


func _test_cancel_window_on_hit_only() -> void:
	_begin("CancelWindow: on_hit_only flag")
	var cw := P_CancelWindow.new()
	cw.start_frame = 0
	cw.end_frame = 10
	cw.on_hit_only = true
	_ok(cw.on_hit_only, "on_hit_only=true")


func _test_skill_data_cancel_windows() -> void:
	_begin("SkillData: cancel_windows query")
	var skill := P_SkillData.new()
	skill.skill_name = "test"
	skill.total_frames = 20

	var cw1 := P_CancelWindow.new()
	cw1.start_frame = 5
	cw1.end_frame = 10
	cw1.allowed_skills = ["heavy"]

	var cw2 := P_CancelWindow.new()
	cw2.start_frame = 12
	cw2.end_frame = 18
	cw2.on_hit_only = true

	skill.cancel_windows = [cw1, cw2]

	_eq(skill.get_cancel_windows_at_frame(5).size(), 1, "frame 5 has 1 cw")
	_eq(skill.get_cancel_windows_at_frame(11).size(), 0, "frame 11 has 0 cw")
	_eq(skill.get_cancel_windows_at_frame(15).size(), 1, "frame 15 has 1 cw")

	_ok(skill.can_cancel_at_frame(7, "heavy", false), "can cancel heavy at 7")
	_ok(not skill.can_cancel_at_frame(7, "light", false), "cannot cancel light at 7")
	_ok(not skill.can_cancel_at_frame(15, "heavy", false), "on_hit_only blocks at 15")
	_ok(skill.can_cancel_at_frame(15, "heavy", true), "on_hit_only passes with hit")


func _test_combat_manager_hit_mode_once() -> void:
	_begin("CombatManager: HitMode ONCE via tracker")
	var cm := DNFCombatManager.new()
	add_child(cm)
	var hb := DNFHitBehavior.new()
	hb.hit_mode = DNFHitBehavior.HitMode.ONCE
	hb.max_hits = 1

	var key := "test_once_key"
	cm._hit_tracker[key] = { "count": 0, "last_frame": -999 }
	var record: Dictionary = cm._hit_tracker[key]

	# ONCE: first attempt passes
	_eq(record.count, 0, "starts at 0")
	record.count = 1
	record.last_frame = 0
	# ONCE: second attempt blocked (count >= 1)
	_ok(record.count >= 1, "ONCE blocks after 1 hit")
	cm.queue_free()


func _test_combat_manager_hit_mode_per_frame() -> void:
	_begin("CombatManager: HitMode PER_FRAME logic")
	var hb := DNFHitBehavior.new()
	hb.hit_mode = DNFHitBehavior.HitMode.PER_FRAME
	hb.max_hits = 3

	var record := { "count": 0, "last_frame": -999 }

	# Frame 0: first hit
	var frame := 0
	_ok(record.last_frame != frame, "different frame -> allow")
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 1, "count=1 after hit 1")

	# Frame 0 again: same frame blocked
	_ok(record.last_frame == frame, "same frame -> block")

	# Frame 1: second hit
	frame = 1
	_ok(record.last_frame != frame, "frame 1 -> allow")
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 2, "count=2 after hit 2")

	# Frame 2: third hit
	frame = 2
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 3, "count=3 after hit 3")

	# Frame 3: max_hits reached
	_ok(hb.max_hits > 0 and record.count >= hb.max_hits, "max_hits blocks")


func _test_combat_manager_hit_mode_interval() -> void:
	_begin("CombatManager: HitMode INTERVAL logic")
	var hb := DNFHitBehavior.new()
	hb.hit_mode = DNFHitBehavior.HitMode.INTERVAL
	hb.hit_interval = 3
	hb.max_hits = 0

	var record := { "count": 0, "last_frame": -999 }

	# Frame 0: first hit (gap from -999 is >> 3)
	var frame := 0
	_ok(frame - record.last_frame >= hb.hit_interval, "frame 0 -> allow")
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 1, "count=1")

	# Frame 1: too soon
	frame = 1
	_ok(frame - record.last_frame < hb.hit_interval, "frame 1 too soon")

	# Frame 3: gap=3 -> allow
	frame = 3
	_ok(frame - record.last_frame >= hb.hit_interval, "frame 3 -> allow")
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 2, "count=2")

	# Frame 6: gap=3 -> allow
	frame = 6
	_ok(frame - record.last_frame >= hb.hit_interval, "frame 6 -> allow")
	record.count += 1
	record.last_frame = frame
	_eq(record.count, 3, "count=3")


func _test_combat_manager_save_load() -> void:
	_begin("CombatManager: save/load state")
	var cm := DNFCombatManager.new()
	add_child(cm)
	cm._frame_counter = 42
	cm._hit_tracker["test_key"] = { "count": 3, "last_frame": 40 }

	var state := cm._save_state()
	_eq(state.fc, 42, "saved frame_counter")
	_ok(state.tracker.has("test_key"), "saved tracker")

	cm._frame_counter = 0
	cm._hit_tracker.clear()
	cm._load_state(state)
	_eq(cm._frame_counter, 42, "restored frame_counter")
	_eq(cm._hit_tracker["test_key"].count, 3, "restored tracker count")
	cm.queue_free()
