# DNF Framework 配置器使用指南

本文档说明如何通过 Godot 编辑器的 Inspector 面板，使用 Resource 来配置角色、技能、动画帧和碰撞体，无需编写代码。

---

## 目录

1. [前提准备](#1-前提准备)
2. [架构总览](#2-架构总览)
3. [配置角色属性 (CharacterStats)](#3-配置角色属性-characterstats)
4. [配置帧动画 (AnimationData + FrameData)](#4-配置帧动画-animationdata--framedata)
5. [配置碰撞体 (HitboxData)](#5-配置碰撞体-hitboxdata)
6. [配置受击行为 (HitBehavior)](#6-配置受击行为-hitbehavior)
7. [配置技能 (SkillDataV2)](#7-配置技能-skilldatav2)
   - 7.1 [攻击区间 (AttackPhase)](#71-攻击区间-attackphase)
   - 7.2 [位移区间 (MovementPhase)](#72-位移区间-movementphase)
   - 7.3 [帧事件 (FrameEvent)](#73-帧事件-frameevent)
   - 7.4 [输入条件 (InputCondition)](#74-输入条件-inputcondition)
   - 7.5 [技能UI (SkillUIData)](#75-技能ui-skilluidata)
8. [配置角色总入口 (CharacterData)](#8-配置角色总入口-characterdata)
9. [场景中添加运行时组件](#9-场景中添加运行时组件)
10. [完整配置示例：「鬼斩」技能](#10-完整配置示例鬼斩技能)
11. [常见问题](#11-常见问题)

---

## 1. 前提准备

1. 在 **项目 → 项目设置 → 插件** 中启用 `DNF Framework`
2. 重启编辑器（确保自定义类型注册生效）
3. 确认 Inspector 中可以创建以下 Resource 类型：
   - `DNFFrameData`、`DNFAnimationData`
   - `DNFHitboxData`、`DNFHitBehavior`
   - `DNFAttackPhase`、`DNFMovementPhase`、`DNFFrameEvent`
   - `DNFSkillDataV2`、`DNFInputCondition`、`DNFSkillUIData`
   - `DNFCharacterStats`、`DNFCharacterData`

---

## 2. 架构总览

DNF Framework 的核心设计原则是**数据驱动 + 区间控制**：

```
CharacterData（角色总入口）
  ├── stats: CharacterStats（属性：HP/MP/力量/智力/暴击…）
  ├── atlas: Texture2D（精灵图集）
  ├── animations: { "idle": AnimationData, "walk": AnimationData, ... }
  └── skills: [
        SkillDataV2（技能定义）
          ├── animation: AnimationData（显示层 — 纯帧序列）
          ├── phases: [ AttackPhase, ... ]（逻辑层 — 攻击区间）
          ├── events: [ FrameEvent, ... ]（时间轴事件）
          └── movement: [ MovementPhase, ... ]（位移区间）
      ]
```

关键理念：**帧驱动 ≠ 逐帧配置**。你不需要为每一帧单独配置碰撞体，而是定义「攻击区间」——一段帧范围共享一个碰撞体和受击行为。

---

## 3. 配置角色属性 (CharacterStats)

在 FileSystem 中右键 → **新建资源** → 选择 `DNFCharacterStats` → 保存为 `.tres` 文件。

在 Inspector 中可以编辑以下属性组：

| 属性组 | 属性 | 默认值 | 说明 |
|--------|------|--------|------|
| **基础** | `max_hp` | 1000 | 最大生命值 |
| | `max_mp` | 500 | 最大魔力值 |
| **四维** | `strength` | 100 | 力量（影响物理攻击） |
| | `intelligence` | 100 | 智力（影响魔法攻击） |
| | `vitality` | 100 | 体力（影响HP） |
| | `spirit` | 100 | 精神（影响MP） |
| **攻击** | `physical_attack` | 200 | 物理攻击力 |
| | `magical_attack` | 200 | 魔法攻击力 |
| | `independent_attack` | 200 | 独立攻击力 |
| **防御** | `physical_defense` | 100 | 物理防御 |
| | `magical_defense` | 100 | 魔法防御 |
| **速度** | `attack_speed` | 0.0 | 攻速加成 |
| | `cast_speed` | 0.0 | 施放速度加成 |
| | `move_speed` | 5.0 | 移动速度 |
| **暴击** | `physical_crit` | 0.05 | 物理暴击率 (5%) |
| | `magical_crit` | 0.05 | 魔法暴击率 (5%) |
| | `crit_damage` | 0.5 | 暴击伤害加成 (50%) |
| **属性强化** | `fire/ice/light/dark_enhance` | 0 | 各属性强化值 |
| **属性抗性** | `fire/ice/light/dark_resist` | 0 | 各属性抗性值 |

---

## 4. 配置帧动画 (AnimationData + FrameData)

### 4.1 创建 FrameData（单帧）

每个 `DNFFrameData` 代表精灵图集中的**一个显示帧**：

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `region` | `Rect2` | (0,0,0,0) | 在 atlas 图集中的裁剪区域 (x, y, w, h) |
| `duration` | `int` | 1 | 该帧持续的逻辑帧数（不是秒） |
| `anchor_offset` | `Vector2` | (0,0) | 精灵的锚点偏移（用于对齐脚底等） |

### 4.2 创建 AnimationData（帧序列）

新建 `DNFAnimationData` 资源：

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `anim_name` | `String` | "" | 动画名称（如 "idle"、"slash"） |
| `fps` | `int` | 12 | 帧率（用于预览和编辑器） |
| `frames` | `Array` | [] | FrameData 数组，按播放顺序排列 |
| `loop` | `bool` | false | 是否循环播放 |
| `atlas` | `Texture2D` | null | 精灵图集纹理 |

### 操作步骤

1. 准备好角色的精灵图集（SpriteSheet）
2. 新建 `DNFAnimationData` 资源，命名如 `slash_anim.tres`
3. 设置 `atlas` 为你的精灵图集
4. 在 `frames` 数组中添加 `DNFFrameData` 元素
5. 为每个 FrameData 设置 `region`（对应图集中该帧的矩形区域）和 `duration`

**示例：3 帧的斩击动画**

```
frames[0]: region=(0, 0, 64, 64),  duration=2   ← 准备动作，持续 2 帧
frames[1]: region=(64, 0, 64, 64), duration=3   ← 挥刀动作，持续 3 帧
frames[2]: region=(128, 0, 64, 64), duration=1  ← 收招动作，持续 1 帧
总逻辑帧数 = 2 + 3 + 1 = 6
```

---

## 5. 配置碰撞体 (HitboxData)

新建 `DNFHitboxData` 资源：

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `shape_size` | `Vector2` | (40, 60) | 矩形碰撞体的宽高（像素） |
| `offset` | `Vector2` | (30, 0) | 碰撞体相对角色中心的偏移（朝向右时） |
| `hit_level` | `HitLevel` | MID | 攻击判定高度 |

**HitLevel 枚举：**

| 值 | 说明 |
|----|------|
| `MID` | 中段攻击（站防可挡） |
| `LOW` | 下段攻击（需蹲防） |
| `OVERHEAD` | 上段攻击（需站防） |
| `UNBLOCKABLE` | 不可防御 |

可以预先创建常用模板，如 `slash_hitbox.tres`、`fireball_hitbox.tres`、`aoe_hitbox.tres`，供多个技能复用。

---

## 6. 配置受击行为 (HitBehavior)

新建 `DNFHitBehavior` 资源：

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `damage` | `int` | 10 | 伤害值 |
| `hit_type` | `HitType` | NORMAL | 受击类型 |
| `hitstun_frames` | `int` | 12 | 被攻击方的僵直帧数 |
| `hitstop_frames` | `int` | 3 | 双方顿帧帧数（打击感） |
| `knockback_force` | `float` | 6.0 | 水平击退力度 |
| `launch_force` | `float` | -18.0 | 垂直击飞力度（仅 LAUNCH 类型） |
| `self_knockback` | `float` | 2.0 | 攻击方自身后坐力 |

**HitType 与角色状态的对应关系：**

| HitType | 目标状态 | 表现 |
|---------|----------|------|
| `NORMAL` | HIT_STUN | 原地僵直 + 轻微击退 |
| `KNOCK_BACK` | KNOCK_BACK | 向后滑行击退 |
| `KNOCK_DOWN` | KNOCK_DOWN | 倒地 → 起身 |
| `LAUNCH` | AIR_BORNE | 击飞至空中 → 落地 → 倒地 |

---

## 7. 配置技能 (SkillDataV2)

`DNFSkillDataV2` 是技能的核心定义，由以下部分组成：

### 基本信息

| 属性 | 类型 | 说明 |
|------|------|------|
| `skill_name` | `String` | 技能内部名称（唯一标识，如 "ghost_slash"） |
| `display_name` | `String` | 显示名称（如 "鬼斩"） |
| `animation` | `Resource` | 关联的 DNFAnimationData |

### 消耗与冷却

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `mp_cost` | `int` | 0 | MP 消耗 |
| `hp_cost` | `int` | 0 | HP 消耗 |
| `cooldown_frames` | `int` | 0 | 冷却帧数（0=无冷却） |

### 伤害属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `damage_type` | `DamageType` | PHYSICAL_PERCENT | 百分比物攻/百分比魔攻/独立 |
| `element` | `Element` | NEUTRAL | 属性：无/火/冰/光/暗 |
| `skill_coefficient` | `float` | 1.0 | 技能系数（倍率） |
| `super_armor_level` | `SuperArmorLevel` | NONE | 霸体等级：无/轻/重/完全 |

### 取消系统

| 属性 | 类型 | 说明 |
|------|------|------|
| `cancelable` | `bool` | 是否可被取消 |
| `cancel_into` | `Array[String]` | 可取消到的技能名列表 |

### 使用条件

| 属性 | 类型 | 说明 |
|------|------|------|
| `ground_only` | `bool` | 仅地面可用 |
| `air_usable` | `bool` | 空中可用 |
| `priority` | `int` | 优先级（多个技能同时满足条件时） |
| `input_conditions` | `Array` | 输入条件列表 |

---

### 7.1 攻击区间 (AttackPhase)

这是 DNF Framework 最核心的概念。一个 `DNFAttackPhase` 定义了**一段帧范围内共享的攻击判定**。

| 属性 | 类型 | 说明 |
|------|------|------|
| `start_frame` | `int` | 攻击判定开始帧 |
| `end_frame` | `int` | 攻击判定结束帧 |
| `hitbox` | `Resource` | 碰撞体数据 (DNFHitboxData) |
| `hit_behavior` | `Resource` | 受击行为 (DNFHitBehavior) |
| `events` | `Array` | 该区间内的帧事件 |

**示例：斩击技能（总 6 帧）**

```
帧 0-1：准备动作（无攻击判定）
帧 2-4：攻击判定（共享一个 hitbox）
帧 5  ：收招动作（无攻击判定）

只需配置 1 个 AttackPhase：
  start_frame = 2
  end_frame = 4
  hitbox = slash_hitbox.tres
  hit_behavior = normal_hit.tres
```

你不需要为帧 2、3、4 分别配置碰撞体 — 它们共享同一个 `AttackPhase`。

一个技能可以有**多个 AttackPhase**（多段攻击）：

```
phases[0]: start=2, end=4, hitbox=slash1   ← 第一段
phases[1]: start=8, end=10, hitbox=slash2  ← 第二段
```

### 7.2 位移区间 (MovementPhase)

定义技能施放期间角色的位移。

| 属性 | 类型 | 说明 |
|------|------|------|
| `start_frame` | `int` | 位移开始帧 |
| `end_frame` | `int` | 位移结束帧 |
| `velocity` | `Vector2` | 位移速度（像素/帧） |
| `relative_to_facing` | `bool` | 是否根据朝向翻转 X 轴 |

**示例：突进斩（帧 1-3 向前冲刺）**

```
start_frame = 1
end_frame = 3
velocity = (8, 0)        ← 每帧向前移动 8 像素
relative_to_facing = true ← 朝左时自动变为 (-8, 0)
```

### 7.3 帧事件 (FrameEvent)

在特定帧触发的一次性事件。

| 属性 | 类型 | 说明 |
|------|------|------|
| `frame` | `int` | 触发帧 |
| `type` | `EventType` | 事件类型 |
| `data` | `Dictionary` | 附加数据 |

**可用的事件类型：**

| EventType | 用途 | data 示例 |
|-----------|------|-----------|
| `SPAWN_EFFECT` | 生成特效 | `{"scene": "res://fx/slash.tscn", "offset": Vector2(20,0)}` |
| `PLAY_SOUND` | 播放音效 | `{"audio": "res://sfx/slash.ogg"}` |
| `CAMERA_SHAKE` | 镜头震动 | `{"intensity": 5.0, "duration": 0.2}` |
| `SPAWN_PROJECTILE` | 生成弹幕 | `{"scene": "res://proj/fireball.tscn"}` |
| `APPLY_BUFF` | 施加 BUFF | `{"buff_id": "attack_up", "duration": 300}` |
| `SUPER_ARMOR_START` | 开启霸体 | `{}` |
| `SUPER_ARMOR_END` | 关闭霸体 | `{}` |
| `INVINCIBLE_START` | 开启无敌 | `{}` |
| `INVINCIBLE_END` | 关闭无敌 | `{}` |
| `CANCEL_WINDOW_OPEN` | 开放取消窗口 | `{}` |
| `CANCEL_WINDOW_CLOSE` | 关闭取消窗口 | `{}` |
| `CUSTOM_SIGNAL` | 自定义信号 | `{"signal_name": "my_event"}` |

### 7.4 输入条件 (InputCondition)

定义技能的触发条件。

| 属性 | 类型 | 说明 |
|------|------|------|
| `condition_type` | `ConditionType` | 条件类型 |
| `input_name` | `String` | 输入键名 |
| `input_value` | `bool` | 期望值（EQUAL_CHECK 用） |
| `motion_sequence` | `Array[String]` | 指令序列（COMMAND_MOTION 用） |
| `hold_frames` | `int` | 按住帧数（HOLD_CHECK 用） |
| `tap_window` | `int` | 双击窗口帧数（DOUBLE_TAP 用） |

**条件类型：**

| ConditionType | 说明 | 示例 |
|---------------|------|------|
| `EQUAL_CHECK` | 简单键值匹配 | input_name="punch", input_value=true |
| `COMMAND_MOTION` | 指令输入（↓↘→等） | motion_sequence=["down","down_right","right"] |
| `HOLD_CHECK` | 长按检测 | input_name="charge", hold_frames=30 |
| `DOUBLE_TAP` | 双击检测 | input_name="right", tap_window=12 |

### 7.5 技能UI (SkillUIData)

技能在界面上的显示信息。

| 属性 | 类型 | 说明 |
|------|------|------|
| `icon` | `Texture2D` | 技能图标 |
| `display_name` | `String` | 显示名称 |
| `description` | `String` | 技能描述文本 |
| `hotkey_hint` | `String` | 快捷键提示（如 "↓↘→ + Z"） |

---

## 8. 配置角色总入口 (CharacterData)

`DNFCharacterData` 是角色的**总配置文件**，将所有数据汇聚在一起：

| 属性 | 类型 | 说明 |
|------|------|------|
| `character_name` | `String` | 角色内部名称 |
| `display_name` | `String` | 显示名称 |
| `portrait` | `Texture2D` | 角色立绘 |
| `atlas` | `Texture2D` | 角色精灵图集 |
| `animations` | `Dictionary` | 动画字典 (key=动画名, value=DNFAnimationData) |
| `skills` | `Array` | 技能列表 (DNFSkillDataV2) |
| `stats` | `Resource` | 角色属性 (DNFCharacterStats) |

### 操作步骤

1. 新建 `DNFCharacterData` → 保存为 `warrior.tres`
2. 设置 `character_name = "warrior"`
3. 指定 `atlas` 为角色精灵图集
4. 在 `animations` 中添加键值对：
   - `"idle"` → idle_anim.tres
   - `"walk"` → walk_anim.tres
   - `"slash"` → slash_anim.tres
5. 在 `skills` 数组中添加技能资源
6. 指定 `stats` 为之前创建的 CharacterStats 资源

---

## 9. 场景中添加运行时组件

在角色场景中添加以下节点来驱动技能系统：

```
CharacterRoot (CharacterBody2D 或 DNFCharacter)
  ├── Sprite2D                  ← 角色精灵
  ├── DNFFramePlayer            ← 帧播放器（驱动 Sprite 显示）
  ├── DNFHitboxComponent        ← 攻击碰撞体（运行时动态创建）
  ├── DNFHurtboxComponent       ← 受击碰撞体
  └── DNFSkillComponentV2       ← 技能执行组件
```

### 各组件设置

**DNFFramePlayer**
- 在 Inspector 中将 `sprite` 属性指向场景中的 `Sprite2D` 节点

**DNFSkillComponentV2**
- 将 `frame_player_path` 指向 `DNFFramePlayer` 节点
- 将 `hitbox_component_path` 指向 `DNFHitboxComponent` 节点

**DNFHurtboxComponent**
- 添加一个 `CollisionShape2D` 子节点作为受击范围

### 代码中使用

```gdscript
# 获取组件引用
@onready var skill_comp: DNFSkillComponentV2 = $DNFSkillComponentV2

# 加载角色数据
var char_data: DNFCharacterData = preload("res://data/warrior.tres")

# 释放技能
var slash = char_data.get_skill_by_name("ghost_slash")
if slash and not skill_comp.is_on_cooldown("ghost_slash"):
    skill_comp.play_skill(slash)

# 每帧驱动
func _physics_process(_delta):
    skill_comp.tick()

# 监听信号
skill_comp.skill_started.connect(func(skill): print("技能开始: ", skill.display_name))
skill_comp.skill_ended.connect(func(skill): print("技能结束: ", skill.display_name))
skill_comp.phase_entered.connect(func(phase, frame): print("攻击区间开始 帧:", frame))
skill_comp.event_fired.connect(func(event): print("事件触发: ", event.type))
```

---

## 10. 完整配置示例：「鬼斩」技能

以鬼剑士的「鬼斩」为例，演示从零配置一个技能的完整流程。

### 第一步：创建帧动画

新建 `ghost_slash_anim.tres` (DNFAnimationData)：

```
anim_name = "ghost_slash"
fps = 12
loop = false
atlas = 鬼剑士精灵图集.png

frames:
  [0] region=(0,0,96,96),    duration=3   ← 举刀准备
  [1] region=(96,0,96,96),   duration=2   ← 挥刀中
  [2] region=(192,0,96,96),  duration=4   ← 刀光展开
  [3] region=(288,0,96,96),  duration=2   ← 收招
  
总帧数 = 3 + 2 + 4 + 2 = 11
```

### 第二步：创建碰撞体模板

新建 `ghost_slash_hitbox.tres` (DNFHitboxData)：

```
shape_size = (80, 60)    ← 大范围横斩
offset = (40, 0)         ← 偏向前方
hit_level = MID          ← 中段
```

### 第三步：创建受击行为

新建 `ghost_slash_hit.tres` (DNFHitBehavior)：

```
damage = 25
hit_type = KNOCK_BACK     ← 击退效果
hitstun_frames = 18
hitstop_frames = 5         ← 较强打击感
knockback_force = 10.0
self_knockback = 3.0
```

### 第四步：组装技能

新建 `ghost_slash_skill.tres` (DNFSkillDataV2)：

```
skill_name = "ghost_slash"
display_name = "鬼斩"
animation = ghost_slash_anim.tres
mp_cost = 20
cooldown_frames = 60       ← 约 1 秒冷却
damage_type = PHYSICAL_PERCENT
element = DARK
skill_coefficient = 1.5
super_armor_level = LIGHT

phases:
  [0] AttackPhase:
        start_frame = 3       ← 帧 3（挥刀起始）
        end_frame = 8         ← 帧 8（刀光持续）
        hitbox = ghost_slash_hitbox.tres
        hit_behavior = ghost_slash_hit.tres

movement:
  [0] MovementPhase:
        start_frame = 2
        end_frame = 5
        velocity = (6, 0)     ← 向前突进
        relative_to_facing = true

events:
  [0] FrameEvent:
        frame = 3
        type = PLAY_SOUND
        data = {"audio": "res://sfx/ghost_slash.ogg"}
  [1] FrameEvent:
        frame = 3
        type = SPAWN_EFFECT
        data = {"scene": "res://fx/slash_wave.tscn"}
  [2] FrameEvent:
        frame = 5
        type = CAMERA_SHAKE
        data = {"intensity": 3.0}

input_conditions:
  [0] InputCondition:
        condition_type = EQUAL_CHECK
        input_name = "skill_1"
        input_value = true

cancelable = true
cancel_into = ["upper_slash"]  ← 可取消到上挑斩

ui:
  icon = ghost_slash_icon.png
  display_name = "鬼斩"
  description = "向前突进并释放暗属性斩击"
  hotkey_hint = "A 键"
```

### 第五步：添加到角色

在 `warrior.tres` (DNFCharacterData) 中：

```
skills = [ ghost_slash_skill.tres, ... ]
```

---

## 11. 常见问题

**Q: 资源文件保存在哪里比较好？**

建议按角色分目录组织：

```
res://data/
  ├── characters/
  │    ├── warrior/
  │    │    ├── warrior_data.tres         (CharacterData)
  │    │    ├── warrior_stats.tres        (CharacterStats)
  │    │    ├── anims/
  │    │    │    ├── idle_anim.tres
  │    │    │    └── slash_anim.tres
  │    │    ├── skills/
  │    │    │    ├── ghost_slash.tres
  │    │    │    └── upper_slash.tres
  │    │    └── hitboxes/
  │    │         ├── slash_hitbox.tres
  │    │         └── thrust_hitbox.tres
  │    └── mage/
  │         └── ...
  └── shared/
       ├── hit_behaviors/
       │    ├── normal_hit.tres
       │    ├── knockback_hit.tres
       │    └── launch_hit.tres
       └── hitboxes/
            └── aoe_large.tres
```

**Q: 碰撞体可以复用吗？**

可以。`DNFHitboxData` 和 `DNFHitBehavior` 都是独立的 Resource，一个碰撞体模板可以被多个 AttackPhase 引用。修改模板会自动影响所有使用它的技能。

**Q: 同一帧有多个 AttackPhase 会怎样？**

`DNFSkillComponentV2` 会同时激活所有匹配当前帧的 Phase，但运行时只会应用最后一个匹配的 hitbox。如果需要多重碰撞体，请使用多个 `DNFHitboxComponent`。

**Q: 如何配置多段技能（连续攻击）？**

在 `phases` 数组中添加多个 `DNFAttackPhase`，每个对应不同的帧范围：

```
phases[0]: start=3,  end=5,  hitbox=hit1  ← 第一段
phases[1]: start=8,  end=10, hitbox=hit2  ← 第二段
phases[2]: start=14, end=16, hitbox=hit3  ← 第三段（可以用更强的 hit_behavior）
```

**Q: 技能系统和旧的 DNFMove 系统的区别？**

`DNFMove`（Phase 1-5）是代码驱动的轻量招式系统，适合简单的攻击定义。`DNFSkillDataV2`（Phase 6+）是完全数据驱动的技能系统，支持区间控制、多段攻击、位移、事件、消耗/冷却、属性系统等，适合复杂的 DNF 风格技能配置。两者可以共存。

**Q: 当前有可视化 Timeline 编辑器吗？**

Timeline 编辑器是后续计划中的功能（Phase 7+），目前所有配置通过 Inspector 面板完成。Resource 系统已经支持在 Inspector 中创建和编辑所有数据，Timeline 编辑器将在此基础上提供更直观的拖拽式操作。
