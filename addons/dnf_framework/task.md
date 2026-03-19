# DNF Framework — Task 清单

## Phase 6: 属性系统 + 伤害公式

- [ ] 6.1 `stats/character_stats.gd` — CharacterStats Resource
  - HP/MP (当前值 + 最大值)
  - STR/INT/VIT/SPR 四维
  - 物攻/魔攻/独立攻击
  - 物防/魔防 (减伤上限 75%)
  - 攻速/施法速度/移速 (各自上限)
  - 物理暴击率/魔法暴击率/暴击伤害
  - 命中率/回避率 (回避上限 75%)
  - 火/冰/光/暗属性强化 (4 个 int)
  - 火/冰/光/暗属性抗性 (4 个 int, 上限 100)
  - HP/MP 回复速率

- [ ] 6.2 `stats/stat_modifier.gd` — 属性修正器
  - 修正类型: FLAT / PERCENT / FINAL_MULTIPLY
  - source: String (来源标记)
  - stat_name: String (目标属性名)
  - value: float
  - duration: int (-1=永久)

- [ ] 6.3 `stats/damage_calculator.gd` — 伤害公式
  - calc_percent_physical(skill_coeff, attacker_stats, defender_stats) → int
  - calc_percent_magical(skill_coeff, attacker_stats, defender_stats) → int
  - calc_independent(skill_fixed, attacker_stats, defender_stats) → int
  - apply_element_bonus(base_dmg, element, attacker_ele_enhance, defender_ele_resist) → int
  - apply_critical(base_dmg, crit_rate, crit_damage) → {damage: int, is_crit: bool}
  - apply_back_attack(base_dmg, is_back) → int
  - calc_final_damage(...) → {damage, is_crit, is_back, element}

- [ ] 6.4 `stats/element_system.gd` — 属性系统
  - Element 枚举: NEUTRAL, FIRE, ICE, LIGHT, DARK
  - DamageType 枚举: PHYSICAL_PERCENT, MAGICAL_PERCENT, INDEPENDENT
  - PhysicalAttackType 枚举: BASH, SLASH, PROJECTILE, EXPLOSION, NULL_TYPE
  - 克制计算函数

- [ ] 6.5 重构 DNFCharacter 集成 CharacterStats
  - @export var base_stats: CharacterStats
  - 运行时属性 = base + modifiers
  - MP 扣除/回复逻辑
  - 移除硬编码 max_health → 用 stats.max_hp

- [ ] 6.6 重构 HitBehavior 加入新字段
  - damage_type: DamageType
  - element: Element
  - skill_coefficient: float (百分比伤害用)
  - fixed_damage: int (独立攻击用)
  - is_back_attackable: bool

- [ ] 6.7 重构 CombatManager 使用 DamageCalculator
  - _resolve_hit 中调用 DamageCalculator
  - 传递攻击者/防御者 stats

- [ ] 6.8 扩充 DNFStates 状态枚举
  - 新增: DEAD, GRAB, GRABBED, CHANNELING, CHARGING
  - 新增: STUNNED, FROZEN, PETRIFIED (状态异常用)
  - 新增: SUPER_ARMOR, INVINCIBLE
  - 更新 helper 函数

- [ ] 6.9 测试: 属性系统 + 伤害公式单元测试
- [ ] 6.10 示例: 使用 CharacterStats 的角色 .tres

## Phase 7: Buff/Debuff + 状态异常

- [ ] 7.1 `buff/buff_data.gd` — BuffData Resource
  - buff_name / display_name / icon: Texture2D
  - duration_frames: int (-1=永久)
  - max_stacks: int
  - refresh_policy: RESET_TIMER / EXTEND_TIMER / ADD_STACK
  - effects: Array[BuffEffect]
  - is_debuff: bool
  - is_dispellable: bool

- [ ] 7.2 `buff/buff_effect.gd` — BuffEffect 基类
  - apply(target_stats) / remove(target_stats) / tick(target, frame)

