extends Node2D
class_name EnemyManager

# 敌人管理器：管理多个敌人的生成、状态和回收

@export var enemy_scene : PackedScene
@export var max_enemies : int = 5

var enemies : Array[Fighter] = []
var player : Fighter

func _ready():
    # 查找玩家
    player = get_tree().get_first_node_in_group("player")
    if not player:
        # 如果没有player组，使用第一个fighter
        var fighters = get_tree().get_nodes_in_group("fighter")
        if fighters.size() > 0:
            player = fighters[0]
    
    # 初始化敌人组
    add_to_group("enemy_manager")

func spawn_enemy(position : Vector2):
    # 生成单个敌人
    if enemies.size() >= max_enemies:
        return null
    
    var enemy = enemy_scene.instantiate() as Fighter
    enemy.position = position
    enemy.input_prefix = "enemy_" + str(enemies.size())
    enemy.set_as_enemy()
    
    # 设置敌人的目标为玩家
    if player:
        enemy.target_fighter = player
    
    add_child(enemy)
    enemies.append(enemy)
    
    return enemy

func spawn_multiple_enemies(count : int, positions : Array[Vector2]):
    # 生成多个敌人
    var spawned = []
    for i in range(min(count, positions.size())):
        var enemy = spawn_enemy(positions[i])
        if enemy:
            spawned.append(enemy)
    return spawned

func despawn_enemy(enemy : Fighter):
    # 移除并销毁敌人
    if enemy in enemies:
        enemies.erase(enemy)
        enemy.queue_free()

func despawn_all_enemies():
    # 移除所有敌人
    for enemy in enemies.duplicate():
        despawn_enemy(enemy)

func get_enemies_in_range(position : Vector2, range : float) -> Array[Fighter]:
    # 获取指定范围内的敌人
    var result = []
    for enemy in enemies:
        if enemy.global_position.distance_to(position) <= range:
            result.append(enemy)
    return result

func update_player_reference(new_player : Fighter):
    # 更新玩家引用
    player = new_player
    for enemy in enemies:
        enemy.target_fighter = new_player

func _process(delta):
    # 移除已死亡的敌人
    for enemy in enemies.duplicate():
        if enemy.health <= 0:
            despawn_enemy(enemy)
