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
class_name FrameData extends Resource

@export var region: Rect2        # Atlas 切片区域
@export var duration: int = 1    # 持续帧数（通常 1）
```

### 3.2 AnimationData（帧动画）

```gdscript
class_name AnimationData extends Resource

@export var anim_name: String
@export var fps: int = 12
@export var frames: Array[FrameData]
@export var loop: bool = false
```

### 3.3 AttackPhase（攻击区间 — 核心）

```gdscript
class_name AttackPhase extends Resource

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var hitbox: HitboxData         # 该区间的碰撞体
@export var hit_behavior: HitBehavior  # 该区间的受击行为
@export var events: Array[FrameEvent]  # 区间内触发的事件
```

### 3.4 HitboxData（碰撞体数据）

```gdscript
class_name HitboxData extends Resource

@export var shape: Vector2       # 碰撞体尺寸
@export var offset: Vector2      # 相对角色原点偏移
@export var hit_level: HitLevel  # MID/LOW/OVERHEAD/UNBLOCKABLE
```

### 3.5 MovementPhase（位移区间）

```gdscript
class_name MovementPhase extends Resource

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var velocity: Vector2           # 位移速度
@export var relative_to_facing: bool = true
```

### 3.6 FrameEvent（单帧事件）

```gdscript
class_name FrameEvent extends Resource

enum Type {
    SPAWN_EFFECT, PLAY_SOUND, CAMERA_SHAKE, SPAWN_PROJECTILE,
    APPLY_BUFF, SUPER_ARMOR_START, SUPER_ARMOR_END,
    INVINCIBLE_START, INVINCIBLE_END,
    CANCEL_WINDOW_OPEN, CANCEL_WINDOW_CLOSE,
    CUSTOM_SIGNAL
}

@export var frame: int           # 触发帧
@export var type: Type
@export var data: Dictionary     # 事件参数
```

### 3.7 SkillData（技能定义 — 核心）

```gdscript
class_name SkillData extends Resource

@export var skill_name: String
@export var display_name: String
@export var animation: AnimationData     # 引用帧动画

# 攻击区间（核心逻辑层）
@export var phases: Array[AttackPhase]
@export var events: Array[FrameEvent]    # 单帧事件
@export var movement: Array[MovementPhase]  # 位移区间

# 消耗
@export var mp_cost: int = 0
@export var hp_cost: int = 0
@export var cooldown_frames: int = 0

# 属性
@export var damage_type: DamageType
@export var element: Element
@export var skill_coefficient: float = 1.0
@export var super_armor_level: SuperArmorLevel = SuperArmorLevel.NONE

# 取消系统
@export var cancelable: bool = false
@export var cancel_into: Array[String]

# 条件
@export var ground_only: bool = true
@export var air_usable: bool = false
@export var priority: int = 0

# UI
@export var ui: SkillUIData
@export var input_conditions: Array[InputCondition]
```

### 3.8 CharacterData（角色总入口）

```gdscript
class_name CharacterData extends Resource

@export var character_name: String
@export var atlas: Texture2D
@export var animations: Dictionary  # String → AnimationData
@export var skills: Array[SkillData]
@export var stats: CharacterStats
```

---

## 四、运行时系统设计

### 4.1 FramePlayer（只管播放动画帧）

```gdscript
func play(anim: AnimationData):
    _anim = anim
    _frame_index = 0
    _frame_timer = 0

func tick():
    _frame_timer += 1
    var f = _anim.frames[_frame_index]
    if _frame_timer >= f.duration:
        _frame_timer = 0
        _frame_index += 1
    apply_display(f)  # 只设 sprite.region_rect

func apply_display(f: FrameData):
    sprite.region_rect = f.region
```

**FramePlayer 只管显示，不管逻辑。**

### 4.2 SkillComponent（管逻辑：Phase 匹配）

```gdscript
func tick():
    frame_player.tick()
    var frame = frame_player.get_current_frame_index()

    # 匹配攻击区间
    for phase in active_skill.phases:
        if frame >= phase.start_frame and frame <= phase.end_frame:
            hitbox_component.set_hitbox(phase.hitbox, phase.hit_behavior)
        else:
            hitbox_component.clear_phase_hitbox(phase)

    # 匹配位移区间
    for mov in active_skill.movement:
        if frame >= mov.start_frame and frame <= mov.end_frame:
            apply_movement(mov)

    # 触发单帧事件
    for ev in active_skill.events:
        if ev.frame == frame:
            execute_event(ev)
```

### 4.3 HitboxComponent（运行时碰撞体管理）

```gdscript
func set_hitbox(hitbox_data: HitboxData, behavior: HitBehavior):
    # 动态创建/更新 Area2D + CollisionShape2D
    # 不再依赖场景中的固定节点

func clear_phase_hitbox(phase: AttackPhase):
    # 清除该 phase 对应的碰撞体
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
    # 当前帧在哪个 AttackPhase 区间内？
    for phase in skill.phases:
        if current_frame >= phase.start_frame and current_frame <= phase.end_frame:
            var rect = Rect2(phase.hitbox.offset, phase.hitbox.shape)
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
│   │   └── skill_component.gd       # 技能执行（Phase 匹配）
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
│   │   ├── skill_data.gd            # 技能（含 phases + events + movement）
│   │   ├── attack_phase.gd          # 攻击区间 ★ 核心
│   │   ├── movement_phase.gd        # 位移区间
│   │   ├── frame_event.gd           # 单帧事件
│   │   ├── skill_ui_data.gd
│   │   └── input_condition.gd
│   ├── combat/
│   │   ├── hitbox_data.gd           # 碰撞体数据
│   │   └── hit_behavior.gd
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

### Phase 6: 核心数据层 + FramePlayer + Phase 系统

1. FrameData（纯显示）+ AnimationData
2. AttackPhase + MovementPhase + FrameEvent
3. HitboxData + HitBehavior 扩充
4. SkillData（含 phases/events/movement）
5. FramePlayer（只管显示）
6. SkillComponent（Phase 匹配逻辑）
7. HitboxComponent（运行时碰撞体管理）
8. CharacterData
9. 目录迁移 + 兼容
10. 测试 + 示例

### Phase 7: 属性系统 + 伤害公式

### Phase 8: Buff/Debuff + 状态异常

### Phase 9: 技能深化 + 霸体 + 格挡/抓取

### Phase 10: 编辑器 — Timeline + PhaseTrack + Hitbox Preview

1. TimelineRoot + FrameRuler
2. PhaseTrack（拖拽创建/调整攻击区间）
3. EventTrack（点击添加事件）
4. MovementTrack + ArmorTrack
5. HitboxPreview（Sprite 上画框）
6. SpritePreview（帧预览）

### Phase 11: 编辑器 — Skill + Character Editor

### Phase 12: 敌人 AI + 集成示例

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
FramePlayer（显示）≠ SkillComponent（逻辑）
SkillData（数据）≠ HitboxComponent（运行时）
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
| Skill 和 Move 分两套 | 概念混乱 | 统一为 SkillData |
| FrameData 放逻辑 | 显示和逻辑耦合 | FrameData 纯显示，逻辑在 SkillData |
| Timeline 做成动画编辑器 | 方向错误 | Timeline = 技能逻辑编辑器 |