- [ ] 7.3 `buff/stat_buff_effect.gd` — 属性修正
  - stat_name: String
  - modifier_type: FLAT / PERCENT
  - value: float

- [ ] 7.4 `buff/dot_buff_effect.gd` — 持续伤害
  - dot_type: BURN / POISON / BLEED / SHOCK
  - damage_per_tick: int
  - tick_interval: int (每 N 帧触发一次)
  - element: Element

- [ ] 7.5 `buff/crowd_control_effect.gd` — 控制效果
  - cc_type: STUN / FREEZE / PETRIFY / SLEEP / BIND / SLOW / CONFUSION / BLIND
  - slow_percent: float (减速用)
  - 对应状态切换

- [ ] 7.6 `buff/buff_component.gd` — Buff 管理组件
  - active_buffs: Array
  - add_buff(buff_data, source, stacks) / remove_buff(buff_name)
  - tick_buffs() — 每帧处理
  - get_total_stat_modifier(stat_name) → float
  - has_cc(cc_type) → bool
  - _save_state / _load_state

- [ ] 7.7 `buff/status_effect.gd` — 状态异常数据
  - abnormal_type 枚举 (BURN/FREEZE/SHOCK/POISON/BLEED/STUN/PETRIFY/SLEEP/BIND/SLOW/CONFUSION/BLIND/CURSE)
  - trigger_rate: float (触发概率)
  - tolerance_key: String (耐性属性名)
  - base_duration: int

- [ ] 7.8 DNFCharacter 集成 BuffComponent
  - 每帧 tick_buffs
  - 属性修正叠加到 effective_stats
  - CC 状态切换

- [ ] 7.9 测试: Buff 叠加/过期/属性修正/DoT
- [ ] 7.10 示例: Buff 技能 + 状态异常 .tres

## Phase 8: 技能系统深化 + 霸体

- [ ] 8.1 扩充 SkillData
  - mp_cost / hp_cost / special_cost: int
  - skill_level / max_level / sp_cost_per_level: int
  - damage_type: DamageType
  - element: Element
  - skill_coefficient: float (按等级缩放)
  - super_armor_level: SuperArmorLevel
  - invincible_frame_range: Vector2i
  - hit_count: int
  - is_passive / is_buff / is_awakening: bool
  - prerequisites: Array[String]
  - cancel_into: Array[String]

- [ ] 8.2 `combat/super_armor.gd` — 霸体系统
  - SuperArmorLevel 枚举: NONE / HALF / BREAKABLE / FULL
  - breakable_hp: int (可破霸体血量)
  - receive_hit_check(hit_behavior) → bool (是否中断)

- [ ] 8.3 `skill/skill_super_armor_event.gd` — 霸体帧事件
  - armor_level: SuperArmorLevel
  - frame_range: Vector2i

- [ ] 8.4 `skill/skill_sound_event.gd` — 音效帧事件
  - audio_stream: AudioStream
  - volume_db: float

- [ ] 8.5 `skill/skill_spawn_event.gd` — 投射物/召唤物事件
  - spawn_scene: PackedScene
  - spawn_offset: Vector2
  - relative_to_facing: bool

- [ ] 8.6 `skill/passive_skill.gd` — 被动技能
  - stat_modifiers: Array[StatModifier]
  - conditional_effects: Array[ConditionalEffect]

- [ ] 8.7 格挡系统实现
  - BLOCK 状态逻辑
  - guard_break 判定
  - 格挡减伤

- [ ] 8.8 抓取系统实现
  - GRAB / GRABBED 状态
  - 抓取判定 (距离/状态)
  - 解除机制

- [ ] 8.9 测试: 技能 MP 消耗 / 霸体 / 多段打击
- [ ] 8.10 示例: 完整技能配置 .tres (带霸体/消耗/属性)

## Phase 9: 敌人 AI 系统

