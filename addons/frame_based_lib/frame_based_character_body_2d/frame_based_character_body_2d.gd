@icon("res://addons/frame_based_lib/frame_based_character_2D/icon.svg")
extends CharacterBody2D

class_name FrameBasedCharacterBody2D

const _FLOOR_ANGLE_THRESHOLD := 0.01

var _platform_rid: RID
var _platform_layer: int
var _platform_object_id: int
var _platform_velocity: Vector2

var _motion_results: Array[KinematicCollision2D] = []
var _last_motion: Vector2 = Vector2.ZERO
var _floor_normal := Vector2.ZERO
var _wall_normal := Vector2.ZERO

var _on_floor := false
var _on_wall := false
var _on_ceiling := false
var _previous_position: Vector2


func _notification(what: int) -> void:
      match what:
            NOTIFICATION_ENTER_TREE:
                  _platform_rid = RID()


func f_move_and_slide() -> bool:
      var current_platform_velocity := f_get_platform_velocity()
      var gt := get_global_transform()
      _previous_position = gt.get_origin()
      if (_on_floor or _on_wall) && _platform_rid.is_valid():
            var excluded := false
            if _on_floor == true:
                  excluded = (platform_floor_layers & _platform_layer) == 0
            elif _on_wall == true:
                  excluded = (platform_wall_layers & _platform_layer) == 0
            if excluded == true:
                  current_platform_velocity = Vector2.ZERO
            else:
                  var body_state := PhysicsServer2D.body_get_direct_state(_platform_rid)
                  if body_state != null:
                        var local_position := gt.get_origin()
                        current_platform_velocity = body_state.get_velocity_at_local_position(local_position)
                  else:
                        current_platform_velocity = Vector2.ZERO
                        _platform_rid = RID()
      _motion_results.clear()
      _last_motion = Vector2.ZERO

      var was_on_floor := _on_floor
      _on_floor = false
      _on_wall = false
      _on_ceiling = false

      if not current_platform_velocity.is_zero_approx():
            PhysicsServer2D.body_add_collision_exception(get_rid(), _platform_rid)

            var floor_result := move_and_collide(current_platform_velocity, false, safe_margin, true)
            if floor_result != null:
                  _motion_results.push_back(floor_result)
                  _set_collision_direction(floor_result)

      if motion_mode == MOTION_MODE_GROUNDED:
            _move_and_slide_grounded(was_on_floor)
      else:
            _move_and_slide_floating()

      if platform_on_leave != PLATFORM_ON_LEAVE_DO_NOTHING:
            if _on_floor == false and _on_wall == false:
                  if platform_on_leave == PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY and current_platform_velocity.dot(up_direction) < 0:
                        current_platform_velocity = current_platform_velocity.slide(up_direction)
                  velocity += current_platform_velocity

      return _motion_results.size() > 0


func f_is_on_floor() -> bool:
      return _on_floor


func f_is_on_floor_only() -> bool:
      return _on_floor and not _on_wall and not _on_ceiling


func f_is_on_wall() -> bool:
      return _on_wall


func f_is_on_wall_only() -> bool:
      return not _on_floor and _on_wall and not _on_ceiling


func f_is_on_ceiling() -> bool:
      return _on_ceiling


func f_is_on_ceiling_only() -> bool:
      return not _on_floor and not _on_wall and _on_ceiling


func f_get_platform_velocity() -> Vector2:
      return _platform_velocity


func _set_collision_direction(result: KinematicCollision2D) -> void:
      if motion_mode == MOTION_MODE_GROUNDED and result.get_angle(up_direction) <= floor_max_angle + _FLOOR_ANGLE_THRESHOLD:
            _on_floor = true
            _floor_normal = result.get_normal()
            _set_platform_data(result)
      elif motion_mode == MOTION_MODE_GROUNDED and result.get_angle(-up_direction) <= floor_max_angle + _FLOOR_ANGLE_THRESHOLD:
            _on_ceiling = true
      else:
            _on_wall = true
            _wall_normal = result.get_normal()
            if result.get_collider() == null:
                  _set_platform_data(result)


func _set_platform_data(result: KinematicCollision2D) -> void:
      var body_state := PhysicsServer2D.body_get_direct_state(result.get_collider())
      if body_state == null:
            return
      _platform_rid = result.get_collider()
      _platform_object_id = result.get_collider_id()
      _platform_velocity = result.get_collider_velocity()
      _platform_layer = body_state.collision_layer


