class_name DNFCharacterData
extends Resource

## 角色总入口 — 绑定 Atlas、动画、技能、属性

@export_group("基本信息")
@export var character_name: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D

@export_group("图形")
@export var atlas: Texture2D
@export var animations: Dictionary = {}  # String → DNFAnimationData

@export_group("技能")
@export var skills: Array = []  # Array of DNFSkillDataV2

@export_group("属性")
@export var stats: Resource  # DNFCharacterStats


func get_animation(anim_name: String):
	return animations.get(anim_name)


func get_skill_by_name(p_skill_name: String):
	for skill in skills:
		if skill.skill_name == p_skill_name:
			return skill
	return null
