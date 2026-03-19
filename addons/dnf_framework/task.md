# DNF Framework — Task 清单

## Phase 6: 帧级数据架构 + FramePlayer ⭐ 最高优先

### 6.1 Resource 数据层

- [ ] 6.1.1 `resources/animation/frame_data.gd` — FrameData Resource
  - region: Rect2 — Atlas 切片区域
  - duration: int = 1 — 该帧持续帧数
  - hitboxes: Array[HitboxData] — 该帧的碰撞体
  - events: Array[FrameEvent] — 该帧触发的事件
  - movement: Vector2 — 该帧的位移

- [ ] 6.1.2 `resources/animation/animation_data.gd` — AnimationData Resource
  - anim_name: String
  - fps: int = 12
  - frames: Array[FrameData]
  - loop: bool = false
  - get_total_frames() → int
  - get_total_duration() → int (所有 frame.duration 之和)

- [ ] 6.1.3 `resources/combat/hitbox_data.gd` — HitboxData Resource
  - shape: Vector2 — 碰撞体尺寸
  - offset: Vector2 — 相对角色原点偏移
  - hit_behavior: HitBehavior — 受击行为引用
  - hit_level: HitLevel enum (MID/LOW/OVERHEAD/UNBLOCKABLE)

- [ ] 6.1.4 `resources/frame_event/frame_event.gd` — FrameEvent Resource
  - type: FrameEventType enum
    - SPAWN_EFFECT — 生成特效
    - PLAY_SOUND — 播放音效
    - CAMERA_SHAKE — 镜头震动
    - SPAWN_PROJECTILE — 生成弹道
    - APPLY_BUFF — 施加 Buff
    - SUPER_ARMOR_START — 霸体开始
    - SUPER_ARMOR_END — 霸体结束
    - INVINCIBLE_START — 无敌开始
    - INVINCIBLE_END — 无敌结束
    - CANCEL_WINDOW_OPEN — 打开取消窗口
    - CANCEL_WINDOW_CLOSE — 关闭取消窗口
    - CUSTOM_SIGNAL — 自定义信号
  - data: Dictionary — 事件参数

- [ ] 6.1.5 `resources/combat/hit_behavior.gd` — HitBehavior (保留 + 扩充)
  - 原有字段保留
  - 新增: damage_type (PHYSICAL_PERCENT/MAGICAL_PERCENT/INDEPENDENT)
  - 新增: element (NEUTRAL/FIRE/ICE/LIGHT/DARK)
  - 新增: skill_coefficient: float
  - 新增: fixed_damage: int

### 6.2 运行时

- [ ] 6.2.1 `runtime/frame/frame_player.gd` — FramePlayer
  - play(anim: AnimationData)
  - tick() — 每帧推进
  - apply_frame(f: FrameData) — 核心：设 sprite + hitbox + event + movement
  - stop() / pause() / resume()
  - get_current_frame_index() / get_current_frame_data()
  - signal frame_changed(index, frame_data)
  - signal animation_finished(anim_name)
  - _save_state / _load_state

- [ ] 6.2.2 `runtime/combat/hitbox_component.gd` — HitboxComponent
  - set_hitboxes(hitbox_list: Array[HitboxData]) — 每帧调用
  - clear_all() — 清除所有活跃碰撞体
  - get_active_hitboxes() → Array
  - 内部动态管理 Area2D + CollisionShape2D
  - _save_state / _load_state

- [ ] 6.2.3 `runtime/combat/hurtbox_component.gd` — HurtboxComponent
  - activate() / deactivate()
  - get_fighter() → Node

- [ ] 6.2.4 重写 `runtime/skill/skill_component.gd`
  - play_skill(skill: SkillData)
  - deduct_cost(skill) — 扣 MP/HP
  - start_cooldown(skill)
  - apply_super_armor(skill)
  - interrupt()
  - tick() — 委托给 FramePlayer.tick()

### 6.3 重写 SkillData

- [ ] 6.3.1 `resources/skill/skill_data.gd`
  - skill_name / display_name: String
  - animation: AnimationData — 直接引用（不是 anim_name 字符串）
  - mp_cost / hp_cost / special_cost: int
  - cooldown_frames: int
  - skill_level / max_level / sp_cost: int
  - skill_coefficient: float
  - damage_type: DamageType
  - element: Element
  - super_armor_level: SuperArmorLevel
  - priority: int
  - cancelable: bool
  - cancel_window: Vector2i
  - cancel_into: Array[String]
  - ground_only / air_usable: bool
  - is_passive / is_buff: bool
  - ui: SkillUIData
  - input_conditions: Array[InputCondition]

- [ ] 6.3.2 `resources/skill/skill_ui_data.gd`
  - icon: Texture2D
  - display_name / description: String
  - hotkey_hint: String
  - slot_index: int

- [ ] 6.3.3 `resources/skill/input_condition.gd` — 合并原 InputType 体系
  - check_valid(input_dict: Dictionary) → bool
  - 子类: EqualCheck / CommandMotion / HoldCheck / DoubleTap

### 6.4 目录迁移 + 兼容

