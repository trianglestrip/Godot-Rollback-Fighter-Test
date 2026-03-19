# DNF Framework — 完整开发计划

## 一、目标

将 dnf_framework 打造为**完整的 DNF（地下城与勇士）风格格斗游戏框架**，包含：
- 完整的运行时系统（战斗/技能/状态/AI/Buff 等）
- 编辑器可视化配置器（Inspector 增强 + 帧数据编辑面板）
- 数据驱动 Resource 架构（.tres 文件即配置）

---

## 二、当前框架覆盖情况 vs DNF 完整系统差距

### 2.1 已实现 ✅

| 模块 | 内容 |
|------|------|
| 帧动画 | FrameAnimationPlayer（帧事件/save-load） |
| 帧物理 | FrameCharacterBody2D（帧确定性位移/重力） |
| 输入缓冲 | InputBuffer（缓冲/过期/combo/指令输入） |
| 状态机 | DNFStates 17 个状态枚举 + DNFCharacter 状态切换 |
| 战斗 | Hitbox/Hurtbox/CombatManager/HitBehavior |
| 招式 | DNFMove + 输入条件 + 取消系统 |
| 技能 | DNFSkillComponent + SkillData + 帧事件 |

### 2.2 缺失系统 ❌（按优先级排序）

#### P0 — 核心战斗缺失（必须有）

| 缺失 | 说明 |
|------|------|
| **属性系统** | HP/MP/STR/INT/VIT/SPR/物攻/魔攻/独立攻击/物防/魔防/攻速/施法速度/移速/暴击率/暴击伤害/命中/回避 |
| **MP 系统** | 技能消耗 MP，MP 回复，最大 MP |
| **伤害公式** | 百分比伤害 / 固伤公式 / 防御减伤 / 属性克制 / 暴击计算 |
| **属性伤害** | 火/冰/光/暗 4 属性 + 属性强化/属性抗性 |
| **霸体系统** | 无霸体/半霸体/可破霸体/完全霸体/无敌帧 |
| **技能消耗** | MP 消耗 / HP 消耗 / 特殊量表消耗 |
| **技能等级** | 等级/SP 消耗/等级缩放/学习等级 |
| **攻击类型** | 物理百分比 / 魔法百分比 / 独立攻击（固伤） |

#### P1 — 状态/战斗扩展

| 缺失 | 说明 |
|------|------|
| **Buff/Debuff 系统** | 持续时间/叠加规则/属性修正/图标显示 |
| **状态异常** | 灼烧/冰冻/感电/中毒/出血/石化/眩晕/睡眠/混乱/束缚/减速/诅咒/破甲 |
| **状态异常耐性** | 每种异常有独立耐性值 |
| **格挡/防御** | Block 状态逻辑 + Guard Break |
| **抓取/投技** | Grab + Being Grabbed 状态 + 解除机制 |
| **死亡/复活** | DEAD 状态 + 复活币 + 无敌帧 |
| **蓄力技能** | CHARGING 状态 + 蓄力等级 |
| **持续释放** | CHANNELING 状态 |
| **连击保护** | PvP 红/蓝/黄标记 + 浮空重力递增 |

#### P2 — 技能系统扩展

| 缺失 | 说明 |
|------|------|
| **被动技能** | 永久属性修正 + 条件触发效果 |
| **Buff 技能** | 自身增益 / 队友增益 / 光环 |
| **觉醒技能** | 1/2/3 觉醒 + 觉醒条件 |
| **冷却减少** | 冷却减少% + 冷却恢复速度 (上限 70%) |
| **多段打击** | 单技能多次 hit + 每段独立 HitBehavior |
| **弹道/投射物** | 远程技能 + 弹道系统 |
| **技能树/前置** | 技能前置条件 + SP 分配 |
| **技能进化** | VP 分配 + 两选一强化方向 |

#### P3 — 敌人/AI 系统

