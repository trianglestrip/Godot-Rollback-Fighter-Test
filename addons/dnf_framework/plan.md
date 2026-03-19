# DNF Framework — 完整开发计划

## 一、插件定义

**DNF 式技能驱动引擎 + 可视化编辑器（Godot 插件）**

核心理念：
- **帧驱动 ≠ 逐帧配置，帧驱动 = 时间轴区间控制**
- **数据驱动** — 技能 = 数据（Resource），不是代码
- **编辑器即生产力** — Resource 保存 → 游戏直接读取，零导出流程

---

## 二、核心架构修正：Phase 模型 vs 逐帧模型

### 错误做法：逐帧配 Hitbox（数据爆炸）

```
FrameData[0] { hitboxes: [] }
FrameData[1] { hitboxes: [] }
FrameData[2] { hitboxes: [] }
FrameData[3] { hitboxes: [slash_box] }   ← 手配
FrameData[4] { hitboxes: [slash_box] }   ← 重复
FrameData[5] { hitboxes: [slash_box] }   ← 重复
FrameData[6] { hitboxes: [slash_box] }   ← 重复
FrameData[7] { hitboxes: [] }
...

→ 30帧技能 × 10个技能 = 300条重复数据
→ 改一次 hitbox = 改 N 次
→ 不可维护
```

### 正确做法：AttackPhase 区间（DNF 真实做法）

```
SkillData {
    animation: AnimationData           ← 纯帧显示数据
    phases: [                          ← 攻击区间（核心）
        AttackPhase {
            start_frame: 3
            end_frame: 7
            hitbox: slash_box          ← 一段区间共享一个 hitbox
            events: [camera_shake]
        }
    ]
    events: [                          ← 时间轴单帧事件
        FrameEvent { frame: 2, type: PLAY_SOUND, data: {audio: "slash.ogg"} }
        FrameEvent { frame: 3, type: SUPER_ARMOR_START }
        FrameEvent { frame: 7, type: SUPER_ARMOR_END }
    ]
    movement: [                        ← 位移区间
        MovementPhase { start: 1, end: 4, velocity: Vector2(5, 0) }
    ]
}
```

### 两层分离：AnimationData（纯显示） + SkillData（纯逻辑）

| 层 | 数据 | 职责 |
|----|------|------|
| **AnimationData** | frames: Array[FrameData] | 纯显示：Atlas region / duration / 不含逻辑 |
| **SkillData** | phases + events + movement | 纯逻辑：hitbox 区间 / 事件 / 位移 / 霸体 |

**FrameData 只做显示，不放 hitbox！**

---

## 三、核心数据结构

### 3.1 FrameData（纯显示帧）

```gdscript
class_name DNFFrameData extends Resource

@export var region: Rect2        # Atlas 切片区域
@export var duration: int = 1    # 持续帧数
@export var anchor_offset: Vector2 = Vector2.ZERO  # 锚点偏移
```

### 3.2 AnimationData（帧动画）

```gdscript
class_name DNFAnimationData extends Resource

@export var anim_name: String
@export var fps: int = 12
@export var frames: Array       # DNFFrameData
@export var loop: bool = false
@export var atlas: Texture2D
```

### 3.3 AttackPhase（攻击区间 — 核心）

```gdscript
class_name DNFAttackPhase extends Resource

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var hitbox: Resource         # DNFHitboxData
@export var hit_behavior: Resource   # DNFHitBehavior
@export var events: Array            # DNFFrameEvent
```

### 3.4 HitboxData（碰撞体数据）

```gdscript
class_name DNFHitboxData extends Resource

enum HitLevel { MID, LOW, OVERHEAD, UNBLOCKABLE }

@export var shape_size: Vector2 = Vector2(40, 60)
@export var offset: Vector2 = Vector2(30, 0)
@export var hit_level: HitLevel = HitLevel.MID
```

### 3.5 MovementPhase（位移区间）

```gdscript
class_name DNFMovementPhase extends Resource

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var velocity: Vector2 = Vector2.ZERO
@export var relative_to_facing: bool = true
```

### 3.6 FrameEvent（单帧事件）

