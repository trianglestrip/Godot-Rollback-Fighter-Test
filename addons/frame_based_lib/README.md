# Frame Based Lib

一个Godot 4插件，为需要精确计时和物理计算的游戏提供基于帧的工具。

## 组件

### 1. FrameBasedTimer

一个基于帧的定时器，允许您以帧为单位设置等待时间，而不是秒。

#### 特性
- 以帧为单位设置等待时间（物理帧或空闲帧）
- 将帧时间转换为秒，便于理解
- 自动启动选项
- 单次触发模式
- 忽略时间缩放选项

#### 使用示例
```gdscript
# 创建定时器实例
var timer = FrameBasedTimer.new()
timer.wait_time_in_frames = 60  # 60个物理帧 = 60 FPS下的1秒
timer.oneshot = true
timer.timeout.connect(_on_timer_timeout)
timer.start()

func _on_timer_timeout():
    print("定时器触发！")
```

#### 属性
| 属性 | 类型 | 描述 |
|------|------|------|
| wait_time_in_frames | int | 等待的帧数 |
| wait_time_in_seconds | float | 计算出的秒级等待时间（只读） |
| shots_per_second | float | 计算出的每秒触发次数（只读） |
| autostart | bool | 是否自动启动 |
| oneshot | bool | 是否在触发一次后停止 |
| ignore_time_scale | bool | 是否忽略时间缩放 |
| process_callback | int | 使用物理帧还是空闲帧处理 |

#### 方法
| 方法 | 描述 |
|------|------|
| start(frames: int = -1) | 启动定时器，可选自定义帧数 |
| resume() | 恢复定时器 |
| pause() | 暂停定时器 |
| stop() | 停止定时器 |
| is_stopped() | 检查定时器是否已停止 |

### 2. FrameBasedCharacterBody2D

扩展了CharacterBody2D，提供基于帧的移动和碰撞检测。

#### 特性
- 基于帧的移动和碰撞
- 平台速度处理
- 墙壁和地面检测
- 地面吸附
- 斜坡上的恒定速度

#### 使用示例
```gdscript
# 在场景中使用FrameBasedCharacterBody2D替换CharacterBody2D
extends FrameBasedCharacterBody2D

func _physics_process(delta):
    # 使用f_move_and_slide()替代move_and_slide()
    f_move_and_slide()
```

#### 方法
| 方法 | 描述 |
|------|------|
| f_move_and_slide() | 基于帧计算的移动和滑动 |
| f_is_on_floor() | 检查是否在地面上 |
| f_is_on_floor_only() | 检查是否仅在地面上（不在墙壁或天花板上） |
| f_is_on_wall() | 检查是否在墙壁上 |
| f_is_on_wall_only() | 检查是否仅在墙壁上（不在地面或天花板上） |
| f_is_on_ceiling() | 检查是否在天花板上 |
| f_is_on_ceiling_only() | 检查是否仅在天花板上（不在地面或墙壁上） |
| f_get_platform_velocity() | 获取角色所在平台的速度 |

#### 内部方法
| 方法 | 描述 |
|------|------|
| _set_collision_direction(result: KinematicCollision2D) | 根据法线设置碰撞方向 |
| _set_platform_data(result: KinematicCollision2D) | 从碰撞中设置平台数据 |
| _move_and_slide_grounded(was_on_floor: bool) | 处理地面移动 |
| _move_and_slide_floating() | 处理浮动移动 |
| _snap_on_floor(was_on_floor: bool, vel_dir_facing_up: bool, wall_as_floor: bool) | 吸附到地面 |
| _apply_floor_snap(wall_as_floor: bool = false) | 应用地面吸附 |
| _on_floor_is_snapped(was_on_floor: bool, vel_dir_facing_up) | 检查是否吸附到地面 |

## 安装说明

1. 将 `frame_based_lib` 文件夹复制到项目的 `addons` 目录中
2. 在项目设置 -> 插件中启用该插件

## 使用场景

### 格斗游戏
- 精确的基于帧的动画
- 输入缓冲系统
- 碰撞盒激活时机

### 节奏游戏
- 精确的音符计时
- 帧完美的输入检测

