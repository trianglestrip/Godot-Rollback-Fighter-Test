# DNF Framework — 完整开发计划

## 一、插件重定义

不是"动画工具"，不是"零散模块集合"，而是：

**DNF 式技能驱动引擎 + 可视化编辑器（Godot 插件）**

核心理念：
- **帧是最小逻辑单位** — 每一帧绑定自己的碰撞体/特效/位移/音效
- **数据驱动** — 技能 = 数据（Resource），不是代码
- **编辑器即生产力** — Resource 保存 → 游戏直接读取，零导出流程

## 二、当前架构问题分析

### 现有架构的核心缺陷

| 问题 | 当前做法 | 正确做法 |
|------|---------|---------|
| **帧 ≠ 最小单位** | SkillEvent 用 `frame_range` 区间触发 | 每帧独立 FrameData，帧上挂 hitbox/event/movement |
| **动画与数据分离** | FrameAnimationPlayer 依赖 SpriteFrames（Godot 内置） | AnimationData Resource 自带帧列表，每帧含 region + 时长 + 逻辑 |
| **Hitbox 绑在场景** | hitbox 是场景中的 Area2D 节点，SkillHitboxEvent 用 NodePath 引用 | hitbox 数据化（HitboxData Resource），由 HitboxComponent 运行时管理 |
| **Skill 和 Move 分裂** | SkillData + DNFMove 两套系统 | 统一为 SkillData，一个 Resource 描述一切 |
| **分层不清** | 所有脚本平铺在各目录 | runtime（游戏用）/ resources（数据定义）/ editor（编辑器）三层分离 |

### 需要保留的部分

| 模块 | 状态 | 决策 |
|------|------|------|
| InputBuffer | 完善 | 保留，移到 runtime/input/ |
| FrameCharacterBody2D | 完善 | 保留为帧物理基础，移到 runtime/character/ |
| DNFStates 状态枚举 | 可用 | 保留扩充 |
| DNFCharacter 基类 | 可用 | 保留重构 |
| CombatManager | 可用 | 保留重构（接入 DamageCalculator） |
| DNFHitBehavior | 可用 | 保留扩充 |
| 152 个测试 | 完善 | 保留适配 |

### 需要重写的部分

| 模块 | 原因 |
|------|------|
| FrameAnimationPlayer | 改为 FramePlayer，读 AnimationData 而不是 SpriteFrames |
| SkillData | 重写为「帧级数据」架构，含 FrameData 数组 |
| SkillEvent 系列 | 替换为 FrameEvent（挂在帧上而不是用区间匹配） |
| SkillHitboxEvent | 替换为 HitboxData（数据化碰撞体） |
| DNFMove | 合并入 SkillData |
| plugin.gd | 重写（加入编辑器面板注册） |

---

## 三、目标架构（三层分离）

