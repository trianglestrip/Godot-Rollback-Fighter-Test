extends Node

## DNF Framework 自动化测试运行器
## 用法: godot --headless --path <project> res://addons/dnf_framework/tests/run_all.tscn

const P_FrameData = preload("res://addons/dnf_framework/resources/animation/frame_data.gd")
const P_AnimData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")
const P_HitboxData = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")
const P_FrameEvent = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")
const P_AttackPhase = preload("res://addons/dnf_framework/resources/skill/attack_phase.gd")
const P_MovementPhase = preload("res://addons/dnf_framework/resources/skill/movement_phase.gd")
const P_SkillDataV2 = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const P_SkillUIData = preload("res://addons/dnf_framework/resources/skill/skill_ui_data.gd")
const P_InputCondition = preload("res://addons/dnf_framework/resources/skill/input_condition.gd")
const P_CharStats = preload("res://addons/dnf_framework/resources/character/character_stats.gd")
const P_CharData = preload("res://addons/dnf_framework/resources/character/character_data.gd")
const P_FramePlayer = preload("res://addons/dnf_framework/runtime/frame/frame_player.gd")
const P_HitboxComp = preload("res://addons/dnf_framework/runtime/combat/hitbox_component.gd")
const P_HurtboxComp = preload("res://addons/dnf_framework/runtime/combat/hurtbox_component.gd")
const P_SkillCompV2 = preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd")

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
		"_test_input_buffer_add_and_has",
		"_test_input_buffer_consume",
		"_test_input_buffer_expiry",
		"_test_input_buffer_combo_detection",
		"_test_input_buffer_sequence",
		"_test_input_buffer_save_load",
		"_test_input_buffer_history",
		"_test_frame_anim_no_spriteframes",
		"_test_frame_anim_play_advance",
		"_test_frame_anim_events",
		"_test_frame_anim_save_load",
		"_test_frame_body_save_load",
	])

	_run_suite("Phase2_States", [
		"_test_states_enum_helpers",
		"_test_states_name_mapping",
		"_test_char_initial_state",
		"_test_char_state_change",
		"_test_char_receive_hit",
		"_test_char_hitstop_freezes",
		"_test_char_save_load",
		"_test_char_dash_auto_ends",
		"_test_char_hitstun_recovery",
	])

	_run_suite("Phase3_Combat", [
		"_test_hit_behavior_types",
		"_test_hit_behavior_values",
		"_test_hitbox_activate",
		"_test_hitbox_find_fighter",
		"_test_hurtbox_activate",
		"_test_combat_mgr_tracker",
		"_test_combat_mgr_clear",
		"_test_receive_hit_all_types",
	])

	_run_suite("Phase4_Moves", [
		"_test_input_type_base",
		"_test_input_equal_check",
		"_test_input_equal_missing",
		"_test_input_type_auto_flags",
		"_test_move_check_input",
		"_test_move_empty_conditions",
		"_test_move_hit_behavior_link",
		"_test_char_execute_move",
		"_test_char_cancel_system",
		"_test_char_cancel_on_hit_only",
	])

	_run_suite("Phase5_Integration", [
		"_test_two_fighters_setup",
		"_test_attack_damages_defender",
		"_test_combo_sequence",
		"_test_hitstop_symmetry",
		"_test_knockout",
		"_test_state_flow_cycle",
		"_test_save_load_mid_fight",
	])

	_run_suite("Phase6_DataLayer", [
		"_test_frame_data_resource",
		"_test_animation_data_resource",
		"_test_hitbox_data_resource",
		"_test_frame_event_resource",
		"_test_attack_phase_resource",
		"_test_movement_phase_resource",
		"_test_skill_data_v2_resource",
		"_test_skill_data_v2_phase_query",
		"_test_skill_data_v2_event_query",
		"_test_input_condition_resource",
		"_test_character_stats_resource",
		"_test_character_data_resource",
		"_test_frame_player_basic",
		"_test_frame_player_save_load",
		"_test_hitbox_component_basic",
		"_test_skill_component_v2_basic",
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


func _eq(actual: Variant, expected: Variant, desc: String) -> void:
	if actual == expected:
		_pass_count += 1
		print("  [PASS] ", _test_name, " | ", desc)
	else:
		_fail_count += 1
		print("  [FAIL] ", _test_name, " | ", desc, "  (got: ", actual, ", expected: ", expected, ")")


func _approx(actual: float, expected: float, eps: float, desc: String) -> void:
	_ok(absf(actual - expected) <= eps, desc)


func _lt(a: float, b: float, desc: String) -> void:
	_ok(a < b, desc)


func _gt(a: float, b: float, desc: String) -> void:
	_ok(a > b, desc)


func _begin(name: String) -> void:
	_test_name = name


# ═══════════════════════════════════════════════════════
#  PHASE 1: FrameAnimationPlayer / InputBuffer / FrameCharacterBody2D
# ═══════════════════════════════════════════════════════

func _test_input_buffer_add_and_has() -> void:
	_begin("InputBuffer: add/has")
	var buf := InputBuffer.new()
	buf.buffer_size = 10
	buf._frame_count = 5
	add_child(buf)
	buf.add_input("punch")
	_ok(buf.has_input("punch"), "punch in buffer")
	_ok(not buf.has_input("kick"), "kick not in buffer")
	_eq(buf.get_buffer_size(), 1, "size=1")
	buf.queue_free()


func _test_input_buffer_consume() -> void:
	_begin("InputBuffer: consume")
	var buf := InputBuffer.new()
	buf.buffer_size = 10
	buf._frame_count = 5
	add_child(buf)
	buf.add_input("punch")
	_ok(buf.consume_input("punch"), "consume success")
	_ok(not buf.has_input("punch"), "consumed")
	_ok(not buf.consume_input("punch"), "double consume fails")
	buf.queue_free()


func _test_input_buffer_expiry() -> void:
	_begin("InputBuffer: expiry")
	var buf := InputBuffer.new()
	buf.buffer_size = 3
	add_child(buf)
	buf._frame_count = 0
	buf.add_input("punch")
	_ok(buf.has_input("punch"), "in buffer at f0")
	buf._frame_count = 5
	buf._clean_expired_inputs()
	_ok(not buf.has_input("punch"), "expired after 3 frames")
	buf.queue_free()


var _combo_result: String = ""

func _test_input_buffer_combo_detection() -> void:
	_begin("InputBuffer: combo")
	var buf := InputBuffer.new()
	buf.buffer_size = 10
	buf.combo_definitions = {"fireball": ["down", "forward", "punch"]}
	add_child(buf)
	_combo_result = ""
	buf.combo_detected.connect(_on_combo)
	buf._frame_count = 1; buf.add_input("down")
	buf._frame_count = 2; buf.add_input("forward")
	buf._frame_count = 3; buf.add_input("punch")
	_eq(_combo_result, "fireball", "fireball detected")
	buf.queue_free()

func _on_combo(n: String, _s: Array) -> void:
	_combo_result = n


func _test_input_buffer_sequence() -> void:
	_begin("InputBuffer: sequence")
	var buf := InputBuffer.new()
	buf.buffer_size = 10
	add_child(buf)
	buf._frame_count = 1; buf.add_input("A")
	buf._frame_count = 2; buf.add_input("B")
	buf._frame_count = 3; buf.add_input("C")
	_ok(buf.has_input_sequence(["A", "B", "C"]), "ABC found")
	_ok(buf.has_input_sequence(["A", "B"]), "AB found")
	_ok(not buf.has_input_sequence(["C", "A"]), "CA not found")
	buf.queue_free()


func _test_input_buffer_save_load() -> void:
	_begin("InputBuffer: save/load")
	var buf := InputBuffer.new()
	buf.buffer_size = 10
	add_child(buf)
	buf._frame_count = 10
	buf.add_input("punch")
	buf.add_input("kick")
	var state := buf._save_state()
	_eq(state["frame"], 10, "saved frame")
	var buf2 := InputBuffer.new()
	buf2.buffer_size = 10
	add_child(buf2)
	buf2._load_state(state)
	_eq(buf2._frame_count, 10, "restored frame")
	_ok(buf2.has_input("punch"), "restored punch")
	_ok(buf2.has_input("kick"), "restored kick")
	buf.queue_free()
	buf2.queue_free()


func _test_input_buffer_history() -> void:
	_begin("InputBuffer: direction history")
	var buf := InputBuffer.new()
	buf.history_size = 5
	add_child(buf)
	for i in range(3):
		buf._frame_count = i
		buf.record_direction("down" if i % 2 == 0 else "forward")
	var hist := buf.get_input_history()
	_eq(hist.size(), 3, "3 entries")
	_eq(hist[0].direction, "down", "first=down")
	buf.queue_free()


func _make_sf(anim: String, count: int) -> SpriteFrames:
	var sf := SpriteFrames.new()
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	for i in range(count):
		var tex := PlaceholderTexture2D.new()
		tex.size = Vector2(16, 16)
		sf.add_frame(anim, tex)
	return sf


func _test_frame_anim_no_spriteframes() -> void:
	_begin("FrameAnimationPlayer: no sprite_frames")
	var ap := FrameAnimationPlayer.new()
	add_child(ap)
	ap.play("idle")
	_ok(not ap.is_playing(), "not playing without sprites")
	ap.queue_free()


func _test_frame_anim_play_advance() -> void:
	_begin("FrameAnimationPlayer: play+advance")
	var ap := FrameAnimationPlayer.new()
	ap.sprite_frames = _make_sf("walk", 6)
	add_child(ap)
	ap.play("walk")
	_ok(ap.is_playing(), "playing")
	_eq(ap.get_current_frame(), 0, "f=0")
	_eq(ap.get_total_frames(), 6, "total=6")
	ap.advance(); _eq(ap.get_current_frame(), 1, "f=1")
	ap.advance(); ap.advance(); _eq(ap.get_current_frame(), 3, "f=3")
	for i in range(10): ap.advance()
	_ok(not ap.is_playing(), "stopped at end")
	_eq(ap.get_current_frame(), 5, "last frame")
	ap.queue_free()


func _test_frame_anim_events() -> void:
	_begin("FrameAnimationPlayer: events")
	var ap := FrameAnimationPlayer.new()
	ap.sprite_frames = _make_sf("attack", 8)
	add_child(ap)
	ap.add_animation_event("attack", 3, "hit_start")
	ap.add_animation_event("attack", 5, "hit_end")
	var evts: Array[String] = []
	ap.animation_event.connect(func(ev: String, _a: String, _f: int): evts.append(ev))
	ap.play("attack")
	for i in range(7): ap.advance()
	_ok("hit_start" in evts, "hit_start fired")
	_ok("hit_end" in evts, "hit_end fired")
	ap.remove_animation_event("attack", 3, "hit_start")
	evts.clear()
	ap.play("attack", 0, true)
	for i in range(7): ap.advance()
	_ok("hit_start" not in evts, "hit_start removed")
	_ok("hit_end" in evts, "hit_end still fires")
	ap.queue_free()


func _test_frame_anim_save_load() -> void:
	_begin("FrameAnimationPlayer: save/load")
	var ap := FrameAnimationPlayer.new()
	ap.sprite_frames = _make_sf("run", 10)
	add_child(ap)
	ap.play("run")
	ap.advance(); ap.advance(); ap.advance()
	var s := ap._save_state()
	_eq(s["frame"], 3, "saved f=3")
	ap._load_state({"anim": "run", "frame": 7, "total": 10, "playing": false, "paused": false})
	_eq(ap.get_current_frame(), 7, "loaded f=7")
	_ok(not ap.is_playing(), "loaded not playing")
	ap.queue_free()


func _test_frame_body_save_load() -> void:
	_begin("FrameCharacterBody2D: save/load")
	var body := FrameCharacterBody2D.new()
	body.position = Vector2(100, 200)
	body.velocity = Vector2(5, -10)
	body._frame_count = 42
	add_child(body)
	var s := body._save_state()
	_approx(s["pos_x"], 100.0, 0.1, "saved pos_x")
	_eq(s["frame"], 42, "saved frame")
	body._load_state({"pos_x": 300.0, "pos_y": 50.0, "vel_x": 0.0, "vel_y": 0.0, "frame": 99})
	_approx(body.position.x, 300.0, 0.1, "loaded pos_x")
	_eq(body._frame_count, 99, "loaded frame")
	body.queue_free()


# ═══════════════════════════════════════════════════════
#  PHASE 2: DNFStates / DNFCharacter
# ═══════════════════════════════════════════════════════

func _test_states_enum_helpers() -> void:
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


func _test_states_name_mapping() -> void:
	_begin("DNFStates: name mapping")
	_eq(DNFStates.state_name(DNFStates.State.IDLE), "IDLE", "IDLE")
	_eq(DNFStates.state_name(DNFStates.State.KNOCK_DOWN), "KNOCK_DOWN", "KNOCK_DOWN")
	_eq(DNFStates.state_name(DNFStates.State.BACK_DASH), "BACK_DASH", "BACK_DASH")


func _mk_char() -> DNFCharacter:
	var ch := DNFCharacter.new()
	ch.max_health = 100
	ch.health = 100
	ch.gravity = 0.0
	return ch


func _test_char_initial_state() -> void:
	_begin("DNFCharacter: initial")
	var ch := _mk_char()
	add_child(ch)
	_eq(ch.current_state, DNFStates.State.IDLE, "starts IDLE")
	_eq(ch.state_tick, 0, "tick=0")
	_eq(ch.health, 100, "hp=100")
	_ok(ch.facing_right, "facing right")
	ch.queue_free()


func _test_char_state_change() -> void:
	_begin("DNFCharacter: _change_state")
	var ch := _mk_char()
	add_child(ch)
	var states: Array[int] = []
	ch.on_state_changed.connect(func(ns: int, _os: int): states.append(ns))
	ch._change_state(DNFStates.State.WALK)
	_eq(ch.current_state, DNFStates.State.WALK, "to WALK")
	_eq(ch.state_tick, 0, "tick reset")
	_eq(states.size(), 1, "signal x1")
	ch._change_state(DNFStates.State.WALK)
	_eq(states.size(), 1, "no dup signal")
	ch._change_state(DNFStates.State.JUMP)
	_eq(ch.current_state, DNFStates.State.JUMP, "to JUMP")
	ch.queue_free()


func _test_char_receive_hit() -> void:
	_begin("DNFCharacter: receive_hit")
	var ch := _mk_char()
	add_child(ch)
	var hit := DNFHitBehavior.new()
	hit.damage = 20; hit.hit_type = DNFHitBehavior.HitType.NORMAL
	hit.hitstun_frames = 15; hit.hitstop_frames = 3; hit.knockback_force = 5.0
	ch.receive_hit(hit, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "HIT_STUN")
	_eq(ch.health, 80, "hp=80")
	_eq(ch.hitstop_remaining, 3, "hitstop=3")
	_approx(ch.velocity.x, 5.0, 0.1, "knockback")

	var h2 := DNFHitBehavior.new()
	h2.damage = 10; h2.hit_type = DNFHitBehavior.HitType.LAUNCH
	h2.hitstun_frames = 30; h2.hitstop_frames = 0; h2.knockback_force = 3.0; h2.launch_force = -20.0
	ch.receive_hit(h2, -1.0)
	_eq(ch.current_state, DNFStates.State.AIR_BORNE, "AIR_BORNE")
	_eq(ch.health, 70, "hp=70")
	_lt(ch.velocity.y, 0, "launched up")
	ch.queue_free()


func _test_char_hitstop_freezes() -> void:
	_begin("DNFCharacter: hitstop freeze")
	var ch := _mk_char()
	add_child(ch)
	ch._change_state(DNFStates.State.WALK)
	ch.state_tick = 5
	ch.hitstop_remaining = 3
	var t := ch.state_tick
	ch._physics_process(0.016)
	_eq(ch.state_tick, t, "tick frozen")
	_eq(ch.hitstop_remaining, 2, "hitstop--")
	ch.queue_free()


func _test_char_save_load() -> void:
	_begin("DNFCharacter: save/load")
	var ch := _mk_char()
	add_child(ch)
	ch._change_state(DNFStates.State.ATTACK)
	ch.state_tick = 7; ch.facing_right = false; ch.health = 55
	ch.hitstop_remaining = 2; ch._has_hit_this_attack = true
	ch.available_cancels = ["heavy"]
	var s := ch._save_state()
	_eq(s["cur_state"], DNFStates.State.ATTACK, "saved ATTACK")
	_eq(s["hp"], 55, "saved hp")

	var ch2 := _mk_char()
	add_child(ch2)
	ch2._load_state(s)
	_eq(ch2.current_state, DNFStates.State.ATTACK, "loaded ATTACK")
	_eq(ch2.health, 55, "loaded hp")
	_ok(not ch2.facing_right, "loaded facing")
	_ok(ch2._has_hit_this_attack, "loaded has_hit")
	ch.queue_free(); ch2.queue_free()


func _test_char_dash_auto_ends() -> void:
	_begin("DNFCharacter: DASH auto end")
	var ch := _mk_char()
	add_child(ch)
	ch._change_state(DNFStates.State.DASH)
	ch.velocity.x = 12.0
	for i in range(11):
		ch._state_process()
		ch.state_tick += 1
	_eq(ch.current_state, DNFStates.State.IDLE, "DASH->IDLE")
	ch.queue_free()


func _test_char_hitstun_recovery() -> void:
	_begin("DNFCharacter: HIT_STUN recovery")
	var ch := _mk_char()
	add_child(ch)
	ch._hitstun_duration = 5
	ch._change_state(DNFStates.State.HIT_STUN)
	ch.velocity.x = 10.0
	for i in range(6):
		ch._state_process()
		ch.state_tick += 1
	_eq(ch.current_state, DNFStates.State.IDLE, "HIT_STUN->IDLE")
	ch.queue_free()


# ═══════════════════════════════════════════════════════
#  PHASE 3: HitBehavior / Hitbox / Hurtbox / CombatManager
# ═══════════════════════════════════════════════════════

func _test_hit_behavior_types() -> void:
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


func _test_hit_behavior_values() -> void:
	_begin("HitBehavior: defaults + custom")
	var hb := DNFHitBehavior.new()
	_eq(hb.damage, 10, "default dmg=10")
	_eq(hb.hitstun_frames, 12, "default hitstun=12")
	hb.damage = 50; hb.knockback_force = 15.0
	_eq(hb.damage, 50, "custom dmg=50")
	_approx(hb.knockback_force, 15.0, 0.01, "custom kb")


func _test_hitbox_activate() -> void:
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


func _test_hitbox_find_fighter() -> void:
	_begin("DNFHitbox: find fighter")
	var ch := _mk_char()
	var hb := DNFHitbox.new()
	ch.add_child(hb)
	add_child(ch)
	_eq(hb.get_fighter(), ch, "finds parent DNFCharacter")
	ch.queue_free()


func _test_hurtbox_activate() -> void:
	_begin("DNFHurtbox: activate/deactivate")
	var hb := DNFHurtbox.new()
	add_child(hb)
	_ok(hb.active, "starts active")
	hb.deactivate()
	_ok(not hb.active, "deactivated")
	hb.activate()
	_ok(hb.active, "re-activated")
	hb.queue_free()


func _test_combat_mgr_tracker() -> void:
	_begin("CombatManager: tracker")
	var mgr := DNFCombatManager.new()
	add_child(mgr)
	_ok(mgr._hit_tracker.is_empty(), "starts empty")
	mgr._hit_tracker["123_456"] = true
	_ok(mgr._hit_tracker.has("123_456"), "recorded")
	mgr.clear_hit_tracker()
	_ok(mgr._hit_tracker.is_empty(), "cleared")
	mgr.queue_free()


func _test_combat_mgr_clear() -> void:
	_begin("CombatManager: selective clear")
	var mgr := DNFCombatManager.new()
	add_child(mgr)
	var hb := DNFHitbox.new()
	add_child(hb)
	var hid := str(hb.get_instance_id())
	mgr._hit_tracker[hid + "_100"] = true
	mgr._hit_tracker[hid + "_200"] = true
	mgr._hit_tracker["999_300"] = true
	_eq(mgr._hit_tracker.size(), 3, "3 before")
	mgr.clear_hit_tracker_for(hb)
	_eq(mgr._hit_tracker.size(), 1, "1 after selective clear")
	_ok(mgr._hit_tracker.has("999_300"), "unrelated kept")
	hb.queue_free(); mgr.queue_free()


func _test_receive_hit_all_types() -> void:
	_begin("DNFCharacter: all hit types")
	var ch := _mk_char()
	add_child(ch)

	var h1 := DNFHitBehavior.new()
	h1.hit_type = DNFHitBehavior.HitType.NORMAL; h1.damage = 10
	h1.hitstun_frames = 10; h1.hitstop_frames = 0; h1.knockback_force = 3.0
	ch.receive_hit(h1, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "NORMAL->HIT_STUN")
	_eq(ch.health, 90, "hp=90")

	var h2 := DNFHitBehavior.new()
	h2.hit_type = DNFHitBehavior.HitType.KNOCK_BACK; h2.damage = 15
	h2.hitstun_frames = 20; h2.hitstop_frames = 0; h2.knockback_force = 8.0
	ch.receive_hit(h2, -1.0)
	_eq(ch.current_state, DNFStates.State.KNOCK_BACK, "KNOCK_BACK")
	_lt(ch.velocity.x, 0, "knocked left")

	var h3 := DNFHitBehavior.new()
	h3.hit_type = DNFHitBehavior.HitType.LAUNCH; h3.damage = 25
	h3.hitstun_frames = 30; h3.hitstop_frames = 0; h3.knockback_force = 4.0; h3.launch_force = -20.0
	ch.receive_hit(h3, 1.0)
	_eq(ch.current_state, DNFStates.State.AIR_BORNE, "LAUNCH->AIR_BORNE")
	_lt(ch.velocity.y, 0, "launched up")
	ch.queue_free()


# ═══════════════════════════════════════════════════════
#  PHASE 4: Move / InputType / Cancel
# ═══════════════════════════════════════════════════════

func _test_input_type_base() -> void:
	_begin("DNFInputType: base")
	var it := DNFInputType.new()
	_ok(not it.check_valid({"punch": true}), "base returns false")


func _test_input_equal_check() -> void:
	_begin("DNFInputEqualCheck: match")
	var iec := DNFInputEqualCheck.new()
	iec.input_name = "punch"; iec.input_value = true
	_ok(iec.check_valid({"punch": true}), "punch=true OK")
	_ok(not iec.check_valid({"punch": false}), "punch=false FAIL")
	_ok(not iec.check_valid({"kick": true}), "wrong key FAIL")


func _test_input_equal_missing() -> void:
	_begin("DNFInputEqualCheck: missing key")
	var iec := DNFInputEqualCheck.new()
	iec.input_name = "punch"; iec.input_value = true
	_ok(not iec.check_valid({}), "empty dict FAIL")


func _test_input_type_auto_flags() -> void:
	_begin("DNFInputType: auto flags")
	var it := DNFInputType.new()
	it.auto_valid = true
	_ok(it.check_valid({}), "auto_valid=true")
	it.auto_valid = false; it.auto_reject = true
	_ok(not it.check_valid({"a": 1}), "auto_reject=true")


func _mk_punch_move() -> DNFMove:
	var c := DNFInputEqualCheck.new()
	c.input_name = "punch"; c.input_value = true
	var m := DNFMove.new()
	m.move_name = "light_attack"; m.input_conditions = [c]
	m.state = DNFStates.State.ATTACK; m.duration = 20; m.forward_impulse = 3.0
	return m


func _mk_kick_move() -> DNFMove:
	var c := DNFInputEqualCheck.new()
	c.input_name = "kick"; c.input_value = true
	var m := DNFMove.new()
	m.move_name = "heavy_attack"; m.input_conditions = [c]
	m.state = DNFStates.State.ATTACK; m.duration = 25; m.forward_impulse = 4.0
	return m


func _test_move_check_input() -> void:
	_begin("DNFMove: check_input")
	var m := _mk_punch_move()
	_ok(m.check_input({"punch": true}), "punch OK")
	_ok(not m.check_input({"punch": false}), "false FAIL")
	_ok(not m.check_input({"kick": true}), "wrong key FAIL")


func _test_move_empty_conditions() -> void:
	_begin("DNFMove: no conditions")
	var m := DNFMove.new(); m.move_name = "test"
	_ok(not m.check_input({"punch": true}), "no conds -> false")


func _test_move_hit_behavior_link() -> void:
	_begin("DNFMove: hit_behavior link")
	var m := _mk_punch_move()
	var hb := DNFHitBehavior.new(); hb.damage = 15
	m.hit_behavior = hb
	_eq(m.hit_behavior.damage, 15, "linked dmg=15")


func _test_char_execute_move() -> void:
	_begin("DNFCharacter: execute_move")
	var ch := _mk_char()
	add_child(ch)
	var m := _mk_punch_move()
	ch.available_moves = [m]
	ch.execute_move(m)
	_eq(ch.current_state, DNFStates.State.ATTACK, "ATTACK")
	_eq(ch._current_move, m, "move set")
	_ok(not ch._has_hit_this_attack, "has_hit=false")
	_approx(ch.velocity.x, 3.0, 0.1, "impulse applied")
	ch.queue_free()


func _test_char_cancel_system() -> void:
	_begin("DNFCharacter: cancel system")
	var ch := _mk_char()
	add_child(ch)
	var light := _mk_punch_move()
	var heavy := _mk_kick_move()
	ch.available_moves = [light, heavy]
	ch.execute_move(light)
	ch.available_cancels = ["heavy_attack"]
	var ok := ch.try_cancel({"kick": true})
	_ok(ok, "cancel succeeded")
	_eq(ch._current_move, heavy, "switched to heavy")
	_eq(ch.state_tick, 0, "tick reset")
	ch.queue_free()


func _test_char_cancel_on_hit_only() -> void:
	_begin("DNFCharacter: cancel_on_hit_only")
	var ch := _mk_char()
	add_child(ch)
	var light := _mk_punch_move()
	var heavy := _mk_kick_move()
	ch.available_moves = [light, heavy]
	ch.execute_move(light)
	ch.available_cancels = ["heavy_attack"]
	ch._cancel_on_hit_only = true
	_ok(not ch.try_cancel({"kick": true}), "blocked without hit")
	ch._has_hit_this_attack = true
	_ok(ch.try_cancel({"kick": true}), "allowed after hit")
	ch.queue_free()


# ═══════════════════════════════════════════════════════
#  PHASE 5: Integration
# ═══════════════════════════════════════════════════════

func _mk_punch_hit() -> DNFHitBehavior:
	var hb := DNFHitBehavior.new()
	hb.damage = 10; hb.hit_type = DNFHitBehavior.HitType.NORMAL
	hb.hitstun_frames = 12; hb.hitstop_frames = 3
	hb.knockback_force = 4.0; hb.self_knockback = 1.5
	return hb


func _test_two_fighters_setup() -> void:
	_begin("Integration: 2 fighters init")
	var p1 := _mk_char(); var p2 := _mk_char()
	p2.facing_right = false
	add_child(p1); add_child(p2)
	_eq(p1.current_state, DNFStates.State.IDLE, "P1 IDLE")
	_eq(p2.current_state, DNFStates.State.IDLE, "P2 IDLE")
	_ok(p1.facing_right, "P1 right")
	_ok(not p2.facing_right, "P2 left")
	p1.queue_free(); p2.queue_free()


func _test_attack_damages_defender() -> void:
	_begin("Integration: attack damages")
	var p1 := _mk_char(); var p2 := _mk_char()
	add_child(p1); add_child(p2)
	var hit := _mk_punch_hit()
	p2.receive_hit(hit, 1.0)
	_eq(p2.health, 90, "P2 hp=90")
	_eq(p2.current_state, DNFStates.State.HIT_STUN, "P2 HIT_STUN")
	p1.on_hit_landed(p2, hit)
	_eq(p1.hitstop_remaining, 3, "P1 hitstop=3")
	_ok(p1._has_hit_this_attack, "P1 has_hit")
	p1.queue_free(); p2.queue_free()


func _test_combo_sequence() -> void:
	_begin("Integration: combo sequence")
	var p2 := _mk_char()
	add_child(p2)
	var punch := _mk_punch_hit()
	p2.receive_hit(punch, 1.0)
	_eq(p2.health, 90, "hit1 hp=90")
	p2.hitstop_remaining = 0
	p2.receive_hit(punch, 1.0)
	_eq(p2.health, 80, "hit2 hp=80")
	var launch := DNFHitBehavior.new()
	launch.damage = 20; launch.hit_type = DNFHitBehavior.HitType.LAUNCH
	launch.hitstun_frames = 30; launch.hitstop_frames = 0
	launch.knockback_force = 3.0; launch.launch_force = -20.0
	p2.hitstop_remaining = 0
	p2.receive_hit(launch, 1.0)
	_eq(p2.health, 60, "launch hp=60")
	_eq(p2.current_state, DNFStates.State.AIR_BORNE, "AIR_BORNE")
	p2.queue_free()


func _test_hitstop_symmetry() -> void:
	_begin("Integration: hitstop symmetry")
	var p1 := _mk_char(); var p2 := _mk_char()
	add_child(p1); add_child(p2)
	var hit := _mk_punch_hit()
	p2.receive_hit(hit, 1.0)
	p1.on_hit_landed(p2, hit)
	_eq(p1.hitstop_remaining, p2.hitstop_remaining, "symmetric hitstop")
	var t1 := p1.state_tick
	p1._physics_process(0.016)
	_eq(p1.state_tick, t1, "P1 frozen")
	p1.queue_free(); p2.queue_free()


func _test_knockout() -> void:
	_begin("Integration: KO")
	var p2 := _mk_char()
	add_child(p2)
	var big := DNFHitBehavior.new()
	big.damage = 150; big.hit_type = DNFHitBehavior.HitType.KNOCK_DOWN
	big.hitstun_frames = 30; big.hitstop_frames = 0; big.knockback_force = 10.0
	p2.receive_hit(big, 1.0)
	_eq(p2.health, 0, "hp clamped to 0")
	_eq(p2.current_state, DNFStates.State.KNOCK_DOWN, "KO KNOCK_DOWN")
	p2.queue_free()


func _test_state_flow_cycle() -> void:
	_begin("Integration: state flow cycle")
	var ch := _mk_char()
	add_child(ch)
	var visited: Array[String] = []
	ch.on_state_changed.connect(func(ns: int, _o: int): visited.append(DNFStates.state_name(ns)))

	ch._change_state(DNFStates.State.WALK)
	ch._change_state(DNFStates.State.ATTACK)

	# HIT_STUN (not KNOCK_DOWN) because is_on_floor() is always false in headless
	var hit := DNFHitBehavior.new()
	hit.damage = 5; hit.hit_type = DNFHitBehavior.HitType.NORMAL
	hit.hitstun_frames = 5; hit.hitstop_frames = 0; hit.knockback_force = 2.0
	ch.receive_hit(hit, 1.0)
	_eq(ch.current_state, DNFStates.State.HIT_STUN, "hit -> HIT_STUN")

	for i in range(6):
		ch._state_process()
		ch.state_tick += 1
	_eq(ch.current_state, DNFStates.State.IDLE, "HIT_STUN->IDLE")

	_ok("WALK" in visited, "visited WALK")
	_ok("ATTACK" in visited, "visited ATTACK")
	_ok("HIT_STUN" in visited, "visited HIT_STUN")
	_ok("IDLE" in visited, "returned IDLE")
	ch.queue_free()


func _test_save_load_mid_fight() -> void:
	_begin("Integration: save/load mid-fight")
	var p1 := _mk_char(); var p2 := _mk_char()
	add_child(p1); add_child(p2)
	p1._change_state(DNFStates.State.ATTACK)
	p1.state_tick = 7; p1._has_hit_this_attack = true
	p1.available_cancels = ["heavy"]
	p2.receive_hit(_mk_punch_hit(), 1.0)

	var s1 := p1._save_state(); var s2 := p2._save_state()

	var r1 := _mk_char(); var r2 := _mk_char()
	add_child(r1); add_child(r2)
	r1._load_state(s1); r2._load_state(s2)

	_eq(r1.current_state, DNFStates.State.ATTACK, "P1 restored ATTACK")
	_eq(r1.state_tick, 7, "P1 tick=7")
	_ok(r1._has_hit_this_attack, "P1 has_hit")
	_eq(r2.current_state, DNFStates.State.HIT_STUN, "P2 restored HIT_STUN")
	_eq(r2.health, 90, "P2 hp=90")

	p1.queue_free(); p2.queue_free()
	r1.queue_free(); r2.queue_free()


# ====================================================================
# Phase 6: Data Layer + FramePlayer + Phase 系统
# ====================================================================

func _test_frame_data_resource() -> void:
	_begin("FrameData: create + defaults")
	var fd = P_FrameData.new()
	_eq(fd.region, Rect2(), "default region empty")
	_eq(fd.duration, 1, "default duration 1")
	fd.region = Rect2(0, 0, 64, 64)
	fd.duration = 3
	_eq(fd.region, Rect2(0, 0, 64, 64), "region set")
	_eq(fd.duration, 3, "duration set")


func _test_animation_data_resource() -> void:
	_begin("AnimationData: frames + total")
	var anim = P_AnimData.new()
	anim.anim_name = "slash"
	anim.fps = 12
	var f1 = P_FrameData.new(); f1.duration = 2; f1.region = Rect2(0, 0, 32, 32)
	var f2 = P_FrameData.new(); f2.duration = 3; f2.region = Rect2(32, 0, 32, 32)
	var f3 = P_FrameData.new(); f3.duration = 1; f3.region = Rect2(64, 0, 32, 32)
	anim.frames = [f1, f2, f3]
	_eq(anim.get_total_frames(), 6, "total=2+3+1=6")
	_eq(anim.get_frame_at_index(0).region, Rect2(0, 0, 32, 32), "frame 0 = f1")
	_eq(anim.get_frame_at_index(1).region, Rect2(0, 0, 32, 32), "frame 1 = f1")
	_eq(anim.get_frame_at_index(2).region, Rect2(32, 0, 32, 32), "frame 2 = f2")
	_eq(anim.get_frame_at_index(4).region, Rect2(32, 0, 32, 32), "frame 4 = f2")
	_eq(anim.get_frame_at_index(5).region, Rect2(64, 0, 32, 32), "frame 5 = f3")
	_eq(anim.get_frame_at_index(99).region, Rect2(64, 0, 32, 32), "frame 99 = last")


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


func _test_skill_data_v2_resource() -> void:
	_begin("SkillDataV2: create with phases")
	var skill = _mk_test_skill()
	_eq(skill.skill_name, "test_slash", "name")
	_eq(skill.phases.size(), 1, "1 phase")
	_eq(skill.events.size(), 1, "1 event")
	_eq(skill.movement.size(), 1, "1 movement")
	_eq(skill.get_total_frames(), 6, "total frames from anim")


func _test_skill_data_v2_phase_query() -> void:
	_begin("SkillDataV2: phase query by frame")
	var skill = _mk_test_skill()
	_eq(skill.get_phases_at_frame(2).size(), 0, "frame 2 no phase")
	_eq(skill.get_phases_at_frame(3).size(), 1, "frame 3 has phase")
	_eq(skill.get_phases_at_frame(5).size(), 1, "frame 5 has phase")
	_eq(skill.get_movement_at_frame(1).size(), 1, "frame 1 has movement")
	_eq(skill.get_movement_at_frame(4).size(), 0, "frame 4 no movement")


func _test_skill_data_v2_event_query() -> void:
	_begin("SkillDataV2: event query by frame")
	var skill = _mk_test_skill()
	_eq(skill.get_events_at_frame(2).size(), 1, "frame 2 has event")
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


func _test_frame_player_basic() -> void:
	_begin("FramePlayer: play + tick")
	var fp = P_FramePlayer.new()
	add_child(fp)
	var anim = _mk_test_anim()

	# anim: f1(dur=2) f2(dur=3) f3(dur=1), total=6
	fp.play(anim)
	_ok(fp.is_playing(), "playing after play()")
	_eq(fp.get_current_frame_index(), 0, "starts at 0")

	fp.tick()  # timer=1 < dur=2 → stay at 0
	_eq(fp.get_current_frame_index(), 0, "still 0 (duration=2)")
	fp.tick()  # timer=2 >= dur=2 → advance to 1
	_eq(fp.get_current_frame_index(), 1, "frame 1 (still f1 region)")
	fp.tick()  # f_at(1)=f1(dur=2), timer=1 < 2
	_eq(fp.get_current_frame_index(), 1, "still 1")
	fp.tick()  # timer=2 >= 2 → advance to 2
	_eq(fp.get_current_frame_index(), 2, "frame 2 (f2 region)")
	for i in 3:  # f_at(2)=f2(dur=3), need 3 ticks to pass
		fp.tick()
	_eq(fp.get_current_frame_index(), 3, "frame 3 after f2 dur")
	fp.tick()  # f_at(3)=f2(dur=3), timer=1
	fp.tick()  # timer=2
	fp.tick()  # timer=3 >= 3 → advance to 4
	_eq(fp.get_current_frame_index(), 4, "frame 4")
	fp.tick()  # f_at(4)=f2(dur=3), timer=1
	fp.tick()  # timer=2
	fp.tick()  # timer=3 >= 3 → advance to 5
	_eq(fp.get_current_frame_index(), 5, "frame 5 (f3)")
	fp.tick()  # f_at(5)=f3(dur=1), timer=1 >= 1 → advance to 6 → finished
	_ok(not fp.is_playing(), "finished (no loop)")
	fp.queue_free()


func _test_frame_player_save_load() -> void:
	_begin("FramePlayer: save/load state")
	var fp = P_FramePlayer.new()
	add_child(fp)
	fp.play(_mk_test_anim())
	fp.tick(); fp.tick()  # after 2 ticks: index=1
	var state = fp._save_state()
	_eq(state["fi"], 1, "saved frame=1")
	_ok(state["pl"], "saved playing=true")

	var fp2 = P_FramePlayer.new()
	add_child(fp2)
	fp2._load_state(state)
	_eq(fp2.get_current_frame_index(), 1, "restored frame=1")
	fp.queue_free(); fp2.queue_free()


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


func _test_skill_component_v2_basic() -> void:
	_begin("SkillComponentV2: play_skill + tick")
	var fp = P_FramePlayer.new()
	add_child(fp)
	var hc = P_HitboxComp.new()
	add_child(hc)

	var sc = P_SkillCompV2.new()
	sc.frame_player_path = fp.get_path()
	sc.hitbox_component_path = hc.get_path()
	add_child(sc)

	var skill = _mk_test_skill()
	_ok(sc.play_skill(skill), "play_skill returns true")
	_ok(sc.is_active(), "active after play")
	_eq(sc.get_active_skill().skill_name, "test_slash", "active skill name")

	for i in 3:
		sc.tick()
	_eq(sc.get_current_frame(), fp.get_current_frame_index(), "frame synced")

	sc.interrupt()
	_ok(not sc.is_active(), "inactive after interrupt")

	fp.queue_free(); hc.queue_free(); sc.queue_free()


# -- Phase 6 helpers --

func _mk_test_anim():
	var anim = P_AnimData.new()
	anim.anim_name = "test_anim"
	anim.fps = 12
	var f1 = P_FrameData.new(); f1.duration = 2; f1.region = Rect2(0, 0, 32, 32)
	var f2 = P_FrameData.new(); f2.duration = 3; f2.region = Rect2(32, 0, 32, 32)
	var f3 = P_FrameData.new(); f3.duration = 1; f3.region = Rect2(64, 0, 32, 32)
	anim.frames = [f1, f2, f3]
	return anim


func _mk_test_skill():
	var skill = P_SkillDataV2.new()
	skill.skill_name = "test_slash"
	skill.display_name = "Test Slash"
	skill.animation = _mk_test_anim()

	var hd = P_HitboxData.new()
	hd.shape_size = Vector2(50, 80)
	hd.offset = Vector2(30, 0)

	var hb := DNFHitBehavior.new()
	hb.damage = 15

	var phase = P_AttackPhase.new()
	phase.start_frame = 3
	phase.end_frame = 5
	phase.hitbox = hd
	phase.hit_behavior = hb
	skill.phases = [phase]

	var ev = P_FrameEvent.new()
	ev.frame = 2
	ev.type = P_FrameEvent.EventType.PLAY_SOUND
	ev.data = {"audio": "slash.ogg"}
	skill.events = [ev]

	var mov = P_MovementPhase.new()
	mov.start_frame = 1
	mov.end_frame = 3
	mov.velocity = Vector2(5, 0)
	skill.movement = [mov]

	return skill