### 平台游戏
- 精确的跳跃物理
- 基于帧的敌人AI

### 联网游戏
- 不同帧率下的一致游戏体验
- 游戏状态的轻松同步

## 如何实现类似DNF的操作

DNF（地下城与勇士）是一款经典的横版格斗游戏，以其流畅的操作和精确的打击感而闻名。要使用Frame Based Lib实现类似DNF的操作，可以参考以下方法：

### 1. 输入缓冲系统

```gdscript
# 在角色脚本中实现输入缓冲
var input_buffer := []
var buffer_size := 10  # 10帧的输入缓冲

func _process(delta):
    # 收集输入
    var current_input = {
        "punch": Input.is_action_just_pressed("punch"),
        "kick": Input.is_action_just_pressed("kick"),
        "jump": Input.is_action_just_pressed("jump"),
        "left": Input.is_action_pressed("left"),
        "right": Input.is_action_pressed("right"),
        "up": Input.is_action_pressed("up"),
        "down": Input.is_action_pressed("down")
    }
    
    # 添加到输入缓冲
    input_buffer.append(current_input)
    if input_buffer.size() > buffer_size:
        input_buffer.remove_at(0)

# 检查特定输入组合是否在缓冲中
func check_input_combination(combination):
    for input in input_buffer:
        if matches_combination(input, combination):
            return true
    return false
```

### 2. 基于帧的攻击动画

```gdscript
# 使用FrameBasedTimer控制攻击动画
var attack_timer = FrameBasedTimer.new()
attack_timer.wait_time_in_frames = 30  # 攻击动画持续30帧
attack_timer.oneshot = true
attack_timer.timeout.connect(_on_attack_finished)

func _physics_process(delta):
    if Input.is_action_just_pressed("punch") and not is_attacking:
        start_attack()

func start_attack():
    is_attacking = true
    attack_timer.start()
    # 播放攻击动画
    animation_player.play("punch")
    # 激活碰撞盒
    hitbox.activate()

func _on_attack_finished():
    is_attacking = false
    # 停止攻击动画
    animation_player.play("idle")
    # 关闭碰撞盒
    hitbox.deactivate()
```

### 3. 精确的打击判定

```gdscript
# 在碰撞盒脚本中实现精确的打击判定
func _on_Hitbox_body_entered(body):
    if body.is_in_group("enemy"):
        # 计算伤害和硬直
        var damage = calculate_damage()
        var hitstop_frames = 10  # 10帧的硬直
        
        # 应用伤害和硬直
        body.take_damage(damage)
        body.add_hitstop(hitstop_frames)
        
        # 触发攻击反馈
        spawn_hit_effect()
        play_hit_sound()
```

## 插件的不足

虽然Frame Based Lib提供了很多有用的功能，但它也有一些不足之处：

### 1. 学习曲线陡峭

基于帧的设计理念与Godot默认的基于时间的设计有所不同，需要开发者理解基于帧的游戏设计理念，学习成本较高。

### 2. 与现有系统的兼容性

该插件扩展了Godot的默认组件，但与某些第三方插件或自定义系统可能存在兼容性问题。

### 3. 缺少完整的工具链

虽然提供了基于帧的定时器和CharacterBody2D扩展，但缺少完整的工具链来支持复杂的基于帧的游戏设计，如：
- 基于帧的动画系统
- 帧级别的输入检测
- 帧同步的网络系统

### 4. 性能考虑

基于帧的设计在某些情况下可能会导致性能问题，特别是在高帧率下运行时，需要开发者注意优化。

### 5. 文档和示例不足

目前的文档和示例相对简单，对于复杂的游戏设计来说可能不够详细。

### 6. 缺少可视化编辑工具

没有提供可视化的编辑工具来调整基于帧的参数，需要手动编写代码或调整属性。

## 基于帧设计的优势

1. **一致性**：不同帧率下的游戏体验保持一致
2. **精确性**：更精确地控制游戏时序
3. **公平性**：确保所有玩家的公平游戏体验
4. **可预测性**：更容易预测游戏行为
5. **同步性**：简化网络同步

## 许可证

MIT License

## 贡献指南

欢迎提交问题和拉取请求！