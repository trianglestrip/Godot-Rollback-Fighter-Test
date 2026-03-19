# DNF Framework — Task 清单

## Phase 6: 核心数据层 + FramePlayer + Phase 系统 ⭐

### 6.1 Resource 数据层

- [ ] 6.1.1 `resources/animation/frame_data.gd` — FrameData（纯显示）
  - region: Rect2 — Atlas 切片区域
  - duration: int = 1 — 持续帧数
  - （不放 hitbox/event/movement！）

- [ ] 6.1.2 `resources/animation/animation_data.gd` — AnimationData
  - anim_name: String
  - fps: int = 12
  - frames: Array[FrameData]
  - loop: bool = false
  - get_total_frames() / get_total_duration()

- [ ] 6.1.3 `resources/skill/attack_phase.gd` — AttackPhase ★ 核心
  - start_frame: int
  - end_frame: int
  - hitbox: HitboxData — 该区间的碰撞体
  - hit_behavior: HitBehavior — 该区间的受击行为
  - events: Array[FrameEvent] — 区间内事件

- [ ] 6.1.4 `resources/skill/movement_phase.gd` — MovementPhase
  - start_frame: int
  - end_frame: int
  - velocity: Vector2
  - relative_to_facing: bool = true

- [ ] 6.1.5 `resources/skill/frame_event.gd` — FrameEvent（单帧事件）
  - frame: int — 触发帧
  - type: FrameEventType enum
    (SPAWN_EFFECT / PLAY_SOUND / CAMERA_SHAKE / SPAWN_PROJECTILE /
     APPLY_BUFF / SUPER_ARMOR_START / SUPER_ARMOR_END /
     INVINCIBLE_START / INVINCIBLE_END /
     CANCEL_WINDOW_OPEN / CANCEL_WINDOW_CLOSE / CUSTOM_SIGNAL)
  - data: Dictionary — 事件参数

- [ ] 6.1.6 `resources/combat/hitbox_data.gd` — HitboxData
  - shape: Vector2 — 碰撞体尺寸
  - offset: Vector2 — 相对角色原点偏移
  - hit_level: HitLevel enum (MID/LOW/OVERHEAD/UNBLOCKABLE)

- [ ] 6.1.7 `resources/combat/hit_behavior.gd` — HitBehavior（保留 + 扩充）
  - 保留: damage / hit_type / hitstun / hitstop / knockback / launch / self_knockback
  - 新增: damage_type (PHYSICAL_PERCENT/MAGICAL_PERCENT/INDEPENDENT)
  - 新增: element (NEUTRAL/FIRE/ICE/LIGHT/DARK)
  - 新增: skill_coefficient: float
  - 新增: fixed_damage: int

### 6.2 SkillData（重写）

- [ ] 6.2.1 `resources/skill/skill_data.gd`
  - skill_name / display_name: String
  - animation: AnimationData
  - phases: Array[AttackPhase] ★ 攻击区间
  - events: Array[FrameEvent] — 单帧事件
  - movement: Array[MovementPhase] — 位移区间
  - mp_cost / hp_cost / cooldown_frames: int
  - skill_coefficient: float
  - damage_type / element / super_armor_level
  - cancelable / cancel_into: Array[String]
  - ground_only / air_usable / priority: int
  - ui: SkillUIData
  - input_conditions: Array[InputCondition]

- [ ] 6.2.2 `resources/skill/skill_ui_data.gd`
  - icon: Texture2D
  - display_name / description: String
  - hotkey_hint: String

- [ ] 6.2.3 `resources/skill/input_condition.gd`
  - check_valid(input_dict) → bool
  - 子类: EqualCheck / CommandMotion / HoldCheck / DoubleTap

### 6.3 运行时

- [ ] 6.3.1 `runtime/frame/frame_player.gd` — FramePlayer（只管显示）
  - play(anim: AnimationData)
  - tick() — 推进帧计数
  - apply_display(f: FrameData) — 只设 sprite.region_rect
  - get_current_frame_index() / get_total_frames()
  - signal frame_changed(index) / animation_finished(anim_name)
  - _save_state / _load_state

- [ ] 6.3.2 `runtime/combat/hitbox_component.gd` — HitboxComponent
  - set_hitbox(hitbox: HitboxData, behavior: HitBehavior)
  - clear_all()
  - 内部动态管理 Area2D + CollisionShape2D
  - get_fighter() → Node
  - _save_state / _load_state

- [ ] 6.3.3 `runtime/combat/hurtbox_component.gd` — HurtboxComponent
  - activate() / deactivate()
  - get_fighter() → Node

- [ ] 6.3.4 `runtime/skill/skill_component.gd` — SkillComponent（重写）
  - play_skill(skill: SkillData)
  - tick() — 驱动 FramePlayer + Phase 匹配 + 事件触发
  - _match_phases(frame) — 匹配攻击区间
  - _match_movement(frame) — 匹配位移区间
  - _fire_events(frame) — 触发单帧事件
  - deduct_cost(skill) / start_cooldown(skill)
  - interrupt() / is_active()
  - _save_state / _load_state

### 6.4 CharacterData

- [ ] 6.4.1 `resources/character/character_data.gd`
  - character_name / display_name: String
  - atlas: Texture2D
  - animations: Dictionary (String → AnimationData)
  - skills: Array[SkillData]
  - stats: CharacterStats
  - portrait: Texture2D

