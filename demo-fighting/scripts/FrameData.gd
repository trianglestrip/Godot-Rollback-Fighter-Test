extends Resource
class_name FighterFrameData

# 帧数据类，用于存储每一帧的信息

# 精灵区域
@export var region : Rect2

# 该帧的hitbox列表
@export var hitboxes : Array[Dictionary]

# 该帧的事件列表
@export var events : Array[Dictionary]

# 该帧的持续时间（秒）
@export var duration : float = 1.0 / 60.0

# 该帧的音效
@export var sound : String = ""

# 该帧的特效
@export var effect : PackedScene = null

func _init():
    region = Rect2()
    hitboxes = []
    events = []
    duration = 1.0 / 60.0
    sound = ""
    effect = null
