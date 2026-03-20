@tool
extends EditorPlugin

var _inspector_plugin: EditorInspectorPlugin
var _skill_editor_panel: Control
var _character_editor_panel: Control


func _enter_tree() -> void:
	add_custom_type(
		"InputBuffer", "Node",
		preload("res://addons/dnf_framework/runtime/input/input_buffer.gd"),
		null
	)
	add_custom_type(
		"FrameCharacterBody2D", "CharacterBody2D",
		preload("res://addons/dnf_framework/runtime/physics/frame_character_body2d.gd"),
		null
	)
	add_custom_type(
		"DNFStateMachine", "Node",
		preload("res://addons/dnf_framework/runtime/character/state_machine.gd"),
		null
	)
	add_custom_type(
		"DNFHitboxComponent", "Node2D",
		preload("res://addons/dnf_framework/runtime/combat/hitbox_component.gd"),
		null
	)
	add_custom_type(
		"DNFHurtboxComponent", "Area2D",
		preload("res://addons/dnf_framework/runtime/combat/hurtbox_component.gd"),
		null
	)
	add_custom_type(
		"DNFSkillComponent", "Node",
		preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd"),
		null
	)
	add_custom_type(
		"DNFAnimatedSprite2D", "AnimatedSprite2D",
		preload("res://addons/dnf_framework/runtime/frame/animated_sprite.gd"),
		null
	)
	add_custom_type(
		"DNFAnimationPreview", "Node2D",
		preload("res://addons/dnf_framework/runtime/frame/animation_preview.gd"),
		null
	)
	add_custom_type(
		"DNFCombatManager", "Node",
		preload("res://addons/dnf_framework/runtime/combat/combat_manager.gd"),
		null
	)
	add_custom_type(
		"DNFHitbox", "Area2D",
		preload("res://addons/dnf_framework/runtime/combat/dnf_hitbox.gd"),
		null
	)
	add_custom_type(
		"DNFHurtbox", "Area2D",
		preload("res://addons/dnf_framework/runtime/combat/dnf_hurtbox.gd"),
		null
	)

	var inspector_script = load("res://addons/dnf_framework/editor/inspectors/dnf_inspector_plugin.gd")
	if inspector_script:
		_inspector_plugin = inspector_script.new()
		add_inspector_plugin(_inspector_plugin)

	var skill_editor_script = load("res://addons/dnf_framework/editor/panels/skill_editor.gd")
	if skill_editor_script:
		_skill_editor_panel = Control.new()
		_skill_editor_panel.set_script(skill_editor_script)
		_skill_editor_panel.name = "DNF 技能编辑器"
		add_control_to_bottom_panel(_skill_editor_panel, "DNF 技能")

	var char_editor_script = load("res://addons/dnf_framework/editor/panels/character_editor.gd")
	if char_editor_script:
		_character_editor_panel = Control.new()
		_character_editor_panel.set_script(char_editor_script)
		_character_editor_panel.name = "DNF 角色编辑器"
		add_control_to_bottom_panel(_character_editor_panel, "DNF 角色")


func _exit_tree() -> void:
	remove_custom_type("InputBuffer")
	remove_custom_type("FrameCharacterBody2D")
	remove_custom_type("DNFStateMachine")
	remove_custom_type("DNFHitboxComponent")
	remove_custom_type("DNFHurtboxComponent")
	remove_custom_type("DNFSkillComponent")
	remove_custom_type("DNFAnimatedSprite2D")
	remove_custom_type("DNFAnimationPreview")
	remove_custom_type("DNFCombatManager")
	remove_custom_type("DNFHitbox")
	remove_custom_type("DNFHurtbox")

	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null

	if _skill_editor_panel:
		remove_control_from_bottom_panel(_skill_editor_panel)
		_skill_editor_panel.queue_free()
		_skill_editor_panel = null

	if _character_editor_panel:
		remove_control_from_bottom_panel(_character_editor_panel)
		_character_editor_panel.queue_free()
		_character_editor_panel = null