- [ ] 9.1 `enemy/enemy_config.gd` — EnemyConfig Resource
  - enemy_type: NORMAL / ELITE / BOSS / RAID
  - base_stats: CharacterStats
  - skills: Array[SkillData]
  - super_armor_config: SuperArmor
  - elemental_resistances: Dictionary
  - abnormal_tolerances: Dictionary
  - drop_table: Array[DropEntry]
  - death_animation: String

- [ ] 9.2 `enemy/ai_behavior.gd` — AIBehavior Resource
  - behavior_type: IDLE / PATROL / CHASE / ATTACK / EVADE / PHASE_CHANGE
  - trigger_conditions: Array[AICondition]
  - attack_pattern: RANDOM / SEQUENCE / CONDITIONAL
  - skill_weights: Dictionary (技能名 → 权重)
  - phase_hp_threshold: float (Boss 阶段 HP%)

- [ ] 9.3 `enemy/ai_component.gd` — AI 组件
  - behaviors: Array[AIBehavior]
  - current_behavior: AIBehavior
  - target: Node
  - tick_ai() — 每帧决策
  - _save_state / _load_state

- [ ] 9.4 `enemy/enemy_character.gd` — 敌人角色基类
  - extends DNFCharacter
  - enemy_config: EnemyConfig
  - ai_component: AIComponent

- [ ] 9.5 测试: AI 行为切换 / 目标追踪 / Boss 阶段
- [ ] 9.6 示例: 近战敌人 + Boss 敌人 .tres

## Phase 10: 编辑器配置器

- [ ] 10.1 `character/character_config.gd` — CharacterConfig Resource
  - character_name / display_name: String
  - base_stats: CharacterStats
  - state_anim_map: Dictionary (State → anim_name)
  - skills: Array[SkillData]
  - moves: Array[DNFMove]
  - portrait: Texture2D

- [ ] 10.2 `skill/skill_frame_data.gd` — SkillFrameData Resource
  - total_frames: int
  - startup_frames / active_frames / recovery_frames: int
  - hitbox_entries: Array[HitboxFrameEntry]
  - effect_entries: Array[EffectFrameEntry]
  - super_armor_ranges: Array[Vector2i]
  - invincible_ranges: Array[Vector2i]
  - cancel_window: Vector2i

- [ ] 10.3 `skill/skill_ui_data.gd` — SkillUIData Resource
  - icon: Texture2D
  - display_name / description: String
  - hotkey_hint: String
  - show_cooldown: bool
  - slot_index: int

- [ ] 10.4 `combat/hitbox_data.gd` — HitboxFrameEntry Resource
  - rect: Rect2
  - offset: Vector2
  - frame_range: Vector2i
  - hit_behavior: DNFHitBehavior

- [ ] 10.5 `editor/dnf_inspector_plugin.gd` — Inspector 增强
  - 注册到 plugin.gd
  - CharacterStats 属性分组显示
  - SkillData 帧数据预览
  - HitBehavior 参数组

- [ ] 10.6 `editor/skill_editor_panel.gd` — 技能帧编辑器 (Bottom Panel)
  - 帧时间轴 (FrameTimeline 控件)
  - 碰撞体预览 (HitboxPreview 控件)
  - 特效帧标记
  - 霸体/无敌帧区间
  - 属性编辑面板

- [ ] 10.7 `editor/character_config_editor.gd` — 角色配置 Dock
  - 属性编辑
  - 状态-动画映射
  - 技能/招式列表管理
  - 一键生成角色场景

- [ ] 10.8 plugin.gd 补全所有自定义类型注册
- [ ] 10.9 目录结构重组 + 引用更新

## Phase 11: 集成示例 + 文档

- [ ] 11.1 用配置器创建完整角色 (含属性/技能/动画)
- [ ] 11.2 用配置器创建敌人 (含 AI/技能/霸体)
- [ ] 11.3 Buff/状态异常完整演示
- [ ] 11.4 伤害公式 + 属性克制演示
- [ ] 11.5 模板系统 (近战型/远程型/Boss 型)
- [ ] 11.6 更新 README.md 完整 API 文档
- [ ] 11.7 配置器使用教程
