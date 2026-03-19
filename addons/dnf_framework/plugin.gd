@tool
extends EditorPlugin


func _enter_tree() -> void:
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


func _exit_tree() -> void:
	remove_custom_type("FrameAnimationPlayer")
	remove_custom_type("InputBuffer")
	remove_custom_type("FrameCharacterBody2D")
	remove_custom_type("DNFStateMachine")
	remove_custom_type("DNFSkillComponent")
