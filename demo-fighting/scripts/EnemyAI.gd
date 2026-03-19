extends Node
class_name EnemyAI

# 简单的敌人AI，能自动移动和攻击

var enemy : Fighter

var current_state : String = "idle"

# AI参数
var detection_range : float = 200.0
var attack_range : float = 80.0
var attack_cooldown : float = 1.0
var last_attack_time : float = 0.0

func _ready():
    enemy = get_parent()
    if not enemy or not enemy is Fighter:
        queue_free()
        return
    
    # 设置为敌人
    enemy.set_as_enemy()
    
    # 将AI添加到游戏的网络处理流程中
    add_to_group("enemy_ai")

func _network_process():
    if not enemy or enemy.health <= 0:
        queue_free()
        return

    # 检查玩家是否存在
    var player = enemy.target_fighter
    if not player or player.health <= 0:
        current_state = "idle"
        return

    # 更新AI状态
    update_state(player)
    
    # 执行当前状态
    match current_state:
        "idle":
            handle_idle()
        "chase":
            handle_chase(player)
        "attack":
            handle_attack(player)
        "retreat":
            handle_retreat(player)

func update_state(player : Fighter):
    # 计算到玩家的距离
    var distance = enemy.global_position.distance_to(player.global_position)
    
    # 根据距离更新状态
    match current_state:
        "idle":
            if distance <= detection_range:
                current_state = "chase"
        "chase":
            if distance <= attack_range:
                current_state = "attack"
            elif distance > detection_range:
                current_state = "idle"
        "attack":
            if distance > attack_range:
                current_state = "chase"
        "retreat":
            if distance > attack_range:
                current_state = "chase"

func handle_idle():
    # 空闲状态：什么都不做
    enemy.input_dict = {"x_axis": 0, "y_axis": 0}

func handle_chase(player : Fighter):
    # 追逐状态：向玩家移动
    var direction = (player.global_position - enemy.global_position).normalized()
    var input_dict = {}
    
    # 设置方向输入
    if direction.x > 0.3:
        input_dict["x_axis"] = 1
    elif direction.x < -0.3:
        input_dict["x_axis"] = -1
    else:
        input_dict["x_axis"] = 0
    
    if direction.y > 0.3:
        input_dict["y_axis"] = 1
    elif direction.y < -0.3:
        input_dict["y_axis"] = -1
    else:
        input_dict["y_axis"] = 0
    
    enemy.input_dict = input_dict
    enemy.input_process()

func handle_attack(player : Fighter):
    # 攻击状态：攻击玩家
    var now = Time.get_time_dict_from_system().unix
    if now - last_attack_time >= attack_cooldown:
        # 简单的攻击逻辑：随机选择拳或脚
        var input_dict = {"x_axis": 0, "y_axis": 0}
        
        # 随机选择攻击方式
        var attack_type = randi() % 2
        if attack_type == 0:
            input_dict["punch"] = true
        else:
            input_dict["kick"] = true
        
        enemy.input_dict = input_dict
        enemy.input_process()
        last_attack_time = now
    else:
        # 攻击冷却中，继续移动
        handle_chase(player)

func handle_retreat(player : Fighter):
    # 撤退状态：远离玩家
    var direction = (enemy.global_position - player.global_position).normalized()
    var input_dict = {}
    
    # 设置方向输入
    if direction.x > 0.3:
        input_dict["x_axis"] = 1
    elif direction.x < -0.3:
        input_dict["x_axis"] = -1
    else:
        input_dict["x_axis"] = 0
    
    if direction.y > 0.3:
        input_dict["y_axis"] = 1
    elif direction.y < -0.3:
        input_dict["y_axis"] = -1
    else:
        input_dict["y_axis"] = 0
    
    enemy.input_dict = input_dict
    enemy.input_process()