| 缺失 | 说明 |
|------|------|
| **敌人类型** | 普通/精英/Boss/Raid Boss |
| **敌人 AI** | 巡逻/追击/攻击模式/Boss 阶段转换 |
| **仇恨系统** | 目标选择 |
| **敌人霸体** | 霸体等级 + 霸体血条 |
| **敌人属性抗性** | 各属性独立抗性 |
| **出生/死亡** | 出生动画 + 死亡动画 + 掉落物 |

#### P4 — UI / 辅助系统

| 缺失 | 说明 |
|------|------|
| **技能快捷栏** | 技能槽位 + 快捷键绑定 + 冷却覆盖 |
| **HP/MP 条** | 血条/蓝条 UI 数据 |
| **Buff 图标栏** | 增益/减益图标 + 剩余时间 |
| **伤害数字** | 浮动伤害数字 + 暴击标记 |
| **连击计数器** | Combo Hit 显示 |
| **技能提示** | 技能名/描述/消耗/伤害/冷却 |

#### P5 — 进阶系统（可后续扩展）

| 缺失 | 说明 |
|------|------|
| **等级/经验** | 角色升级 + 经验获取 |
| **职业系统** | 职业 + 转职 |
| **装备系统** | 武器/防具/属性加成 |
| **物品/掉落** | 掉落表 + 品质 |
| **副本/房间** | 房间制地图结构 |
| **音效/特效** | SFX + 打击特效 |
| **摄像机** | 战斗摄像机控制 |

---

## 三、重构后目标架构

```
dnf_framework/
├── core/                              # 核心基础
│   ├── frame_animation_player.gd      # 帧动画
│   ├── input_buffer.gd                # 输入缓冲
│   └── frame_character_body2d.gd      # 帧物理体
│
├── stats/                             # [新] 属性系统
│   ├── character_stats.gd             # 角色属性 Resource
│   ├── stat_modifier.gd               # 属性修正器
│   ├── damage_calculator.gd           # 伤害公式计算器
│   └── element_system.gd              # 属性克制系统
│
├── character/                         # 角色系统
│   ├── dnf_character.gd               # 角色基类（重构）
│   ├── dnf_states.gd                  # 状态枚举（扩充）
│   └── character_config.gd            # [新] 角色配置 Resource
│
├── combat/                            # 战斗系统
│   ├── dnf_hitbox.gd
│   ├── dnf_hurtbox.gd
│   ├── hit_behavior.gd               # (扩充: 属性/多段打击)
│   ├── combat_manager.gd             # (扩充: 伤害公式)
│   ├── hitbox_data.gd                # [新] 碰撞体配置
│   ├── super_armor.gd                # [新] 霸体系统
│   └── grab_system.gd               # [新] 抓取系统
│
├── skill/                             # 技能系统（合并 move + skill）
│   ├── skill_data.gd                  # (扩充: MP消耗/等级/属性/霸体)
│   ├── skill_frame_data.gd           # [新] 帧数据配置
│   ├── skill_component.gd
│   ├── skill_event.gd
│   ├── skill_effect_event.gd
│   ├── skill_hitbox_event.gd
│   ├── skill_movement_event.gd
│   ├── skill_sound_event.gd          # [新] 音效事件
│   ├── skill_spawn_event.gd          # [新] 投射物/召唤物事件
│   ├── skill_super_armor_event.gd    # [新] 霸体事件
│   ├── skill_ui_data.gd             # [新] 技能 UI
│   ├── passive_skill.gd             # [新] 被动技能
│   └── input_condition.gd           # 输入条件
│
├── buff/                             # [新] Buff/Debuff 系统
│   ├── buff_data.gd                  # Buff 定义 Resource
│   ├── buff_component.gd            # Buff 管理组件
│   ├── buff_effect.gd               # Buff 效果基类
│   ├── stat_buff_effect.gd          # 属性修正效果
│   ├── dot_buff_effect.gd           # 持续伤害效果
│   └── status_effect.gd             # 状态异常
│
├── enemy/                            # [新] 敌人系统
│   ├── enemy_config.gd              # 敌人配置 Resource
│   ├── enemy_character.gd           # 敌人基类
│   ├── ai_behavior.gd              # AI 行为 Resource
│   ├── ai_component.gd             # AI 执行组件
│   └── spawn_config.gd             # 出生配置
│
├── state/                            # 状态机
│   ├── state_machine.gd
│   ├── fighter_state.gd
│   ├── state_event.gd
│   └── state_transition_event.gd
│
├── ui/                               # [新] UI 数据层
│   ├── skill_slot_data.gd           # 技能栏槽位
│   ├── hud_data.gd                  # HUD 配置
│   └── damage_number_data.gd       # 伤害数字配置
│
├── editor/                           # [新] 编辑器扩展
│   ├── dnf_inspector_plugin.gd      # Inspector 增强
│   ├── skill_editor_panel.gd        # 技能帧编辑器
│   ├── character_config_editor.gd   # 角色配置编辑器
│   ├── frame_timeline.gd           # 帧时间轴控件
│   └── hitbox_preview.gd           # 碰撞体预览
│
├── examples/
├── tests/
├── plugin.gd
└── plugin.cfg
```

