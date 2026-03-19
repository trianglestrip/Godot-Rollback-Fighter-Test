# 修复敌人AI脚本
# 此脚本用于将EnemyAI添加到ClientPlayer节点上，让右侧角色能够自动AI移动

@tool
extends Node

func _ready() -> void:
	# 查找ClientPlayer节点
	var client_player = get_node_or_null("/root/Main/ClientPlayer")
	if not client_player:
		print("无法找到ClientPlayer节点")
		return
	
	# 检查是否已经有EnemyAI节点
	var enemy_ai = client_player.get_node_or_null("EnemyAI")
	if enemy_ai:
		print("ClientPlayer节点上已经有EnemyAI节点")
		return
	
	# 加载EnemyAI脚本
	var enemy_ai_script = load("res://demo-fighting/scripts/EnemyAI.gd")
	if not enemy_ai_script:
		print("无法加载EnemyAI脚本")
		return
	
	# 创建EnemyAI节点并添加到ClientPlayer上
	var ai_node = Node.new()
	ai_node.name = "EnemyAI"
	ai_node.script = enemy_ai_script
	client_player.add_child(ai_node)
	
	print("已成功将EnemyAI添加到ClientPlayer节点上")
	print("右侧角色现在将自动AI移动")