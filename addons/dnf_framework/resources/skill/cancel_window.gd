class_name DNFCancelWindow
extends Resource

## 取消窗口 — 定义技能可被取消的帧区间及目标

## 窗口开始帧
@export var start_frame: int = 0
## 窗口结束帧
@export var end_frame: int = 5
## 可取消到的技能名列表（空 = 允许任何可用技能）
@export var allowed_skills: Array[String] = []
## 是否仅在命中后才可取消
@export var on_hit_only: bool = false


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame


func is_skill_allowed(skill_name: String) -> bool:
	if allowed_skills.is_empty():
		return true
	return skill_name in allowed_skills
