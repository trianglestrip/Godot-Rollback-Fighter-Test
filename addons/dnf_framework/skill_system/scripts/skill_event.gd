class_name DNFSkillEvent
extends Resource

## 技能帧事件基类，在技能执行期间的指定帧触发

## 事件激活的帧范围 [start, end)，end 为 -1 表示持续到技能结束
@export var frame_range: Vector2i = Vector2i(0, -1)

## 是否仅在进入帧范围的第一帧触发
@export var once: bool = false

var _has_fired: bool = false


func should_activate(frame: int) -> bool:
	var in_range := frame >= frame_range.x and (frame_range.y < 0 or frame < frame_range.y)
	if not in_range:
		_has_fired = false
		return false
	if once and _has_fired:
		return false
	_has_fired = true
	return true


func activate(_fighter: Node, _frame: int) -> void:
	pass


func deactivate(_fighter: Node) -> void:
	pass


func reset() -> void:
	_has_fired = false
