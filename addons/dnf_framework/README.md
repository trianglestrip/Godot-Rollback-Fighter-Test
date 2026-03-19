# DNF Framework

Godot 4 插件，用于开发 DNF（地下城与勇士）风格的格斗游戏。提供帧确定性的动画、物理、状态机、受击碰撞和招式取消系统。

## 核心组件

### 基础层

| 组件 | 路径 | 说明 |
|------|------|------|
| `FrameAnimationPlayer` | `frame_animation/scripts/` | 帧计数驱动的动画播放器（非 delta） |
| `InputBuffer` | `frame_input/scripts/` | 帧计数的输入缓冲、连招检测、指令输入历史 |
| `FrameCharacterBody2D` | `frame_physics/scripts/` | 帧驱动的 2D 物理角色（velocity 直接作为每帧位移） |

### 状态机层

| 组件 | 路径 | 说明 |
|------|------|------|
| `DNFStates` | `state_machine/scripts/dnf_states.gd` | 核心状态枚举（IDLE/WALK/RUN/JUMP/ATTACK/HIT_STUN/KNOCK_DOWN 等） |
| `DNFCharacter` | `state_machine/scripts/dnf_character.gd` | 角色基类，集成状态机 + 受击 + 招式取消 |
| `DNFStateMachine` | `state_machine/scripts/state_machine.gd` | 资源驱动的通用状态机（tick 推进 + 状态事件） |
| `DNFFighterState` | `state_machine/scripts/fighter_state.gd` | 状态定义（Resource），含事件列表 |
| `DNFStateEvent` | `state_machine/scripts/state_event.gd` | 状态事件基类 |
| `DNFStateTransitionEvent` | `state_machine/scripts/state_transition_event.gd` | 状态切换事件 |

### 战斗层

| 组件 | 路径 | 说明 |
|------|------|------|
| `DNFHitbox` | `combat/scripts/dnf_hitbox.gd` | 攻击判定框（Area2D） |
| `DNFHurtbox` | `combat/scripts/dnf_hurtbox.gd` | 受击判定框（Area2D） |
| `DNFHitBehavior` | `combat/scripts/hit_behavior.gd` | 受击行为资源（伤害/硬直/击退/击飞/顿帧） |
| `DNFCombatManager` | `combat/scripts/combat_manager.gd` | 战斗管理器，统一碰撞检测和伤害结算 |
| `DNFHitboxActivationEvent` | `combat/scripts/hitbox_activation_event.gd` | 在帧范围内激活/关闭 Hitbox |
| `DNFHurtboxActivationEvent` | `combat/scripts/hurtbox_activation_event.gd` | 在帧范围内激活/关闭 Hurtbox |

### 招式层

| 组件 | 路径 | 说明 |
|------|------|------|
| `DNFMove` | `move_system/scripts/move.gd` | 招式定义（输入条件 + 帧数据 + 受击行为） |
| `DNFInputType` | `move_system/scripts/input_type.gd` | 输入条件基类 |
| `DNFInputEqualCheck` | `move_system/scripts/input_equal_check.gd` | 简单键值匹配检查 |
| `DNFCommandMotionInput` | `move_system/scripts/command_motion_input.gd` | 指令输入检测（QCF/DP 等） |
| `DNFCancelListEvent` | `move_system/scripts/cancel_list_event.gd` | 在帧范围内开放取消窗口 |

## 状态系统

DNFCharacter 内置以下状态，自动处理切换逻辑：

```
基本状态: IDLE, WALK, RUN, JUMP, FALL, LAND, DASH, BACK_DASH
攻击状态: ATTACK, SKILL
受击状态: HIT_STUN, KNOCK_BACK, KNOCK_DOWN, AIR_BORNE, GET_UP
防御状态: BLOCK, GUARD_BREAK
```

受击类型和对应表现：

| HitType | 状态 | 表现 |
|---------|------|------|
| NORMAL | HIT_STUN | 原地硬直 + 轻微击退 |
| KNOCK_BACK | KNOCK_BACK | 向后击退滑行 |
| KNOCK_DOWN | KNOCK_DOWN | 倒地 → GET_UP |
| LAUNCH | AIR_BORNE | 击飞到空中 → KNOCK_DOWN → GET_UP |

## 快速上手

### 1. 创建角色

```gdscript
extends DNFCharacter

@export var input_prefix: String = "player1_"

func _get_move_direction() -> float:
    var dir := 0.0
    if Input.is_action_pressed(input_prefix + "right"):
        dir += 1.0
    if Input.is_action_pressed(input_prefix + "left"):
        dir -= 1.0
    return dir

func _is_jump_pressed() -> bool:
    return Input.is_action_just_pressed(input_prefix + "up")
```

### 2. 设置攻击

```gdscript
func _ready():
    var hit := DNFHitBehavior.new()
    hit.damage = 10
    hit.hit_type = DNFHitBehavior.HitType.NORMAL
    hit.hitstun_frames = 15
    hit.hitstop_frames = 4
    hit.knockback_force = 4.0

    var cond := DNFInputEqualCheck.new()
    cond.input_name = "punch"
    cond.input_value = true

    var move := DNFMove.new()
    move.move_name = "light_attack"
    move.input_conditions = [cond]
    move.duration = 18
    move.active_start = 4
    move.active_end = 8
    move.hit_behavior = hit

    available_moves = [move]
```

### 3. 设置连段取消

在 `_state_process()` 中根据当前招式和帧数设置取消窗口：

```gdscript
if _current_move.move_name == "light_attack":
    if state_tick >= 8 and state_tick < 16:
        available_cancels = ["heavy_attack"]
```

### 4. 场景配置

- 角色节点需要 `CollisionShape2D`
- 添加 `DNFHitbox`（Area2D）子节点作为攻击判定
- 添加 `DNFHurtbox`（Area2D）子节点作为受击判定
- Hitbox 放入 `dnf_hitbox` 组，Hurtbox 放入 `dnf_hurtbox` 组
- 场景中添加 `DNFCombatManager` 节点统一处理碰撞检测

## 示例

| 示例 | 路径 | 演示内容 |
|------|------|----------|
| Phase 1 | `examples/phase1_basic/` | 基础行走/跳跃/帧动画 |
| Phase 2 | `examples/phase2_states/` | 状态机切换 (IDLE/WALK/RUN/JUMP/FALL/LAND/DASH) |
| Phase 3 | `examples/phase3_combat/` | 攻击/受击 (硬直/击退/击飞) |
| Phase 4 | `examples/phase4_moves/` | 招式系统 + 连段取消 |
| Phase 5 | `examples/phase5_full/` | 完整双人对战 |

## 设计原则

- **帧确定性**：所有系统基于帧计数而非 delta 时间，可用于回滚网络
- **模块化**：每个系统可独立使用，也可组合
- **资源驱动**：状态、招式、受击行为使用 Godot Resource，支持编辑器配置
- **回滚友好**：所有核心组件提供 `_save_state()` / `_load_state()` 方法

## 安装

1. 复制 `addons/dnf_framework/` 到项目的 `addons/` 目录
2. 在项目设置 -> 插件中启用 "DNF Framework"
3. 重启编辑器

## 许可证

MIT