```gdscript
class_name DNFFrameEvent extends Resource

enum EventType {
    SPAWN_EFFECT, PLAY_SOUND, CAMERA_SHAKE, SPAWN_PROJECTILE,
    APPLY_BUFF, SUPER_ARMOR_START, SUPER_ARMOR_END,
    INVINCIBLE_START, INVINCIBLE_END,
    CANCEL_WINDOW_OPEN, CANCEL_WINDOW_CLOSE,
    CUSTOM_SIGNAL
}

@export var frame: int
@export var type: EventType
@export var data: Dictionary
```

### 3.7 SkillDataV2（技能定义 — 核心）

```gdscript
class_name DNFSkillDataV2 extends Resource

enum DamageType { PHYSICAL_PERCENT, MAGICAL_PERCENT, INDEPENDENT }
enum Element { NEUTRAL, FIRE, ICE, LIGHT, DARK }
enum SuperArmorLevel { NONE, LIGHT, HEAVY, FULL }

@export var skill_name: String
@export var display_name: String
@export var animation: Resource      # DNFAnimationData

@export var phases: Array            # DNFAttackPhase
@export var events: Array            # DNFFrameEvent
@export var movement: Array          # DNFMovementPhase

@export var mp_cost: int = 0
@export var hp_cost: int = 0
@export var cooldown_frames: int = 0

@export var damage_type: DamageType
@export var element: Element
@export var skill_coefficient: float = 1.0
@export var super_armor_level: SuperArmorLevel

@export var cancelable: bool = false
@export var cancel_into: Array[String]

@export var ground_only: bool = true
@export var air_usable: bool = false
@export var priority: int = 0
@export var input_conditions: Array  # DNFInputCondition

@export var ui: Resource             # DNFSkillUIData
```

### 3.8 CharacterData（角色总入口）

```gdscript
class_name DNFCharacterData extends Resource

@export var character_name: String
@export var display_name: String
@export var atlas: Texture2D
@export var portrait: Texture2D
@export var animations: Dictionary   # String → DNFAnimationData
@export var skills: Array            # DNFSkillDataV2
@export var stats: Resource          # DNFCharacterStats
```

---

## 四、运行时系统设计

### 4.1 FramePlayer（只管播放动画帧）

```gdscript
func play(anim: Resource):   # DNFAnimationData
    _anim = anim
    _frame_index = 0
    _frame_timer = 0

func tick():
    _frame_timer += 1
    var f = _anim.get_frame_at_index(_frame_index)
    if _frame_timer >= f.duration:
        _frame_timer = 0
        _frame_index += 1
    apply_display(f)
```

**FramePlayer 只管显示，不管逻辑。**

### 4.2 SkillComponentV2（管逻辑：Phase 匹配）

```gdscript
func tick():
    frame_player.tick()
    var frame = frame_player.get_current_frame_index()

    # 匹配攻击区间
    for phase in active_skill.phases:
        if phase.contains_frame(frame):
            hitbox_component.set_hitbox(phase.hitbox, phase.hit_behavior)

    # 匹配位移区间
    for mov in active_skill.movement:
        if mov.contains_frame(frame):
            apply_movement(mov)

    # 触发单帧事件
    for ev in active_skill.get_events_at_frame(frame):
        execute_event(ev)
```

### 4.3 HitboxComponent（运行时碰撞体管理）

```gdscript
func set_hitbox(hitbox_data: Resource, behavior: Resource):
    # 动态创建/更新 Area2D + CollisionShape2D

func clear_all():
    # 清除碰撞体
```

---

## 五、编辑器系统设计

### 5.1 Timeline（核心价值 — 技能逻辑编辑器）

**Timeline 不是动画编辑器，是技能逻辑编辑器。**

```
[工具栏: Play | Pause | Frame: 0/30 | Zoom]
[Sprite 预览窗口]
[Timeline 时间轴]
    ├── FrameRuler（帧刻度尺）
    │    |0---|1---|2---|3---|4---|5---|6---|7---|8---|
    ├── PhaseTrack（攻击区间轨道）
    │    |----[======]------|           ← 拖拽创建/调整区间
    ├── EventTrack（事件轨道）
    │    |----●------●------|           ← 点击添加事件
    ├── MovementTrack（位移轨道）
    │    |--[====]----------|           ← 拖拽位移区间
    └── ArmorTrack（霸体/无敌轨道）
         |------[=====]-----|           ← 拖拽霸体区间
[属性面板 Inspector]
    选中区间 → 编辑 hitbox/behavior/event 参数
```

### 5.2 用户操作流程

