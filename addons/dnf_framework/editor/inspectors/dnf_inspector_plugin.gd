@tool
extends EditorInspectorPlugin

## DNF 资源检查器插件
## 为 DNFAnimationData 提供帧列表 + 预览播放
## 为 DNFSkillDataV2、DNFAttackPhase、DNFHitboxData 提供支持

const AnimInspector = preload("res://addons/dnf_framework/editor/inspectors/animation_inspector.gd")

var _current_anim_inspector: Control


func _can_handle(object: Variant) -> bool:
	if object is Resource:
		return _is_dnf_resource(object)
	return false


func _parse_begin(object: Object) -> void:
	if not (object is Resource):
		return
	var script := object.get_script()
	if script == null:
		return
	var path: String = script.resource_path
	if path.contains("animation_data"):
		_current_anim_inspector = VBoxContainer.new()
		_current_anim_inspector.set_script(AnimInspector)
		_current_anim_inspector.setup(object)
		add_custom_control(_current_anim_inspector)


func _is_dnf_resource(object: Resource) -> bool:
	var script := object.get_script()
	if not script:
		return false
	var path: String = script.resource_path
	return path.contains("dnf_framework") and (
		path.contains("animation_data") or
		path.contains("skill_data_v2") or
		path.contains("attack_phase") or
		path.contains("hitbox_data")
	)
