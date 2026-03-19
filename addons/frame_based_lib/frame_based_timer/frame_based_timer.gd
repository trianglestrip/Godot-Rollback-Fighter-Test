@icon("res://addons/frame_based_lib/frame_based_timer/icon.svg")
@tool
class_name FrameBasedTimer
extends Node

signal timeout

@export_enum("Idle", "Physics") var process_callback: int = 0
@export var wait_time_in_frames: int:
      set = set_wait_time_in_frames
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY) var wait_time_in_seconds: float:
      get = get_wait_time_in_seconds
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY) var shots_per_second: float:
      get = get_shots_per_second
@export var autostart: bool = false
@export var oneshot: bool = false
@export var ignore_time_scale: bool = false

var _remaining_frames: int = -1


func _ready() -> void:
      set_process(false)
      set_physics_process(false)
      if Engine.is_editor_hint():
            return
      if autostart == true:
            start()


func _notification(what: int) -> void:
      if what != NOTIFICATION_PHYSICS_PROCESS and what != NOTIFICATION_PROCESS:
            return
      if not is_processing() and not is_physics_processing():
            return
      _remaining_frames -= 1
      if _remaining_frames <= 0:
            if oneshot == true:
                  set_physics_process(false)
                  set_process(false)
            else:
                  _remaining_frames = wait_time_in_frames
            timeout.emit()


func start(frames: int = -1) -> void:
      if frames < 0:
            _remaining_frames = wait_time_in_frames
      else:
            _remaining_frames = frames
      set_physics_process(true) if process_callback == 0 else set_process(true)


func resume() -> void:
      set_physics_process(true) if process_callback == 0 else set_process(true)


func pause() -> void:
      set_physics_process(false)
      set_process(false)


func stop() -> void:
      set_physics_process(false)
      set_process(false)
      _remaining_frames = -1


func is_stopped() -> bool:
      return not is_physics_processing() and not is_processing()


func set_wait_time_in_frames(val: int) -> void:
      if wait_time_in_frames == val:
            return
      wait_time_in_frames = max(0, val)
      notify_property_list_changed()


func get_wait_time_in_seconds() -> float:
      if wait_time_in_frames == 0:
            return 0.0
      return wait_time_in_frames as float / ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)


func get_shots_per_second() -> float:
      if wait_time_in_seconds == 0:
            return 0.0
      return 1.0 / wait_time_in_seconds