1. **创建攻击区间**: 在 PhaseTrack 上拖拽 → 生成 AttackPhase(start, end)
2. **绑定 Hitbox**: 选中区间 → Inspector 中配置 HitboxData
3. **添加事件**: 在 EventTrack 上点击帧位置 → 选事件类型
4. **预览**: 播放按钮 → 帧刻度推进 → Sprite 切换 + Hitbox 框实时绘制
5. **保存**: 自动保存到 SkillData Resource (.tres)

### 5.3 Hitbox 可视化

在 Sprite 预览窗口中：
```gdscript
func _draw():
    for phase in skill.phases:
        if current_frame >= phase.start_frame and current_frame <= phase.end_frame:
            var rect = Rect2(phase.hitbox.offset, phase.hitbox.shape_size)
            draw_rect(rect, Color.RED, false, 2.0)
```

### 5.4 Hitbox 模板复用

```
预设碰撞体模板:
  - Slash_Hitbox (前方横斩)
  - Thrust_Hitbox (前方刺击)
  - AOE_Hitbox (周围范围)
  - Projectile_Hitbox (弹道碰撞)

用户操作: 选区间 → 下拉选模板 → 自动填充 shape/offset
```

### 5.5 批量操作

```
选中多个帧 → 右键 → 批量应用 hitbox
选中区间 → 复制 → 粘贴到另一个技能
```

---

## 六、属性系统 + 伤害公式

### CharacterStats

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

### 伤害公式

```
百分比物理 = 技能倍率 × 物攻 × (1 + STR/250) × (1 - 物防减伤%) × 属性加成
百分比魔法 = 技能倍率 × 魔攻 × (1 + INT/250) × (1 - 魔防减伤%) × 属性加成
独立攻击   = 技能固伤 × (1 + STR或INT/250) × (1 - 防御减伤%) × 属性加成
属性加成   = 1 + (属性强化 - 敌方属性抗性) / 220
暴击       = 基础伤害 × (1 + 暴击伤害%)
```

---

## 七、Buff/Debuff + 状态异常

### Buff 类型
- **StatBuff** — 属性修正（+攻击/+防御/+速度）
- **DotBuff** — 持续伤害（灼烧/中毒/出血/感电）
- **CrowdControl** — 控制（眩晕/冰冻/石化/睡眠/束缚/减速/混乱/致盲）
- **ShieldBuff** — 护盾
- **SuperArmorBuff** — 霸体增益

### 叠加规则
- 相同 Buff: RESET_TIMER / EXTEND_TIMER / ADD_STACK
- 异常耐性: 每种异常独立耐性值

---

## 八、目标架构（三层分离）

```
addons/dnf_framework/
│
├── runtime/                          # 运行时
│   ├── frame/
│   │   └── frame_player.gd          # 帧播放器（只管显示）
│   ├── character/
│   │   ├── dnf_character.gd         # 角色基类
│   │   ├── dnf_states.gd            # 状态枚举
│   │   └── frame_character_body2d.gd
│   ├── input/
│   │   └── input_buffer.gd
│   ├── combat/
│   │   ├── hitbox_component.gd      # 碰撞体运行时管理
│   │   ├── hurtbox_component.gd
│   │   ├── combat_manager.gd
│   │   ├── damage_calculator.gd
│   │   └── super_armor.gd
│   ├── skill/
│   │   └── skill_component_v2.gd    # 技能执行（Phase 匹配）
│   ├── buff/
│   │   └── buff_component.gd
│   ├── stats/
│   │   └── stats_component.gd
│   └── enemy/
│       ├── enemy_character.gd
│       └── ai_component.gd
│
├── resources/                        # 数据定义（全 Resource）
│   ├── animation/
│   │   ├── animation_data.gd        # 帧序列
│   │   └── frame_data.gd            # 单帧（纯显示：region + duration）
│   ├── skill/
│   │   ├── skill_data_v2.gd         # 技能（含 phases + events + movement）
│   │   ├── attack_phase.gd          # 攻击区间 ★ 核心
│   │   ├── movement_phase.gd        # 位移区间
│   │   ├── frame_event.gd           # 单帧事件
│   │   ├── skill_ui_data.gd
│   │   └── input_condition.gd
│   ├── combat/
│   │   └── hitbox_data.gd           # 碰撞体数据
│   ├── character/
│   │   ├── character_data.gd        # 角色总入口
│   │   └── character_stats.gd
│   ├── buff/
│   │   ├── buff_data.gd
│   │   └── buff_effect.gd + 子类
│   ├── stats/
│   │   ├── stat_modifier.gd
│   │   └── element_system.gd
│   └── enemy/
│       ├── enemy_config.gd
│       └── ai_behavior.gd
│
├── editor/                           # 编辑器（@tool）
│   ├── panels/
│   │   ├── skill_editor.gd          # 技能编辑器主面板
│   │   ├── character_editor.gd
│   │   └── effect_editor.gd
│   ├── timeline/
│   │   ├── timeline_root.gd         # 时间轴根控件
│   │   ├── frame_ruler.gd           # 帧刻度尺
│   │   ├── phase_track.gd           # 攻击区间轨道 ★
│   │   ├── event_track.gd           # 事件轨道
│   │   ├── movement_track.gd        # 位移轨道
│   │   └── armor_track.gd           # 霸体/无敌轨道
│   ├── inspectors/
│   │   └── dnf_inspector_plugin.gd
│   └── preview/
│       ├── hitbox_preview.gd        # Sprite 上画碰撞体框
│       └── sprite_preview.gd
│
├── examples/
├── tests/
├── plugin.gd
└── plugin.cfg
```