func _move_and_slide_grounded(was_on_floor: bool) -> void:
      var motion := velocity
      var motion_slide_up := motion.slide(up_direction)
      var prev_floor_normal := _floor_normal

      _platform_rid = RID()
      _platform_object_id = Object.new().get_instance_id()
      _floor_normal = Vector2.ZERO
      _platform_velocity = Vector2.ZERO

      const CMP_EPSILON = 0.00001

      var sliding_enabled := not floor_stop_on_slope
      var can_apply_constant_speed := sliding_enabled
      var apply_ceiling_velocity := false
      var vel_dir_facing_up := velocity.dot(up_direction) > 0
      var last_travel := Vector2.ZERO
      var first_slide := true

      for slide in max_slides:
            var collision := move_and_collide(motion, false, safe_margin, not sliding_enabled)

            _last_motion = motion
            if collision != null:
                  _last_motion = collision.get_travel()
                  _motion_results.push_back(collision)
                  _set_collision_direction(collision)
                  if _on_ceiling and collision.get_collider_velocity() != Vector2.ZERO and collision.get_collider_velocity().dot(up_direction) < 0:
                        if not slide_on_ceiling or motion.dot(up_direction) < 0 or (collision.get_collider_velocity() + up_direction).length() < 0.01:
                              apply_ceiling_velocity = true
                              var ceiling_vertical_velocity := up_direction * up_direction.dot(collision.get_collider_velocity())
                              var motion_vertical_velocity := up_direction * up_direction.dot(velocity)
                              if motion_vertical_velocity.dot(up_direction) > 0 or ceiling_vertical_velocity.length_squared() > motion_vertical_velocity.length_squared():
                                    velocity = ceiling_vertical_velocity + velocity.slide(up_direction)
                  if _on_floor and floor_stop_on_slope and (velocity.normalized() + up_direction).length() < 0.01:
                        var gt := get_global_transform()
                        if collision.get_travel().length() <= safe_margin + CMP_EPSILON:
                              gt.origin -= collision.get_travel()
                        global_transform = gt
                        velocity = Vector2.ZERO
                        _last_motion = Vector2.ZERO
                        motion = Vector2.ZERO
                        break

                  if collision.get_remainder().is_zero_approx():
                        motion = Vector2.ZERO
                        break

                  if floor_block_on_wall and _on_wall and motion_slide_up.dot(collision.get_normal()) <= 0:
                        if was_on_floor and not not _on_floor and not vel_dir_facing_up:
                              if collision.get_travel().length() <= safe_margin + CMP_EPSILON:
                                    var gt := get_global_transform()
                                    gt.origin -= collision.get_travel()
                                    global_transform = gt
                              _snap_on_floor(true, false, true)
                              velocity = Vector2.ZERO
                              _last_motion = Vector2.ZERO
                              motion = Vector2.ZERO
                              break
                        elif not _on_floor:
                              motion = up_direction * up_direction.dot(collision.get_remainder())
                              motion = motion.slide(collision.get_normal())
                        else:
                              motion = collision.get_remainder()
                  elif floor_constant_speed and f_is_on_floor_only() and can_apply_constant_speed and was_on_floor and motion.dot(collision.get_normal()) < 0:
                        can_apply_constant_speed = false
                        var motion_slide_norm := collision.get_remainder().slide(collision.get_normal()).normalized()
                        motion = motion_slide_norm * (motion_slide_norm.length() * collision.get_travel().slide(up_direction).length() - last_travel.slide(up_direction).length())
                  elif (sliding_enabled or not _on_floor) and (not _on_ceiling or slide_on_ceiling or not vel_dir_facing_up) and not apply_ceiling_velocity:
                        var slide_motion := collision.get_remainder().slide(collision.get_normal())
                        if slide_motion.dot(velocity) > 0.0:
                              motion = slide_motion
                        else:
                              motion = Vector2.ZERO
                        if slide_on_ceiling and _on_ceiling:
                              if vel_dir_facing_up:
                                    velocity = velocity.slide(collision.get_normal())
                              else:
                                    velocity = up_direction * up_direction.dot(velocity)
                  else:
                        motion = collision.get_remainder()
                        if _on_ceiling and not slide_on_ceiling and vel_dir_facing_up:
                              velocity = velocity.slide(up_direction)
                              motion = motion.slide(up_direction)
                  last_travel = collision.get_travel()
            elif floor_constant_speed and first_slide and _on_floor_is_snapped(was_on_floor, vel_dir_facing_up):
                  can_apply_constant_speed = false
                  sliding_enabled = true
                  var gt := get_global_transform()
                  gt.origin = _previous_position
                  global_transform = gt

                  var motion_slide_norm := motion.slide(prev_floor_normal).normalized()
                  motion = motion_slide_norm * motion_slide_norm.length()
                  collision = null

            can_apply_constant_speed = not can_apply_constant_speed and not sliding_enabled
            sliding_enabled = true
            first_slide = false

            if collision == null or motion.is_zero_approx():
                  break

      _snap_on_floor(was_on_floor, vel_dir_facing_up, false)

      if f_is_on_wall_only() and motion_slide_up.dot(_motion_results.get(0).get_normal()) < 0:
            var slide_motion := velocity.slide(_motion_results.get(0).get_normal())
            if motion_slide_up.dot(slide_motion) < 0:
                  velocity = up_direction * up_direction.dot(velocity)
            else:
                  velocity = up_direction * up_direction.dot(velocity) + slide_motion.slide(up_direction)
      if _on_floor and not vel_dir_facing_up:
            velocity = velocity.slide(up_direction)


