# DNF Framework — Task 清单

## Phase 1-5: 基础框架 ✅ 全部完成

- [x] InputBuffer（帧输入缓冲 + 连招检测 + 方向历史）
- [x] FrameCharacterBody2D（帧驱动物理角色 + save/load）
- [x] DNFStates + DNFCharacter（状态机 + 受击 + 取消系统）
- [x] DNFHitbox / DNFHurtbox / DNFHitBehavior / DNFCombatManager
- [x] DNFMove + DNFInputType + DNFInputEqualCheck + DNFCommandMotionInput
- [x] 5 个示例场景 + 自动化测试

---

## Phase 6: 核心数据层 + DNFAnimatedSprite2D + Phase 系统 ✅

### 6.1 Resource 数据层 ✅

- [x] 6.1.1 使用 Godot 原生 SpriteFrames 管理帧动画（已移除自定义 DNFFrameData/DNFAnimationData/DNFSpriteFrames）
- [x] 6.1.2 `resources/skill/attack_phase.gd` — DNFAttackPhase ★
- [x] 6.1.3 `resources/skill/movement_phase.gd` — DNFMovementPhase
- [x] 6.1.4 `resources/skill/frame_event.gd` — DNFFrameEvent（12 种事件类型）
- [x] 6.1.5 `resources/combat/hitbox_data.gd` — DNFHitboxData（含 HitLevel 枚举）
- [x] 6.1.6 `combat/scripts/hit_behavior.gd` — HitBehavior 扩充

### 6.2 SkillData ✅

- [x] 6.2.1 `resources/skill/skill_data_v2.gd` — DNFSkillData（animation_name 引用 SpriteFrames 动画名）
- [x] 6.2.2 `resources/skill/skill_ui_data.gd` — DNFSkillUIData
- [x] 6.2.3 `resources/skill/input_condition.gd` — DNFInputCondition

### 6.3 运行时 ✅

- [x] 6.3.1 `runtime/frame/animated_sprite.gd` — DNFAnimatedSprite2D（继承 AnimatedSprite2D + tick() 回滚驱动）
- [x] 6.3.2 `runtime/frame/animation_preview.gd` — DNFAnimationPreview
- [x] 6.3.3 `runtime/combat/hitbox_component.gd` — DNFHitboxComponent
- [x] 6.3.4 `runtime/combat/hurtbox_component.gd` — DNFHurtboxComponent
- [x] 6.3.5 `runtime/skill/skill_component_v2.gd` — DNFSkillComponent

### 6.4 CharacterData ✅

- [x] 6.4.1 `resources/character/character_data.gd` — DNFCharacterData（sprite_frames: SpriteFrames）
- [x] 6.4.2 `resources/character/character_stats.gd` — DNFCharacterStats（28 项属性）

### 6.5 集成 + 清理 ✅

- [x] 6.5.1 创建 runtime/ resources/ 目录结构
- [x] 6.5.2 更新 plugin.gd（注册 DNFAnimatedSprite2D 等自定义类型）
- [x] 6.5.3 更新测试 — 169/169 通过
- [x] 6.5.4 CONFIGURATOR_GUIDE.md 配置器使用指南
- [x] 6.5.5 已移除弃用模块：
  - ❌ DNFFramePlayer → 用 DNFAnimatedSprite2D 替代
  - ❌ DNFSpriteFrames / DNFAnimationData / DNFFrameData → 用原生 SpriteFrames 替代
  - ❌ DNF 动画编辑器（animation_editor.gd） → 使用 Godot 原生 SpriteFrames Inspector
  - ❌ animation_inspector.gd → 不再需要

---

## Phase 7: 属性系统 + 伤害公式

- [x] 7.1 `resources/character/character_stats.gd`（已在 Phase 6.4 完成）
- [ ] 7.2 `resources/stats/stat_modifier.gd` — 属性修正器
- [ ] 7.3 `resources/stats/element_system.gd` — 属性克制
- [ ] 7.4 `runtime/combat/damage_calculator.gd` — 伤害公式
- [ ] 7.5 `runtime/stats/stats_component.gd` — 属性计算组件
- [ ] 7.6 重构 DNFCharacter 集成 CharacterStats
- [ ] 7.7 重构 CombatManager 使用 DamageCalculator
- [ ] 7.8 扩充 DNFStates
- [ ] 7.9 测试 + 示例

