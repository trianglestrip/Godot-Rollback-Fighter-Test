extends Node2D

## Phase 6: SkillData + AttackPhase 示例
## 演示程序化创建技能数据、DNFAnimatedSprite2D、HitboxComponent、SkillComponent 的完整流程

const P_HitboxData = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")
const P_HitBehavior = preload("res://addons/dnf_framework/runtime/combat/hit_behavior.gd")
const P_AttackPhase = preload("res://addons/dnf_framework/resources/skill/attack_phase.gd")
const P_MovementPhase = preload("res://addons/dnf_framework/resources/skill/movement_phase.gd")
const P_FrameEvent = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")
const P_SkillData = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const P_AnimSprite = preload("res://addons/dnf_framework/runtime/frame/animated_sprite.gd")
const P_HitboxComp = preload("res://addons/dnf_framework/runtime/combat/hitbox_component.gd")
const P_SkillComp = preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd")

var velocity: Vector2 = Vector2.ZERO

var _skill_comp: Node
var _quit_delay: int = -1


func _ready() -> void:
	print("=== Phase 6: SkillData + AttackPhase 示例 ===")

	# 创建原生 SpriteFrames，添加一个 3 帧动画
	var sf := SpriteFrames.new()
	sf.add_animation("ghost_slash")
	sf.set_animation_speed("ghost_slash", 12)
	sf.set_animation_loop("ghost_slash", false)
	# 3 帧无纹理（headless 模式）
	for i in 3:
		sf.add_frame("ghost_slash", PlaceholderTexture2D.new())

	var hitbox_data := P_HitboxData.new()
	hitbox_data.shape_size = Vector2(60, 80)
	hitbox_data.offset = Vector2(30, 0)

	var hit_behavior := P_HitBehavior.new()
	hit_behavior.damage = 25
	hit_behavior.hit_type = P_HitBehavior.HitType.KNOCK_BACK
	hit_behavior.hitstun_frames = 18

	var attack_phase := P_AttackPhase.new()
	attack_phase.start_frame = 1
	attack_phase.end_frame = 2
	attack_phase.hitbox = hitbox_data
	attack_phase.hit_behavior = hit_behavior
	attack_phase.events = []

	var movement_phase := P_MovementPhase.new()
	movement_phase.start_frame = 0
	movement_phase.end_frame = 1
	movement_phase.velocity = Vector2(6, 0)

	var frame_event := P_FrameEvent.new()
	frame_event.frame = 1
	frame_event.type = P_FrameEvent.EventType.PLAY_SOUND
	frame_event.data = {"audio": "slash.ogg"}

	var skill := P_SkillData.new()
	skill.skill_name = "ghost_slash"
	skill.display_name = "鬼斩"
	skill.animation_name = "ghost_slash"
	skill.total_frames = 3
	skill.phases = [attack_phase]
	skill.movement = [movement_phase]
	skill.events = [frame_event]
	skill.mp_cost = 20
	skill.cooldown_frames = 60

	var anim_sprite := P_AnimSprite.new()
	anim_sprite.name = "AnimatedSprite"
	anim_sprite.sprite_frames = sf

	var hitbox_comp := P_HitboxComp.new()
	hitbox_comp.name = "HitboxComponent"

	_skill_comp = P_SkillComp.new()
	_skill_comp.name = "SkillComponent"
	_skill_comp.animated_sprite_path = NodePath("AnimatedSprite")
	_skill_comp.hitbox_component_path = NodePath("HitboxComponent")
	_skill_comp.add_child(anim_sprite)
	_skill_comp.add_child(hitbox_comp)
	add_child(_skill_comp)

	_skill_comp.skill_started.connect(_on_skill_started)
	_skill_comp.skill_ended.connect(_on_skill_ended)
	_skill_comp.phase_entered.connect(_on_phase_entered)
	_skill_comp.phase_exited.connect(_on_phase_exited)
	_skill_comp.event_fired.connect(_on_event_fired)

	_skill_comp.play_skill(skill)


func _on_skill_started(skill: Resource) -> void:
	print("[信号] 技能开始: ", skill.display_name, " (", skill.skill_name, ")")


func _on_skill_ended(skill: Resource) -> void:
	print("[信号] 技能结束: ", skill.display_name)
	_quit_delay = 30


func _on_phase_entered(phase: Resource, frame_val: int) -> void:
	print("[信号] 进入攻击区间: 帧 ", phase.start_frame, "~", phase.end_frame, " (当前帧 ", frame_val, ")")


func _on_phase_exited(phase: Resource, frame_val: int) -> void:
	print("[信号] 退出攻击区间: 帧 ", phase.start_frame, "~", phase.end_frame, " (当前帧 ", frame_val, ")")


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
