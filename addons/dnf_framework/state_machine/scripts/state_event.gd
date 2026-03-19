class_name DNFStateEvent
extends Resource

## 状态事件基类，在指定帧范围内触发

## 事件激活的帧范围 [start, end)，-1 表示无限制
@export var tick_range: Vector2i = Vector2i(0, -1)

## 是否仅在进入范围的第一帧触发（而非每帧都触发）
@export var once: bool = false

var _has_fired: bool = false


func should_activate(tick: int) -> bool:
	var in_range := tick >= tick_range.x and (tick_range.y < 0 or tick < tick_range.y)
	if not in_range:
		_has_fired = false
		return false
	if once and _has_fired:
		return false
	_has_fired = true
	return true


func activate(fighter: Node, _tick: int) -> void:
	pass


func reset() -> void:
	_has_fired = false