```
addons/dnf_framework/
│
├── runtime/                          # 运行时（游戏真正用的）
│   ├── frame/
│   │   ├── frame_player.gd           # 帧播放器（替代 FrameAnimationPlayer）
│   │   └── frame_driver.gd           # 帧驱动器（统一 tick 管理）
│   ├── character/
│   │   ├── dnf_character.gd          # 角色基类（重构）
│   │   ├── dnf_states.gd             # 状态枚举（扩充）
│   │   └── frame_character_body2d.gd # 帧物理体（保留）
│   ├── input/
│   │   └── input_buffer.gd           # 输入缓冲（保留）
│   ├── combat/
│   │   ├── hitbox_component.gd       # 碰撞体管理组件（运行时创建/销毁 hitbox）
│   │   ├── hurtbox_component.gd      # 受击组件
│   │   ├── combat_manager.gd         # 战斗管理器（重构）
│   │   ├── damage_calculator.gd      # 伤害公式
│   │   └── super_armor.gd            # 霸体系统
│   ├── skill/
│   │   ├── skill_component.gd        # 技能执行组件（重写）
│   │   └── passive_manager.gd        # 被动技能管理
│   ├── buff/
│   │   ├── buff_component.gd         # Buff 管理组件
│   │   └── buff_processor.gd         # Buff tick 处理
│   ├── stats/
│   │   └── stats_component.gd        # 属性计算组件
│   └── enemy/
│       ├── enemy_character.gd        # 敌人角色基类
│       └── ai_component.gd           # AI 执行组件
│
├── resources/                        # 数据定义（核心，全 Resource）
│   ├── character/
│   │   ├── character_data.gd         # 角色配置总入口
│   │   └── character_stats.gd        # 角色属性
│   ├── animation/
│   │   ├── animation_data.gd         # 帧动画数据（帧序列 + fps）
│   │   └── frame_data.gd            # 单帧数据（核心中的核心）
│   ├── skill/
│   │   ├── skill_data.gd             # 技能定义（含 AnimationData 引用）
│   │   ├── skill_ui_data.gd          # 技能 UI 配置
│   │   └── input_condition.gd        # 输入条件
│   ├── combat/
│   │   ├── hitbox_data.gd            # 碰撞体数据
│   │   └── hit_behavior.gd           # 受击行为
│   ├── frame_event/
│   │   └── frame_event.gd            # 帧事件（统一枚举型）
│   ├── buff/
│   │   ├── buff_data.gd              # Buff 定义
│   │   ├── buff_effect.gd            # Buff 效果基类
│   │   ├── stat_buff_effect.gd       # 属性修正
│   │   ├── dot_buff_effect.gd        # 持续伤害
│   │   └── crowd_control_effect.gd   # 控制效果
│   ├── stats/
│   │   ├── stat_modifier.gd          # 属性修正器
│   │   └── element_system.gd         # 属性克制
│   └── enemy/
│       ├── enemy_config.gd           # 敌人配置
│       └── ai_behavior.gd            # AI 行为定义
│
├── editor/                           # 编辑器插件（@tool）
│   ├── panels/
│   │   ├── character_editor.gd       # 角色编辑器面板
│   │   ├── skill_editor.gd           # 技能编辑器面板
│   │   └── effect_editor.gd          # 特效编辑器面板
│   ├── timeline/
│   │   └── frame_timeline.gd         # 帧时间轴控件
│   ├── inspectors/
│   │   └── dnf_inspector_plugin.gd   # Inspector 增强
│   └── preview/
│       ├── hitbox_preview.gd         # 碰撞体预览（在 Sprite 上画框）
│       └── sprite_preview.gd         # Sprite 帧预览
│
├── examples/                         # 示例
├── tests/                            # 测试
├── plugin.gd                         # 插件入口
└── plugin.cfg
```

---

## 四、核心数据结构（最关键的设计）

### 帧级数据架构的核心思想

```
CharacterData
  ├── animations: Dictionary { "idle" → AnimationData, "attack_1" → AnimationData, ... }
  ├── skills: Array[SkillData]
  └── stats: CharacterStats

AnimationData
  ├── fps: int = 12
  └── frames: Array[FrameData]       ← 逐帧定义

FrameData（最小逻辑单位）
  ├── region: Rect2                   ← Atlas 中的切片区域
  ├── duration: int = 1               ← 持续帧数（通常 1）
  ├── hitboxes: Array[HitboxData]     ← 该帧激活的碰撞体
  ├── events: Array[FrameEvent]       ← 该帧触发的事件
  └── movement: Vector2               ← 该帧的位移

SkillData
  ├── name / display_name
  ├── animation: AnimationData        ← 直接引用帧动画（而不是 anim_name 字符串）
  ├── mp_cost / hp_cost / cooldown
  ├── skill_level / skill_coefficient
  ├── element / damage_type
  ├── super_armor_level
  ├── cancel_window / cancel_into
  ├── ui: SkillUIData
  └── input_conditions: Array[InputCondition]
```

### vs 当前架构对比

| 维度 | 当前（区间事件驱动） | 目标（帧级数据驱动） |
|------|---------------------|---------------------|
| Hitbox | SkillHitboxEvent(frame_range=[5,10]) → 激活场景中的 Area2D | FrameData.hitboxes → 运行时 HitboxComponent 创建 |
| 特效 | SkillEffectEvent(frame_range=[3,3], CAMERA_SHAKE) | FrameData.events → [{type: CAMERA_SHAKE, data: {intensity: 2}}] |
| 位移 | SkillMovementEvent(frame_range=[2,8], impulse) | FrameData.movement = Vector2(5, 0) |
| 编辑 | 代码中配置 Event 数组 | 编辑器时间轴上点击帧 → 添加/编辑 |

**关键区别**: 当前是"事件在区间内持续匹配"，目标是"每帧自带完整数据"。后者更适合可视化编辑，也更接近格斗游戏的真实帧数据表。