---

## 四、分阶段开发路线

### Phase 6: 属性系统 + 伤害公式（P0 核心）

建立完整的 RPG 属性层，让战斗不再只是"扣 HP"。

1. `CharacterStats` Resource — 全属性定义
   - HP/MP（当前值 + 最大值）
   - STR/INT/VIT/SPR 四维属性
   - 物攻/魔攻/独立攻击
   - 物防/魔防
   - 攻速/施法速度/移速（含上限）
   - 物理暴击/魔法暴击/暴击伤害
   - 命中率/回避率
   - 火/冰/光/暗属性强化
   - 火/冰/光/暗属性抗性
   - HP/MP 回复速率

2. `StatModifier` — 属性修正器
   - 类型：加法(flat)/百分比(percent)/最终乘算(multiply)
   - 来源标记（装备/buff/被动/临时）
   - 优先级/堆叠规则

3. `DamageCalculator` — 伤害公式
   - 百分比物理伤害 = 技能倍率 × 物攻 × (1 + STR/250) × (1 - 物防减伤%)
   - 百分比魔法伤害 = 技能倍率 × 魔攻 × (1 + INT/250) × (1 - 魔防减伤%)
   - 独立攻击伤害 = 技能固伤 × (1 + STR或INT/250) × (1 - 防御减伤%)
   - 属性伤害加成 = 基础伤害 × [1 + (属性强化 - 敌方属性抗性) / 220]
   - 暴击判定 + 暴击倍率
   - 背击加成

4. `ElementSystem` — 属性克制
   - 4 属性枚举 (FIRE/ICE/LIGHT/DARK/NEUTRAL)
   - 攻击属性类型 (物理百分比/魔法百分比/独立攻击)
   - 物理攻击类型 (打击/斩击/射击/爆炸)

5. 重构 `DNFCharacter` — 集成 CharacterStats
6. 重构 `HitBehavior` — 加入属性/攻击类型/倍率
7. 重构 `CombatManager` — 使用 DamageCalculator

### Phase 7: Buff/Debuff + 状态异常（P1）

1. `BuffData` Resource — Buff 定义
   - buff 名称/图标/描述
   - 持续时间（帧数）
   - 最大叠加层数
   - 效果列表 Array[BuffEffect]
   - 刷新规则 (重置时间/延长时间/叠加层数)

2. `BuffEffect` 基类 + 子类
   - `StatBuffEffect` — 修正属性 (加攻击/加防御/加速度)
   - `DotBuffEffect` — 持续伤害 (灼烧/中毒/出血/感电)
   - `CrowdControlEffect` — 控制 (眩晕/冰冻/石化/睡眠/束缚/减速/混乱)
   - `ShieldEffect` — 护盾
   - `SuperArmorEffect` — 霸体增益