- [ ] 6.4.1 创建 runtime/ resources/ editor/ 三层目录
- [ ] 6.4.2 迁移保留的模块 (InputBuffer → runtime/input/, FrameCharacterBody2D → runtime/character/, etc.)
- [ ] 6.4.3 更新所有 preload/extends 路径
- [ ] 6.4.4 更新 plugin.gd 注册
- [ ] 6.4.5 适配现有 152 个测试
- [ ] 6.4.6 旧 examples 兼容适配或重写

### 6.5 CharacterData

- [ ] 6.5.1 `resources/character/character_data.gd`
  - name / display_name: String
  - atlas: Texture2D
  - animations: Dictionary (String → AnimationData)
  - skills: Array[SkillData]
  - stats: CharacterStats
  - portrait: Texture2D

## Phase 7: 属性系统 + 伤害公式

- [ ] 7.1 `resources/character/character_stats.gd` — 全属性
- [ ] 7.2 `resources/stats/stat_modifier.gd` — 修正器
- [ ] 7.3 `resources/stats/element_system.gd` — 属性克制
- [ ] 7.4 `runtime/combat/damage_calculator.gd` — 伤害公式
- [ ] 7.5 `runtime/stats/stats_component.gd` — 属性计算组件
- [ ] 7.6 重构 DNFCharacter 集成 CharacterStats + StatsComponent
- [ ] 7.7 重构 CombatManager 使用 DamageCalculator
- [ ] 7.8 扩充 DNFStates (+DEAD/GRAB/GRABBED/CHANNELING/CHARGING/STUNNED/FROZEN/PETRIFIED)
- [ ] 7.9 测试 + 示例

## Phase 8: Buff/Debuff + 状态异常

- [ ] 8.1 `resources/buff/buff_data.gd`
- [ ] 8.2 `resources/buff/buff_effect.gd` 基类
- [ ] 8.3 `resources/buff/stat_buff_effect.gd`
- [ ] 8.4 `resources/buff/dot_buff_effect.gd`
- [ ] 8.5 `resources/buff/crowd_control_effect.gd`
- [ ] 8.6 `runtime/buff/buff_component.gd`
- [ ] 8.7 `runtime/buff/buff_processor.gd`
- [ ] 8.8 DNFCharacter 集成 BuffComponent
- [ ] 8.9 测试 + 示例

## Phase 9: 技能深化 + 霸体 + 格挡抓取

- [ ] 9.1 `runtime/combat/super_armor.gd`
- [ ] 9.2 `runtime/skill/passive_manager.gd`
- [ ] 9.3 格挡系统 (BLOCK 状态逻辑 + guard_break)
- [ ] 9.4 抓取系统 (GRAB/GRABBED + 解除)
- [ ] 9.5 蓄力技能 (CHARGING 状态)
- [ ] 9.6 持续释放 (CHANNELING 状态)
- [ ] 9.7 测试 + 示例

## Phase 10: 编辑器 — Animation + Timeline + Hitbox

- [ ] 10.1 `editor/panels/animation_editor.gd` — Atlas 切帧 / 帧排序 / fps / 预览
- [ ] 10.2 `editor/timeline/frame_timeline.gd` — 帧时间轴控件
  - 缩放/滚动
  - 点击帧选中
  - 添加/删除 event
  - 拖拽 duration
  - hitbox/特效/霸体/无敌帧 多轨道标记
- [ ] 10.3 `editor/preview/hitbox_preview.gd` — Sprite 上画碰撞体
  - draw_rect 实时预览
  - 拖拽调整大小/位置
  - 多 hitbox 支持
- [ ] 10.4 `editor/preview/sprite_preview.gd` — 帧 Sprite 预览
- [ ] 10.5 `editor/inspectors/dnf_inspector_plugin.gd` — Inspector 增强
- [ ] 10.6 注册 Bottom Panel 到 EditorPlugin

## Phase 11: 编辑器 — Skill + Character + Effect

- [ ] 11.1 `editor/panels/skill_editor.gd` — 技能编辑器
  - 选择动画
  - 配 MP/冷却/属性/霸体
  - 绑定特效帧
  - 技能图标
  - 输入条件
- [ ] 11.2 `editor/panels/character_editor.gd` — 角色编辑器
  - 角色列表
  - Atlas 绑定
  - 动画管理
  - 技能列表管理
  - 属性配置
- [ ] 11.3 `editor/panels/effect_editor.gd` — 特效编辑器
- [ ] 11.4 模板系统（近战/远程/Boss 预设 .tres）

## Phase 12: 敌人 AI + 集成示例 + 文档

- [ ] 12.1 `resources/enemy/enemy_config.gd`
- [ ] 12.2 `resources/enemy/ai_behavior.gd`
- [ ] 12.3 `runtime/enemy/enemy_character.gd`
- [ ] 12.4 `runtime/enemy/ai_component.gd`
- [ ] 12.5 完整角色示例（配置器创建）
- [ ] 12.6 完整敌人示例（配置器创建）
- [ ] 12.7 更新 README.md
- [ ] 12.8 配置器使用教程