---

## 五、运行时系统设计

### 5.1 FramePlayer（替代 FrameAnimationPlayer）

```gdscript
class_name FramePlayer extends Node

var anim: AnimationData
var frame_index: int = 0
var frame_timer: int = 0

func play(a: AnimationData):
    anim = a
    frame_index = 0
    frame_timer = 0

func tick():
    if anim == null: return
    frame_timer += 1
    var f = anim.frames[frame_index]
    if frame_timer >= f.duration:
        frame_timer = 0
        frame_index += 1
        if frame_index >= anim.frames.size():
            finished.emit()
            return
    apply_frame(anim.frames[frame_index])

func apply_frame(f: FrameData):
    sprite.region_rect = f.region
    hitbox_component.set_hitboxes(f.hitboxes)
    character.velocity += f.movement
    for e in f.events:
        event_system.execute(e)
```

**核心**: `apply_frame()` 每帧调用，精确执行该帧的所有数据。

### 5.2 HitboxComponent（运行时碰撞体管理）

不再用场景中固定的 Area2D + NodePath 引用：

```gdscript
class_name HitboxComponent extends Node

func set_hitboxes(hitbox_list: Array[HitboxData]):
    clear_all()
    for hb in hitbox_list:
        create_runtime_hitbox(hb)  # 动态创建/更新碰撞体
```

### 5.3 SkillComponent（重写）

```gdscript
func play_skill(skill: SkillData):
    if not can_use(skill): return
    deduct_cost(skill)           # 扣 MP/HP
    start_cooldown(skill)
    frame_player.play(skill.animation)
    apply_super_armor(skill)
```

---

## 六、编辑器系统设计

### 6.1 核心编辑器模块

| 模块 | 功能 | 优先级 |
|------|------|--------|
| **Animation Editor** | Atlas 切帧 / 调 fps / 帧排序 / 帧复制删除 | P0 |
| **Hitbox Editor** | 在 Sprite 上画碰撞体矩形 / 每帧独立设置 | P0 |
| **Timeline** | 帧时间轴 / 点击帧 / 添加 event / 拖拽 duration | P0 |
| **Skill Editor** | 选动画 / 配 MP/冷却 / 绑特效 / 技能图标 | P1 |
| **Character Editor** | 角色列表 / Atlas 绑定 / 技能管理 | P1 |
| **Effect Editor** | 粒子/音效/镜头震动配置 | P2 |

### 6.2 Timeline 示意

```
|----|----|----|----|----|----|
  f1   f2   f3   f4   f5   f6
  ▪         ▪▪▪▪▪▪▪         ← hitbox active
       ★                    ← 特效触发
            ━━━━━━━━━       ← 霸体区间
  →→   →→   →→→  →          ← 位移
```

点击任意帧 → 右侧显示该帧的 FrameData：
- region（Sprite 区域）
- hitboxes（碰撞体列表）
- events（事件列表）
- movement（位移）

### 6.3 编辑器与运行时通信

```
编辑器修改 → Resource 保存(.tres) → 游戏直接读取
```

不需要导出/编译流程。

---

## 七、属性系统 + 伤害公式

### 7.1 CharacterStats

```
HP / MP（当前 + 最大）
STR / INT / VIT / SPR 四维
物攻 / 魔攻 / 独立攻击
物防 / 魔防（上限 75%）
攻速 / 施法速度 / 移速（各有上限）
物理暴击 / 魔法暴击 / 暴击伤害
命中 / 回避（上限 75%）
火/冰/光/暗 属性强化
火/冰/光/暗 属性抗性（上限 100）
HP/MP 回复速率
```

### 7.2 伤害公式

```
百分比物理 = 技能倍率 × 物攻 × (1 + STR/250) × (1 - 物防减伤%) × 属性加成
百分比魔法 = 技能倍率 × 魔攻 × (1 + INT/250) × (1 - 魔防减伤%) × 属性加成
独立攻击   = 技能固伤 × (1 + STR或INT/250) × (1 - 防御减伤%) × 属性加成
属性加成   = 1 + (属性强化 - 敌方属性抗性) / 220
暴击       = 基础伤害 × (1 + 暴击伤害%)
```

---

## 八、Buff/Debuff + 状态异常

