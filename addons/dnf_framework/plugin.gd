@tool
extends EditorPlugin

var _inspector_plugin: EditorInspectorPlugin
var _timeline_panel: Control
var _skill_editor_panel: Control
var _character_editor_panel: Control


func _enter_tree() -> void:
	# Phase 1-5 原有组件
	add_custom_type(
		"FrameAnimationPlayer", "Node",
		preload("res://addons/dnf_framework/frame_animation/scripts/frame_animation_player.gd"),
		null
	)
	add_custom_type(
		"InputBuffer", "Node",
		preload("res://addons/dnf_framework/frame_input/scripts/input_buffer.gd"),
		null
	)
	add_custom_type(
		"FrameCharacterBody2D", "CharacterBody2D",
		preload("res://addons/dnf_framework/frame_physics/scripts/frame_character_body2d.gd"),
		null
	)
	add_custom_type(
		"DNFStateMachine", "Node",
		preload("res://addons/dnf_framework/state_machine/scripts/state_machine.gd"),
		null
	)
	add_custom_type(
		"DNFSkillComponent", "Node",
		preload("res://addons/dnf_framework/skill_system/scripts/skill_component.gd"),
		null
	)

	# Phase 6 新组件
	add_custom_type(
		"DNFFramePlayer", "Node",
		preload("res://addons/dnf_framework/runtime/frame/frame_player.gd"),
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
		"DNFSkillComponentV2", "Node",
		preload("res://addons/dnf_framework/runtime/skill/skill_component_v2.gd"),
		null
	)

	# Phase 10-11: 编辑器面板
	var inspector_script = load("res://addons/dnf_framework/editor/inspectors/dnf_inspector_plugin.gd")
	if inspector_script:
		_inspector_plugin = inspector_script.new()
		add_inspector_plugin(_inspector_plugin)

	var timeline_script = load("res://addons/dnf_framework/editor/timeline/timeline_root.gd")
	if timeline_script:
		_timeline_panel = Control.new()
		_timeline_panel.set_script(timeline_script)
		_timeline_panel.name = "DNF Timeline"
		add_control_to_bottom_panel(_timeline_panel, "DNF Timeline")

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
	remove_custom_type("FrameAnimationPlayer")
	remove_custom_type("InputBuffer")
	remove_custom_type("FrameCharacterBody2D")
	remove_custom_type("DNFStateMachine")
	remove_custom_type("DNFSkillComponent")
	remove_custom_type("DNFFramePlayer")
	remove_custom_type("DNFHitboxComponent")
	remove_custom_type("DNFHurtboxComponent")
	remove_custom_type("DNFSkillComponentV2")

	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null

	if _timeline_panel:
		remove_control_from_bottom_panel(_timeline_panel)
		_timeline_panel.queue_free()
		_timeline_panel = null

	if _skill_editor_panel:
		remove_control_from_bottom_panel(_skill_editor_panel)
		_skill_editor_panel.queue_free()
		_skill_editor_panel = null

	if _character_editor_panel:
		remove_control_from_bottom_panel(_character_editor_panel)
		_character_editor_panel.queue_free()
		_character_editor_panel = null