---

## 九、分阶段开发路线

### Phase 1-5: 基础框架 ✅ 已完成

- ✅ InputBuffer（帧输入缓冲 + 连招检测）
- ✅ FrameAnimationPlayer（帧动画播放器）
- ✅ FrameCharacterBody2D（帧驱动物理角色）
- ✅ DNFStates + DNFCharacter（状态机 + 角色基类）
- ✅ DNFHitbox / DNFHurtbox / DNFHitBehavior / DNFCombatManager（战斗系统）
- ✅ DNFMove + DNFInputType（招式系统 + 取消系统）
- ✅ Phase 1-5 示例 + 152 项测试全部通过

### Phase 6: 核心数据层 + FramePlayer + Phase 系统 ✅ 已完成

- ✅ 6.1 Resource 数据层
  - ✅ `resources/animation/frame_data.gd` — DNFFrameData
  - ✅ `resources/animation/animation_data.gd` — DNFAnimationData
  - ✅ `resources/skill/attack_phase.gd` — DNFAttackPhase
  - ✅ `resources/skill/movement_phase.gd` — DNFMovementPhase
  - ✅ `resources/skill/frame_event.gd` — DNFFrameEvent（12 种事件类型）
  - ✅ `resources/combat/hitbox_data.gd` — DNFHitboxData
- ✅ 6.2 SkillDataV2 重写
  - ✅ `resources/skill/skill_data_v2.gd` — DNFSkillDataV2
  - ✅ `resources/skill/skill_ui_data.gd` — DNFSkillUIData
  - ✅ `resources/skill/input_condition.gd` — DNFInputCondition
- ✅ 6.3 运行时组件
  - ✅ `runtime/frame/frame_player.gd` — DNFFramePlayer
  - ✅ `runtime/combat/hitbox_component.gd` — DNFHitboxComponent
  - ✅ `runtime/combat/hurtbox_component.gd` — DNFHurtboxComponent
  - ✅ `runtime/skill/skill_component_v2.gd` — DNFSkillComponentV2
- ✅ 6.4 CharacterData
  - ✅ `resources/character/character_data.gd` — DNFCharacterData
  - ✅ `resources/character/character_stats.gd` — DNFCharacterStats（28 项 DNF 属性）
- ✅ 6.5 plugin.gd 更新 + 测试 + 中文文档注释
  - ✅ plugin.gd 注册 4 个新自定义类型
  - ✅ Phase6_DataLayer 测试套件（67 项测试）
  - ✅ 全部 219/219 测试通过
  - ✅ 所有 Resource 属性添加中文 `##` 文档注释
  - ✅ CONFIGURATOR_GUIDE.md 配置器使用指南
- ⚠️ 6.5 部分未完成
  - ❌ 6.5.2 迁移保留模块到 runtime/（InputBuffer / FrameCharacterBody2D / DNFStates / DNFCharacter / CombatManager 仍在旧目录）
  - ❌ 6.5.3 更新所有 preload/extends 路径
  - ❌ 6.5.6 创建新示例（基于 SkillDataV2 + Phase 配置的 .tres 示例）