## Phase 8: Buff/Debuff + 状态异常

- [ ] 8.1 `resources/buff/buff_data.gd`
- [ ] 8.2 `resources/buff/buff_effect.gd` + stat/dot/cc 子类
- [ ] 8.3 `runtime/buff/buff_component.gd`
- [ ] 8.4 DNFCharacter 集成 BuffComponent
- [ ] 8.5 测试 + 示例

## Phase 9: 技能深化 + 霸体 + 格挡/抓取

- [ ] 9.1 `runtime/combat/super_armor.gd`
- [ ] 9.2 格挡系统
- [ ] 9.3 抓取系统
- [ ] 9.4 蓄力/持续释放
- [ ] 9.5 被动技能
- [ ] 9.6 测试 + 示例

## Phase 10: 编辑器 — Timeline + Phase Editor + Hitbox Preview ✅

- [x] 10.1 `editor/timeline/timeline_root.gd` — 时间轴主面板
- [x] 10.2 `editor/timeline/frame_ruler.gd` — 帧刻度尺
- [x] 10.3 `editor/timeline/phase_track.gd` — 攻击区间轨道 ★
- [x] 10.4 `editor/timeline/event_track.gd` — 事件轨道
- [x] 10.5 `editor/timeline/movement_track.gd` — 位移区间轨道
- [x] 10.6 `editor/timeline/armor_track.gd` — 霸体/无敌轨道
- [x] 10.7 `editor/preview/hitbox_preview.gd` — Hitbox 叠加预览
- [x] 10.8 `editor/preview/sprite_preview.gd` — 帧 Sprite 预览
- [x] 10.9 `editor/inspectors/dnf_inspector_plugin.gd` — Inspector 增强
- [x] 10.10 注册 Bottom Panel
- [x] 10.11 Hitbox 模板系统（6 种预设）

## Phase 11: 编辑器 — Skill + Character Editor ✅

- [x] 11.1 `editor/panels/skill_editor.gd` — 技能编辑器面板
- [x] 11.2 `editor/panels/character_editor.gd` — 角色编辑器面板
- [x] 11.3 `editor/panels/effect_editor.gd` — 效果事件编辑器
- [x] 11.4 模板系统 (hitbox_templates.gd 6 种预设)

## Phase 11.5: 编辑器增强 + EffectLayer ✅

### 编辑器增强
- [x] 11.5.1 技能删除 — ConfirmationDialog 确认弹窗防误删
- [x] 11.5.2 双击技能名重命名 — item_activated → AcceptDialog + LineEdit
- [x] 11.5.3 动画绑定 — PopupMenu 下拉选择 SpriteFrames 动画名，自动同步 total_frames + 预览
- [x] 11.5.4 加载角色时自动将 sprite_frames 传递给 sprite_preview

### EffectLayer 特效层系统
- [x] 11.5.5 `resources/skill/effect_layer.gd` — DNFEffectLayer（表现+轻量碰撞）
  - layer_name / animation_name / spawn_frame / offset / follow_character
  - movement: Array（飞行位移）
  - hitbox / hit_behavior / hitbox_start_frame / hitbox_end_frame（可选碰撞）
  - 无 phases / 无 events — 复杂逻辑由 SkillData.events 统一调度
- [x] 11.5.6 `skill_data_v2.gd` 新增 `effect_layers: Array` + `get_effect_layers_at_frame()`
- [x] 11.5.7 skill_editor.gd 右侧 Inspector 新增特效层管理 UI
  - 特效层列表 + 添加/删除
  - 选中后编辑：层名、动画绑定、spawn_frame、offset、跟随/朝向、碰撞、位移
- [x] 11.5.8 sprite_preview.gd 多层叠加渲染（主动画 + 特效层半透明叠加）

## Phase 12: 敌人 AI + 集成示例

- [ ] 12.1 `resources/enemy/enemy_config.gd`
- [ ] 12.2 `resources/enemy/ai_behavior.gd`
- [ ] 12.3 `runtime/enemy/enemy_character.gd`
- [ ] 12.4 `runtime/enemy/ai_component.gd`
- [ ] 12.5 完整角色示例
- [ ] 12.6 完整敌人示例
- [ ] 12.7 README.md + 配置器教程