3. `BuffComponent` — Buff 管理器（Node 组件）
   - 添加/移除 Buff
   - 每帧 tick 处理
   - 属性修正计算
   - 状态异常判定（耐性检查）
   - save/load state

4. `StatusEffect` — 状态异常数据
   - 异常类型枚举
   - 触发概率
   - 耐性衰减
   - 效果参数（伤害/减速比例等）

5. 扩充 DNFStates — 增加 STUNNED/FROZEN/PETRIFIED 等状态

### Phase 8: 技能系统深化 + 霸体（P0+P1）

1. 扩充 `SkillData`
   - mp_cost / hp_cost / special_cost
   - skill_level + max_level + sp_cost
   - damage_type (PHYSICAL_PERCENT/MAGICAL_PERCENT/INDEPENDENT)
   - element (FIRE/ICE/LIGHT/DARK/NEUTRAL)
   - skill_coefficient (技能倍率，按等级缩放)
   - super_armor_level (技能释放时霸体等级)
   - invincible_frames (无敌帧范围)
   - hit_count (多段打击次数)
   - is_passive / is_buff / is_awakening
   - prerequisites (前置技能)

2. `SuperArmor` 系统
   - 霸体等级枚举 (NONE/HALF/BREAKABLE/FULL)
   - 霸体血量（可破霸体用）
   - `SkillSuperArmorEvent` — 技能帧事件

3. `SkillSoundEvent` — 音效帧事件
4. `SkillSpawnEvent` — 投射物/召唤物帧事件
5. `PassiveSkill` — 被动技能 Resource
6. 格挡/抓取状态实现

### Phase 9: 敌人 AI 系统（P3）

1. `EnemyConfig` Resource — 敌人配置
   - 敌人类型 (NORMAL/ELITE/BOSS/RAID)
   - 属性 (CharacterStats)
   - 技能列表
   - 霸体配置
   - 属性抗性
   - 异常耐性

2. `AIBehavior` Resource — AI 行为定义
   - 行为类型（巡逻/追击/攻击/躲避/空闲）
   - 触发条件（距离/HP 阈值/状态）
   - 攻击模式（随机/序列/条件）
   - Boss 阶段配置

3. `AIComponent` — AI 执行组件
4. `EnemyCharacter` — 敌人角色基类

### Phase 10: Resource 数据层 + 编辑器配置器

1. `CharacterConfig` Resource — 完整角色配置
   - 角色名称 + 显示名称
   - 属性模板 (CharacterStats)
   - 状态-动画映射 (Dictionary)
   - 技能列表 (Array[SkillData])
   - 招式列表 (Array[DNFMove])

2. `SkillFrameData` Resource — 帧数据
   - 每帧碰撞体 / 特效 / 霸体 / 无敌帧
   - 可视化编辑

3. `SkillUIData` Resource — 技能 UI
   - 图标 / 显示名 / 描述 / 快捷键

4. Editor Inspector 增强
5. 技能帧编辑器 Bottom Panel
6. 角色配置编辑器 Dock

### Phase 11: 集成示例 + 文档 + 模板

1. 配置器创建完整角色
2. 配置器创建敌人
3. Buff/状态异常演示
4. 伤害公式演示
5. 模板系统（近战/远程/Boss）
6. README + API 文档

---

## 五、关键设计原则

1. **数据驱动** — 所有配置 = Resource (.tres)，零硬编码
2. **Editor-first** — 编辑器体验优先，减少写代码
3. **向后兼容** — 现有代码仍然可用
4. **Rollback-friendly** — 全部 save/load_state
5. **模块化** — 可以只用一部分模块
6. **DNF 还原度** — 伤害公式/属性系统/霸体系统尽量还原
