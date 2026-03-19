@tool
extends RefCounted

## 碰撞体预设模板 — 提供常用 hitbox 配置

const HitboxData = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")


## 获取所有模板名称
static func get_template_names() -> Array[String]:
	return [
		"前方横斩",
		"前方刺击",
		"周围范围",
		"上方打击",
		"下段扫腿",
		"弹道碰撞"
	]


## 获取模板字典（名称 -> DNFHitboxData）
static func get_templates() -> Dictionary:
	return {
		"前方横斩": _create_hitbox_static(Vector2(80, 60), Vector2(40, 0), HitboxData.HitLevel.MID),
		"前方刺击": _create_hitbox_static(Vector2(100, 30), Vector2(50, 0), HitboxData.HitLevel.MID),
		"周围范围": _create_hitbox_static(Vector2(120, 120), Vector2(0, 0), HitboxData.HitLevel.MID),
		"上方打击": _create_hitbox_static(Vector2(60, 80), Vector2(20, -40), HitboxData.HitLevel.OVERHEAD),
		"下段扫腿": _create_hitbox_static(Vector2(90, 30), Vector2(45, 30), HitboxData.HitLevel.LOW),
		"弹道碰撞": _create_hitbox_static(Vector2(20, 20), Vector2(0, 0), HitboxData.HitLevel.MID)
	}


## 根据模板名创建新的 DNFHitboxData 实例
static func create_from_template(name: String) -> Resource:
	var templates := get_templates()
	if not templates.has(name):
		return null
	var src: Resource = templates[name]
	var dup := src.duplicate()
	return dup


static func _create_hitbox_static(shape_size: Vector2, offset: Vector2, hit_level: HitboxData.HitLevel) -> Resource:
	var h := HitboxData.new()
	h.shape_size = shape_size
	h.offset = offset
	h.hit_level = hit_level
	return h
