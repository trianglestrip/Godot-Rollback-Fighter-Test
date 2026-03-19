# DNF Framework — Task 清单

## Phase 1-5: 基础框架 ✅ 全部完成

- [x] InputBuffer（帧输入缓冲 + 连招检测 + 方向历史）
- [x] FrameAnimationPlayer（帧计数驱动动画播放 + 事件系统）
- [x] FrameCharacterBody2D（帧驱动物理角色 + save/load）
- [x] DNFStates + DNFCharacter（状态机 + 受击 + 取消系统）
- [x] DNFHitbox / DNFHurtbox / DNFHitBehavior / DNFCombatManager
- [x] DNFMove + DNFInputType + DNFInputEqualCheck + DNFCommandMotionInput
- [x] 5 个示例场景 + 152 项自动化测试

---

## Phase 6: 核心数据层 + FramePlayer + Phase 系统 ⭐

### 6.1 Resource 数据层 ✅

- [x] 6.1.1 `resources/animation/frame_data.gd` — DNFFrameData
- [x] 6.1.2 `resources/animation/animation_data.gd` — DNFAnimationData
- [x] 6.1.3 `resources/skill/attack_phase.gd` — DNFAttackPhase ★
- [x] 6.1.4 `resources/skill/movement_phase.gd` — DNFMovementPhase
- [x] 6.1.5 `resources/skill/frame_event.gd` — DNFFrameEvent（12 种事件类型）
- [x] 6.1.6 `resources/combat/hitbox_data.gd` — DNFHitboxData（含 HitLevel 枚举）
- [ ] 6.1.7 `combat/scripts/hit_behavior.gd` — HitBehavior 扩充
  - 待加: damage_type / element / skill_coefficient / fixed_damage

### 6.2 SkillDataV2 ✅

- [x] 6.2.1 `resources/skill/skill_data_v2.gd` — DNFSkillDataV2
- [x] 6.2.2 `resources/skill/skill_ui_data.gd` — DNFSkillUIData
- [x] 6.2.3 `resources/skill/input_condition.gd` — DNFInputCondition

### 6.3 运行时 ✅

- [x] 6.3.1 `runtime/frame/frame_player.gd` — DNFFramePlayer
- [x] 6.3.2 `runtime/combat/hitbox_component.gd` — DNFHitboxComponent
- [x] 6.3.3 `runtime/combat/hurtbox_component.gd` — DNFHurtboxComponent
- [x] 6.3.4 `runtime/skill/skill_component_v2.gd` — DNFSkillComponentV2

### 6.4 CharacterData ✅

- [x] 6.4.1 `resources/character/character_data.gd` — DNFCharacterData
- [x] 6.4.2 `resources/character/character_stats.gd` — DNFCharacterStats（28 项属性）

### 6.5 集成 + 测试 ✅（部分）

- [x] 6.5.1 创建 runtime/ resources/ 目录结构
- [ ] 6.5.2 迁移保留模块到 runtime/ 目录
  - InputBuffer → runtime/input/
  - FrameCharacterBody2D → runtime/character/
  - DNFStates + DNFCharacter → runtime/character/
  - CombatManager → runtime/combat/
  - FrameAnimationPlayer → runtime/frame/（或保留）
- [ ] 6.5.3 更新所有 preload/extends 路径
- [x] 6.5.4 更新 plugin.gd 注册（新增 4 个自定义类型）
- [x] 6.5.5 适配测试（Phase6_DataLayer 67 项，总计 219/219 通过）
- [ ] 6.5.6 创建新示例（基于 SkillDataV2 的 .tres 技能配置 + 场景）
- [x] 6.5.7 所有 Resource 添加中文 `##` 文档注释
- [x] 6.5.8 CONFIGURATOR_GUIDE.md 配置器使用指南

---

## Phase 7: 属性系统 + 伤害公式

- [x] 7.1 `resources/character/character_stats.gd`（已在 Phase 6.4 完成）
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
- [ ] 10.2 `editor/timeline/frame_ruler.gd` — 帧刻度尺
- [ ] 10.3 `editor/timeline/phase_track.gd` — 攻击区间轨道 ★
- [ ] 10.4 `editor/timeline/event_track.gd` — 事件轨道
- [ ] 10.5 `editor/timeline/movement_track.gd` — 位移区间轨道
- [ ] 10.6 `editor/timeline/armor_track.gd` — 霸体/无敌轨道
- [ ] 10.7 `editor/preview/hitbox_preview.gd` — Sprite 上画碰撞体
- [ ] 10.8 `editor/preview/sprite_preview.gd` — 帧 Sprite 预览
- [ ] 10.9 `editor/inspectors/dnf_inspector_plugin.gd` — Inspector 增强
- [ ] 10.10 注册 Bottom Panel 到 plugin.gd
- [ ] 10.11 Hitbox 模板系统 (Slash/Thrust/AOE/Projectile 预设)
- [ ] 10.12 批量操作 (选中多帧 → 应用 hitbox)

## Phase 11: 编辑器 — Skill + Character Editor

- [ ] 11.1 `editor/panels/skill_editor.gd`
- [ ] 11.2 `editor/panels/character_editor.gd`
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