func _move_and_slide_floating() -> void:
      var motion := velocity
      _platform_rid = RID()
      _platform_object_id = Object.new().get_instance_id()
      _floor_normal = Vector2.ZERO
      _platform_velocity = Vector2.ZERO

      var first_slide := false
      for slide in max_slides:
            var collision := move_and_collide(motion, false, safe_margin, true)
            _last_motion = motion
            if collision != null:
                  _last_motion = collision.get_travel()
                  _motion_results.push_back(collision)
                  _set_collision_direction(collision)
                  if collision.get_remainder().is_zero_approx():
                        motion = Vector2.ZERO
                        break

                  if wall_min_slide_angle != 0 and collision.get_angle(-velocity.normalized()) < wall_min_slide_angle + _FLOOR_ANGLE_THRESHOLD:
                        motion = Vector2.ZERO
                  elif first_slide == true:
                        var motion_slide_norm := collision.get_remainder().slide(collision.get_normal()).normalized()
                        motion = motion_slide_norm * (motion.length() - collision.get_travel().length())
                  else:
                        motion = collision.get_remainder().slide(collision.get_normal())

                  if motion.dot(velocity) <= 0.0:
                        motion = Vector2.ZERO
            elif motion.is_zero_approx():
                  break

            first_slide = false


func _snap_on_floor(was_on_floor: bool, vel_dir_facing_up: bool, wall_as_floor: bool) -> void:
      if _on_floor or not was_on_floor or vel_dir_facing_up:
            return
      _apply_floor_snap(wall_as_floor)


func _apply_floor_snap(wall_as_floor: bool = false) -> void:
      if _on_floor:
            return
      var length := maxf(floor_snap_length, safe_margin)
      var previous_gt := get_global_transform()
      var collision := move_and_collide(-up_direction * length, false, safe_margin, true)

      if collision == null:
            return
      if collision.get_angle(up_direction) <= floor_max_angle + _FLOOR_ANGLE_THRESHOLD or \
      wall_as_floor and collision.get_angle(-up_direction) > floor_max_angle + _FLOOR_ANGLE_THRESHOLD:
            _on_floor = true
            _floor_normal = collision.get_normal()
            _set_platform_data(collision)

            if collision.get_travel().length() > safe_margin:
                  collision.set("travel", up_direction * up_direction.dot(collision.get_travel()))
            else:
                  collision.set("travel", Vector2.ZERO)
      previous_gt.origin += collision.get_travel()
      global_transform = previous_gt


func _on_floor_is_snapped(was_on_floor: bool, vel_dir_facing_up) -> bool:
      if up_direction == Vector2.ZERO or _on_floor or not was_on_floor or vel_dir_facing_up:
            return false
      var length := maxf(floor_snap_length, safe_margin)

      var coll := move_and_collide(-up_direction * length, false, safe_margin, true)
      if coll != null:
            if coll.get_angle(up_direction) <= floor_max_angle + _FLOOR_ANGLE_THRESHOLD:
                  return true
      return false
