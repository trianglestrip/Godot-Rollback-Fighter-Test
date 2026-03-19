extends Node
class_name FramePlayer

# 帧动画播放器，用于替代AnimationPlayer，支持帧驱动的SpriteSheet动画

# 精灵节点引用
@export var sprite : Sprite2D

# 帧数据列表
@export var frames : Array[FighterFrameData] = []

# 播放速度（倍率）
@export var speed : float = 1.0

# 是否循环播放
@export var loop : bool = true

# 是否自动播放
@export var autoplay : bool = false

# 帧速率（fps）
@export var fps : float = 60.0

# 私有变量
var _current_frame_index : int = 0
var _time_accumulator : float = 0.0
var _is_playing : bool = false
var _is_paused : bool = false
var _on_frame_complete : Callable
var _on_animation_complete : Callable

# 信号
signal frame_changed(frame_index : int)
signal animation_started()
signal animation_completed()

func _ready():
    # 自动播放检查
    if autoplay:
        play()

func _process(delta):
    if not _is_playing or _is_paused or frames.is_empty():
        return
    
    # 计算累积时间
    _time_accumulator += delta * speed
    
    # 计算当前帧
    var frame_duration : float = frames[_current_frame_index].duration
    if _time_accumulator >= frame_duration:
        # 消耗当前帧时间
        _time_accumulator -= frame_duration
        
        # 移动到下一帧
        _current_frame_index += 1
        
        # 检查动画是否结束
        if _current_frame_index >= frames.size():
            if loop:
                # 循环播放
                _current_frame_index = 0
            else:
                # 停止播放
                _current_frame_index = frames.size() - 1
                stop()
                emit_signal("animation_completed")
                if _on_animation_complete:
                    _on_animation_complete.call()
                return
        
        # 应用当前帧
        apply_current_frame()
        
        # 触发帧变化信号
        emit_signal("frame_changed", _current_frame_index)
        if _on_frame_complete:
            _on_frame_complete.call(_current_frame_index)

func play():
    # 开始播放动画
    _is_playing = true
    _is_paused = false
    emit_signal("animation_started")
    apply_current_frame()

func pause():
    # 暂停动画
    _is_paused = true

func resume():
    # 恢复播放
    _is_paused = false

func stop():
    # 停止播放并重置到第一帧
    _is_playing = false
    _is_paused = false
    _current_frame_index = 0
    _time_accumulator = 0.0
    apply_current_frame()

func restart():
    # 重新开始播放
    stop()
    play()

func jump_to_frame(frame_index : int):
    # 跳转到指定帧
    if frame_index >= 0 and frame_index < frames.size():
        _current_frame_index = frame_index
        _time_accumulator = 0.0
        apply_current_frame()
        emit_signal("frame_changed", _current_frame_index)
        if _on_frame_complete:
            _on_frame_complete.call(_current_frame_index)

func apply_current_frame():
    # 应用当前帧的数据
    if frames.is_empty() or _current_frame_index < 0 or _current_frame_index >= frames.size():
        return
    
    var frame_data : FighterFrameData = frames[_current_frame_index]
    
    # 更新精灵区域
    if sprite:
        sprite.region_rect = frame_data.region
    
    # 触发帧事件
    trigger_frame_events(frame_data)
    
    # 播放帧音效
    if frame_data.sound != "":
        # 这里可以替换为你的音效播放系统
        # SyncManager.play_sound("frame_sound", frame_data.sound) - 暂时注释，等待SyncManager正确引用
        pass
    
    # 生成帧特效
    if frame_data.effect:
        var effect_instance = frame_data.effect.instantiate()
        if sprite:
            effect_instance.global_position = sprite.global_position
        # SyncManager.spawn("frame_effect", effect_instance) - 暂时注释，等待SyncManager正确引用

func trigger_frame_events(frame_data : FighterFrameData):
    # 触发帧事件
    for event in frame_data.events:
        match event["type"]:
            "hitbox":
                # 触发hitbox事件
                emit_signal("hitbox_event", event["data"])
            "state":
                # 触发状态变化事件
                emit_signal("state_event", event["data"])
            "movement":
                # 触发移动事件
                emit_signal("movement_event", event["data"])
            "custom":
                # 触发自定义事件
                emit_signal("custom_event", event["name"], event["data"])

# 设置回调函数
func set_on_frame_complete(callback : Callable):
    _on_frame_complete = callback

func set_on_animation_complete(callback : Callable):
    _on_animation_complete = callback

# 获取当前状态
func is_playing() -> bool:
    return _is_playing

func is_paused() -> bool:
    return _is_paused

func get_current_frame() -> int:
    return _current_frame_index

func get_total_frames() -> int:
    return frames.size()

# 加载帧数据
func load_frames_from_sprite_sheet(sprite_sheet : Texture2D, frame_width : int, frame_height : int, start_x : int = 0, start_y : int = 0, frame_count : int = -1):
    # 从SpriteSheet加载帧数据
    var texture_width = sprite_sheet.get_width()
    var texture_height = sprite_sheet.get_height()
    
    # 计算帧数
    var total_frames = (texture_width - start_x) / frame_width * (texture_height - start_y) / frame_height
    if frame_count > 0 and frame_count < total_frames:
        total_frames = frame_count
    
    # 创建帧数据
    frames.clear()
    var index : int = 0
    var y : int = start_y
    
    while index < total_frames and y < texture_height:
        var x : int = start_x
        while index < total_frames and x < texture_width:
            var frame_data = FighterFrameData.new()
            frame_data.region = Rect2(x, y, frame_width, frame_height)
            frames.append(frame_data)
            
            x += frame_width
            index += 1
        y += frame_height
    
    # 更新精灵纹理
    if sprite:
        sprite.texture = sprite_sheet
        sprite.region_enabled = true

func load_frames_from_dict(frame_dict : Dictionary):
    # 从字典加载帧数据
    frames.clear()
    for frame_data_dict in frame_dict.get("frames", []):
        var frame_data = FighterFrameData.new()
        frame_data.region = Rect2(frame_data_dict.get("x", 0), frame_data_dict.get("y", 0), 
                                 frame_data_dict.get("width", 0), frame_data_dict.get("height", 0))
        frame_data.hitboxes = frame_data_dict.get("hitboxes", [])
        frame_data.events = frame_data_dict.get("events", [])
        frame_data.duration = frame_data_dict.get("duration", 1.0 / 60.0)
        frame_data.sound = frame_data_dict.get("sound", "")
        # 注意：effect需要特殊处理，这里简化处理
        frames.append(frame_data)
