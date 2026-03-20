class_name DNFCharacterData
extends Resource

## 角色总入口 — 绑定 SpriteFrames、技能、属性

@export_group("基本信息")
## 角色内部名称（唯一标识）
@export var character_name: String = ""
## 角色显示名称
@export var display_name: String = ""
## 角色立绘
@export var portrait: Texture2D

@export_group("图形资源")
## 角色精灵图集（原生 SpriteFrames，包含所有动画）
@export var sprite_frames: SpriteFrames

@export_group("技能列表")
## 角色拥有的技能（DNFSkillData）
@export var skills: Array = []

@export_group("角色属性")
## 角色属性数据（DNFCharacterStats）
@export var stats: Resource


func get_skill_by_name(p_skill_name: String):
	for skill in skills:
		if skill.skill_name == p_skill_name:
			return skill
	return null