### Buff 类型
- **StatBuff** — 属性修正（+攻击/+防御/+速度）
- **DotBuff** — 持续伤害（灼烧/中毒/出血/感电）
- **CrowdControl** — 控制（眩晕/冰冻/石化/睡眠/束缚/减速/混乱/致盲）
- **ShieldBuff** — 护盾
- **SuperArmorBuff** — 霸体增益

### 叠加规则
- 相同 Buff: RESET_TIMER / EXTEND_TIMER / ADD_STACK
- 异常耐性: 每种异常独立耐性值，影响触发概率和持续时间

---

## 九、分阶段开发路线

### Phase 6: 帧级数据架构 + FramePlayer（最高优先）

重写核心数据模型，建立"帧是最小单位"的架构。

1. `resources/animation/frame_data.gd` — FrameData Resource
2. `resources/animation/animation_data.gd` — AnimationData Resource
3. `resources/combat/hitbox_data.gd` — HitboxData Resource
4. `resources/frame_event/frame_event.gd` — FrameEvent Resource
5. `runtime/frame/frame_player.gd` — FramePlayer（替代 FrameAnimationPlayer）
6. `runtime/combat/hitbox_component.gd` — HitboxComponent
7. 重写 SkillData 引用 AnimationData
8. 重写 SkillComponent 使用 FramePlayer
9. 测试 + 示例

### Phase 7: 属性系统 + 伤害公式

1. CharacterStats Resource
2. StatModifier
3. DamageCalculator
4. ElementSystem
5. 重构 DNFCharacter 集成
6. 重构 CombatManager

### Phase 8: Buff/Debuff + 状态异常

1. BuffData + BuffEffect 层级
2. BuffComponent
3. 状态异常系统
4. DNFCharacter 集成

### Phase 9: 技能系统深化 + 霸体

1. SkillData 扩充 (MP/等级/属性/霸体)
2. SuperArmor 系统
3. 格挡/抓取
4. 被动技能

### Phase 10: 编辑器 — Animation Editor + Timeline + Hitbox Editor

1. Animation Editor 面板（Atlas 切帧/帧排序）
2. Timeline 控件（帧时间轴/事件标记）
3. Hitbox Editor（Sprite 上画碰撞体）
4. Inspector 增强

### Phase 11: 编辑器 — Skill Editor + Character Editor

1. Skill Editor 面板
2. Character Editor 面板
3. Effect Editor
4. 模板系统

### Phase 12: 敌人 AI + 集成示例

1. EnemyConfig + AIBehavior
2. AIComponent
3. 完整示例 + 文档

---

## 十、关键设计原则（必须遵守）

### 1. 数据驱动
```
技能 = 数据（Resource）
不是代码
```

### 2. 帧是最小单位
```
逻辑绑定在帧上
不是事件区间匹配
```

### 3. 解耦
```
FramePlayer ≠ Skill
Skill ≠ Hitbox
Hitbox ≠ 场景节点
```

### 4. 三层分离
```
runtime/   — 游戏运行时代码
resources/ — 纯数据 Resource
editor/    — @tool 编辑器代码
```

### 5. 向后兼容
```
现有 FrameCharacterBody2D / InputBuffer / DNFStates 保留
新系统渐进替换旧系统
旧 examples + tests 适配后继续工作
```

### 6. Rollback-friendly
```
所有运行时组件实现 _save_state / _load_state
```

---

## 十一、你会踩的坑（提前规避）

| 坑 | 后果 | 正确做法 |
|----|------|---------|
| 用 AnimationPlayer | 无法帧精确控制，无法数据化 | 用 FramePlayer + AnimationData |
| Hitbox 写死在场景 | 无法按帧切换碰撞体 | HitboxData Resource + HitboxComponent 运行时管理 |
| 不做 Resource | 无法编辑器化 | 一切配置 = Resource |
| Skill 和 Move 分两套 | 概念混乱，维护困难 | 统一为 SkillData |
| 事件用区间匹配 | 无法精确到单帧，编辑器展示困难 | 每帧的 FrameData 自带事件列表 |

---

## 十二、扩展能力

```
✔ Roguelike 增强
  skill.damage_coefficient *= 1.5

✔ 技能变异
  frame_data.hitboxes.append(extra_hitbox)

✔ 多职业
  切换 CharacterData

✔ 在线对战
  FramePlayer 帧确定性 + save/load_state
```