- ❌ 6.1.7 HitBehavior 扩充（damage_type/element/skill_coefficient/fixed_damage 未加入 hit_behavior.gd）

### Phase 7: 属性系统 + 伤害公式 ⬚ 未开始

- ❌ 7.1 CharacterStats Resource（✅ 已在 Phase 6.4 提前完成）
- ❌ 7.2 `resources/stats/stat_modifier.gd` — 属性修正器
- ❌ 7.3 `resources/stats/element_system.gd` — 属性克制
- ❌ 7.4 `runtime/combat/damage_calculator.gd` — 伤害公式
- ❌ 7.5 `runtime/stats/stats_component.gd` — 属性计算组件
- ❌ 7.6 重构 DNFCharacter 集成 CharacterStats
- ❌ 7.7 重构 CombatManager 使用 DamageCalculator
- ❌ 7.8 扩充 DNFStates（+DEAD/GRAB/GRABBED/CHANNELING/CHARGING/STUNNED/FROZEN/PETRIFIED）
- ❌ 7.9 测试 + 示例

### Phase 8: Buff/Debuff + 状态异常 ⬚ 未开始

- ❌ 8.1 `resources/buff/buff_data.gd`
- ❌ 8.2 `resources/buff/buff_effect.gd` + stat/dot/cc 子类
- ❌ 8.3 `runtime/buff/buff_component.gd`
- ❌ 8.4 DNFCharacter 集成 BuffComponent
- ❌ 8.5 测试 + 示例

### Phase 9: 技能深化 + 霸体 + 格挡/抓取 ⬚ 未开始

- ❌ 9.1 `runtime/combat/super_armor.gd`
- ❌ 9.2 格挡系统（BLOCK + guard_break）
- ❌ 9.3 抓取系统（GRAB/GRABBED + 解除）
- ❌ 9.4 蓄力/持续释放（CHARGING/CHANNELING）
- ❌ 9.5 被动技能（passive_manager）
- ❌ 9.6 测试 + 示例

### Phase 10: 编辑器 — Timeline + Phase Editor + Hitbox Preview ⬚ 未开始

- ❌ 10.1-10.12（详见 task.md）

### Phase 11: 编辑器 — Skill + Character Editor ⬚ 未开始

- ❌ 11.1-11.4（详见 task.md）

### Phase 12: 敌人 AI + 集成示例 ⬚ 未开始

- ❌ 12.1-12.7（详见 task.md）

---

## 十、设计原则

### 1. 帧驱动 ≠ 逐帧配置
```
帧驱动 = 时间轴区间控制
AttackPhase 一段区间共享一个 hitbox
不是每帧手动配碰撞体
```

### 2. 两层分离：显示 vs 逻辑
```
AnimationData = 纯显示（region + duration）
SkillData     = 纯逻辑（phases + events + movement）
```

### 3. 三层分离：runtime / resources / editor
```
runtime/   = 游戏运行时代码
resources/ = 纯数据 Resource（.tres 即配置）
editor/    = @tool 编辑器代码
```

### 4. 数据驱动
```
技能 = 数据（Resource）
不是代码
```

### 5. 解耦
```
FramePlayer（显示）≠ SkillComponentV2（逻辑）
SkillDataV2（数据）≠ HitboxComponent（运行时）
```

### 6. Rollback-friendly
```
所有运行时组件实现 _save_state / _load_state
```

---

## 十一、防坑清单

| 坑 | 后果 | 正确做法 |
|----|------|---------|
| 逐帧配 hitbox | 30帧×10技能=300条重复数据 | AttackPhase 区间共享 hitbox |
| 用 AnimationPlayer | 无法帧精确控制 | FramePlayer + AnimationData |
| Hitbox 写死在场景 | 无法按区间切换 | HitboxData + HitboxComponent 运行时管理 |
| 不做 Resource | 无法编辑器化 | 一切配置 = Resource |
| Skill 和 Move 分两套 | 概念混乱 | 统一为 SkillDataV2 |
| FrameData 放逻辑 | 显示和逻辑耦合 | FrameData 纯显示，逻辑在 SkillData |
| Timeline 做成动画编辑器 | 方向错误 | Timeline = 技能逻辑编辑器 |
| Godot 4 typed array 跨脚本 | headless 模式 class_name 查找失败 | Resource 中用 untyped Array + 注释标注类型 |
