@tool
extends EditorInspectorPlugin

## DNF 资源检查器插件 — 为 DNFSkillDataV2、DNFAttackPhase、DNFHitboxData 提供支持


func _can_handle(object: Variant) -> bool:
	if object is Resource:
		return _is_dnf_resource(object)
	return false


func _is_dnf_resource(object: Resource) -> bool:
	var script := object.get_script()
	if not script:
		return false
	var path: String = script.resource_path
	return path.contains("dnf_framework") and (
		path.contains("skill_data_v2") or
		path.contains("attack_phase") or
		path.contains("hitbox_data")
	)
