extends Node2D

## Phase 6: SkillDataV2 + AttackPhase 示例
## 演示程序化创建技能数据、FramePlayer、HitboxComponent、SkillComponentV2 的完整流程
## 可在无头模式下运行

# 使用 preload 引用所有类（兼容 headless）
const P_AnimData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")
const P_FrameData = preload("res://addons/dnf_framework/resources/animation/frame_data.gd")
const P_HitboxData = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")
const P_HitBehavior = preload("res://addons/dnf_framework/combat/scripts/hit_behavior.gd")
const P_AttackPhase = preload("res://addons/dnf_framework/resources/skill/attack_phase.gd")
const P_MovementPhase = preload("res://addons/dnf_framework/resources/skill/movement_phase.gd")
const P_FrameEvent = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")
const P_SkillDataV2 = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const P_FramePlayer = preload("res://addons/dnf_framework/runtime/frame/frame_player.gd")
const P_HitboxComp = preload("res://addons/dnf_framework/runtime/combat/hitbox_component.gd")
const P_SkillCompV2 = preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd")

## 供 SkillComponentV2 位移系统使用
var velocity: Vector2 = Vector2.ZERO

var _skill_comp: Node
var _quit_delay: int = -1


func _ready() -> void:
	print("=== Phase 6: SkillDataV2 + AttackPhase 示例 ===")

	# 1. 创建动画数据：3 帧，时长 3+4+2=9 逻辑帧
	var anim_data := P_AnimData.new()
	anim_data.anim_name = "ghost_slash"
	anim_data.fps = 12
	anim_data.frames = [
		_create_frame(3),
		_create_frame(4),
		_create_frame(2),
	]

	# 2. 创建碰撞体数据
	var hitbox_data := P_HitboxData.new()
	hitbox_data.shape_size = Vector2(60, 80)
	hitbox_data.offset = Vector2(30, 0)

	# 3. 创建受击行为
	var hit_behavior := P_HitBehavior.new()
	hit_behavior.damage = 25
	hit_behavior.hit_type = P_HitBehavior.HitType.KNOCK_BACK
	hit_behavior.hitstun_frames = 18

	# 4. 创建攻击区间（帧 3~6）
	var attack_phase := P_AttackPhase.new()
	attack_phase.start_frame = 3
	attack_phase.end_frame = 6
	attack_phase.hitbox = hitbox_data
	attack_phase.hit_behavior = hit_behavior
	attack_phase.events = []  # 使用 plain Array

	# 5. 创建位移区间（帧 1~4）
	var movement_phase := P_MovementPhase.new()
	movement_phase.start_frame = 1
	movement_phase.end_frame = 4
	movement_phase.velocity = Vector2(6, 0)

	# 6. 创建帧事件（帧 3 播放音效）
	var frame_event := P_FrameEvent.new()
	frame_event.frame = 3
	frame_event.type = P_FrameEvent.EventType.PLAY_SOUND
	frame_event.data = {"audio": "slash.ogg"}

	# 7. 组合为 SkillDataV2
	var skill := P_SkillDataV2.new()
	skill.skill_name = "ghost_slash"
	skill.display_name = "鬼斩"
	skill.animation = anim_data
	skill.phases = [attack_phase]
	skill.movement = [movement_phase]
	skill.events = [frame_event]
	skill.mp_cost = 20
	skill.cooldown_frames = 60

	# 8. 创建节点层级
	var frame_player := P_FramePlayer.new()
	frame_player.name = "FramePlayer"

	var hitbox_comp := P_HitboxComp.new()
	hitbox_comp.name = "HitboxComponent"

	_skill_comp = P_SkillCompV2.new()
	_skill_comp.name = "SkillComponentV2"
	_skill_comp.frame_player_path = NodePath("FramePlayer")
	_skill_comp.hitbox_component_path = NodePath("HitboxComponent")
	_skill_comp.add_child(frame_player)
	_skill_comp.add_child(hitbox_comp)
	add_child(_skill_comp)

	# 9. 连接信号
	_skill_comp.skill_started.connect(_on_skill_started)
	_skill_comp.skill_ended.connect(_on_skill_ended)
	_skill_comp.phase_entered.connect(_on_phase_entered)
	_skill_comp.phase_exited.connect(_on_phase_exited)
	_skill_comp.event_fired.connect(_on_event_fired)

	# 10. 播放技能
	_skill_comp.play_skill(skill)


func _create_frame(dur: int) -> Resource:
	var fd := P_FrameData.new()
	fd.duration = dur
	fd.region = Rect2()
	fd.anchor_offset = Vector2.ZERO
	return fd


func _on_skill_started(skill: Resource) -> void:
	print("[信号] 技能开始: ", skill.display_name, " (", skill.skill_name, ")")


func _on_skill_ended(skill: Resource) -> void:
	print("[信号] 技能结束: ", skill.display_name)
	_quit_delay = 30  # 约 0.5 秒后退出


func _on_phase_entered(phase: Resource, frame: int) -> void:
	print("[信号] 进入攻击区间: 帧 ", phase.start_frame, "~", phase.end_frame, " (当前帧 ", frame, ")")


func _on_phase_exited(phase: Resource, frame: int) -> void:
	print("[信号] 退出攻击区间: 帧 ", phase.start_frame, "~", phase.end_frame, " (当前帧 ", frame, ")")


func _on_event_fired(event: Resource) -> void:
	print("[信号] 帧事件触发: 帧 ", event.frame, " 类型 ", event.type, " 数据 ", event.data)


func _physics_process(_delta: float) -> void:
	if _quit_delay >= 0:
		_quit_delay -= 1
		if _quit_delay <= 0:
			print("示例运行完毕，退出。")
			get_tree().quit()
		return

	if _skill_comp:
		_skill_comp.tick()

		var frame_idx := _skill_comp.get_current_frame()
		var is_active := _skill_comp.is_active()
		var active_phases: Array = []
		if _skill_comp.get_active_skill():
			for p in _skill_comp.get_active_skill().phases:
				if p.contains_frame(frame_idx):
					active_phases.append("帧%d~%d" % [p.start_frame, p.end_frame])

		print("[状态] 帧索引=%d 激活=%s 当前区间=%s" % [frame_idx, is_active, str(active_phases)])
