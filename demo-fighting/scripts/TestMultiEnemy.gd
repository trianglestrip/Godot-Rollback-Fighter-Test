extends Node2D
class_name TestMultiEnemy

# 多敌人测试脚本

@export var enemy_scene : PackedScene
@export var spawn_positions : Array[Vector2] = [
    Vector2(200, 0),
    Vector2(300, 50),
    Vector2(400, -50),
    Vector2(500, 0),
    Vector2(600, 50)
]

@onready var enemy_manager = preload("res://demo-fighting/scripts/EnemyManager.gd").new()

func _ready():
    # 添加敌人管理器
    add_child(enemy_manager)
    enemy_manager.enemy_scene = enemy_scene
    
    # 生成初始敌人
    spawn_initial_enemies()
    
    # 添加调试输入
    InputMap.add_action("spawn_enemy", 0)
    InputMap.add_action("clear_enemies", 0)
    
    # 设置键盘快捷键
    var event1 = InputEventKey.new()
    event1.keycode = KEY_SPACE
    InputMap.action_add_event("spawn_enemy", event1)
    
    var event2 = InputEventKey.new()
    event2.keycode = KEY_C
    event2.ctrl_pressed = true
    InputMap.action_add_event("clear_enemies", event2)

func _process(delta):
    # 调试输入处理
    if Input.is_action_just_pressed("spawn_enemy"):
        spawn_random_enemy()
    
    if Input.is_action_just_pressed("clear_enemies"):
        clear_all_enemies()

func spawn_initial_enemies():
    # 生成初始的3个敌人
    enemy_manager.spawn_multiple_enemies(3, spawn_positions)

func spawn_random_enemy():
    # 在随机位置生成敌人
    var random_pos = spawn_positions[randi() % spawn_positions.size()]
    enemy_manager.spawn_enemy(random_pos)

func clear_all_enemies():
    # 清除所有敌人
    enemy_manager.despawn_all_enemies()

func _input(event):
    # 调试输出
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_F1:
            print("敌人数量: ", enemy_manager.enemies.size())
        elif event.keycode == KEY_F2:
            for i in range(enemy_manager.enemies.size()):
                var enemy = enemy_manager.enemies[i]
                print("敌人", i, ": 位置=", enemy.global_position, ", 生命值=", enemy.health)
