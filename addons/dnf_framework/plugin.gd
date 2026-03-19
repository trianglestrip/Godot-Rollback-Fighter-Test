@tool
extends EditorPlugin


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