### 6.5 目录迁移 + 兼容

- [ ] 6.5.1 创建 runtime/ resources/ editor/ 三层目录
- [ ] 6.5.2 迁移保留模块 (InputBuffer / FrameCharacterBody2D / DNFStates / DNFCharacter / CombatManager)
- [ ] 6.5.3 更新所有 preload/extends 路径
- [ ] 6.5.4 更新 plugin.gd 注册
- [ ] 6.5.5 适配现有测试
- [ ] 6.5.6 创建新示例 (SkillData .tres + Phase 配置)

## Phase 7: 属性系统 + 伤害公式

- [ ] 7.1 `resources/character/character_stats.gd` — 全属性 Resource
- [ ] 7.2 `resources/stats/stat_modifier.gd` — 属性修正器
- [ ] 7.3 `resources/stats/element_system.gd` — 属性克制
- [ ] 7.4 `runtime/combat/damage_calculator.gd` — 伤害公式
- [ ] 7.5 `runtime/stats/stats_component.gd` — 属性计算组件
- [ ] 7.6 重构 DNFCharacter 集成 CharacterStats
- [ ] 7.7 重构 CombatManager 使用 DamageCalculator
- [ ] 7.8 扩充 DNFStates (+DEAD/GRAB/GRABBED/CHANNELING/CHARGING/STUNNED/FROZEN/PETRIFIED)
- [ ] 7.9 测试 + 示例

## Phase 8: Buff/Debuff + 状态异常

- [ ] 8.1 `resources/buff/buff_data.gd`
- [ ] 8.2 `resources/buff/buff_effect.gd` + stat/dot/cc 子类
- [ ] 8.3 `runtime/buff/buff_component.gd`
- [ ] 8.4 DNFCharacter 集成 BuffComponent
- [ ] 8.5 测试 + 示例

## Phase 9: 技能深化 + 霸体 + 格挡/抓取

- [ ] 9.1 `runtime/combat/super_armor.gd`
- [ ] 9.2 格挡系统 (BLOCK + guard_break)
- [ ] 9.3 抓取系统 (GRAB/GRABBED + 解除)
- [ ] 9.4 蓄力/持续释放 (CHARGING/CHANNELING)
- [ ] 9.5 被动技能 (passive_manager)
- [ ] 9.6 测试 + 示例

## Phase 10: 编辑器 — Timeline + Phase Editor + Hitbox Preview ⭐

- [ ] 10.1 `editor/timeline/timeline_root.gd` — 时间轴主控件
  - 播放/暂停/帧跳转
  - 缩放/滚动
- [ ] 10.2 `editor/timeline/frame_ruler.gd` — 帧刻度尺
  - 绘制帧编号刻度线
  - 当前帧指示器
- [ ] 10.3 `editor/timeline/phase_track.gd` — 攻击区间轨道 ★
  - 拖拽创建攻击区间
  - 拖拽移动/拉伸区间边界
  - 选中区间 → emit phase_selected
  - draw_rect 彩色区间块
- [ ] 10.4 `editor/timeline/event_track.gd` — 事件轨道
  - 点击帧位置添加事件
  - draw_circle 事件标记
- [ ] 10.5 `editor/timeline/movement_track.gd` — 位移区间轨道
- [ ] 10.6 `editor/timeline/armor_track.gd` — 霸体/无敌轨道
- [ ] 10.7 `editor/preview/hitbox_preview.gd` — Sprite 上画碰撞体
  - 当前帧匹配 phase → 画 hitbox rect
  - 拖拽调整大小/位置
- [ ] 10.8 `editor/preview/sprite_preview.gd` — 帧 Sprite 预览
- [ ] 10.9 `editor/inspectors/dnf_inspector_plugin.gd` — Inspector 增强
  - 选中 Phase → 显示 hitbox/behavior 参数
  - 选中 Event → 显示 type/data 参数
- [ ] 10.10 注册 Bottom Panel 到 plugin.gd
- [ ] 10.11 Hitbox 模板系统 (Slash/Thrust/AOE/Projectile 预设)
- [ ] 10.12 批量操作 (选中多帧 → 应用 hitbox)

## Phase 11: 编辑器 — Skill + Character Editor

- [ ] 11.1 `editor/panels/skill_editor.gd`
  - 技能列表
  - 选动画 + 配 phases
  - MP/冷却/属性/霸体
  - 技能图标 + 输入条件
- [ ] 11.2 `editor/panels/character_editor.gd`
  - 角色列表 + Atlas 绑定
  - 动画管理 (SpriteSheet 自动切帧)
  - 技能列表管理
  - 属性配置
- [ ] 11.3 `editor/panels/effect_editor.gd`
- [ ] 11.4 模板系统 (近战/远程/Boss 预设 .tres)

## Phase 12: 敌人 AI + 集成示例

- [ ] 12.1 `resources/enemy/enemy_config.gd`
- [ ] 12.2 `resources/enemy/ai_behavior.gd`
- [ ] 12.3 `runtime/enemy/enemy_character.gd`
- [ ] 12.4 `runtime/enemy/ai_component.gd`
- [ ] 12.5 完整角色示例 (配置器创建)
- [ ] 12.6 完整敌人示例 (配置器创建)
- [ ] 12.7 README.md + 配置器教程
