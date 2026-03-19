# DNF Framework — Task 清单

## Phase 6: Resource 数据层重构

- [ ] 6.1 创建 `character/character_config.gd` (CharacterConfig Resource)
  - 角色名/显示名
  - 状态动画映射表 Dictionary
  - 基础属性 (速度/血量/重力)
  - skills: Array[SkillData]
  - moves: Array[DNFMove]

- [ ] 6.2 创建 `skill/skill_frame_data.gd` (SkillFrameData Resource)
  - total_frames: int
  - hitbox_entries: Array[HitboxFrameEntry]
  - effect_entries: Array[EffectFrameEntry]
  - stun_frames: Array[int] — 产生僵直的帧
  - cancel_window: Vector2i

- [ ] 6.3 创建 `combat/hitbox_data.gd` (HitboxData/HitboxFrameEntry Resource)
  - rect: Rect2 — 碰撞体范围
  - frame_range: Vector2i — 激活帧区间
  - hit_behavior: DNFHitBehavior
  - offset: Vector2 — 相对角色原点偏移

- [ ] 6.4 创建 `skill/skill_ui_data.gd` (SkillUIData Resource)
  - icon: Texture2D
  - display_name: String
  - description: String
  - hotkey_hint: String
  - cooldown_display: bool

- [ ] 6.5 重构 SkillData 整合帧数据 + UI
  - 添加 frame_data: SkillFrameData
  - 添加 ui_data: SkillUIData
  - 添加 input_conditions: Array[DNFInputType]
  - 添加 cancel_into: Array[String]

- [ ] 6.6 重构目录结构
  - state_machine/ → character/ + state/
  - move_system/ → 合并入 skill/
  - skill_system/ → skill/
  - 更新所有 preload/extends 引用
  - 更新 plugin.gd 注册

- [ ] 6.7 更新自动化测试适配新结构
- [ ] 6.8 创建示例 .tres 配置文件 (角色+技能)

## Phase 7: Inspector 增强

- [ ] 7.1 创建 `editor/dnf_inspector_plugin.gd`
  - 注册到 plugin.gd
  - _can_handle() 识别 DNF Resource 类型

- [ ] 7.2 SkillFrameData 自定义 Inspector
  - 帧范围滑块编辑
  - 碰撞体列表管理
  - 特效列表管理

- [ ] 7.3 CharacterConfig 自定义 Inspector
  - 状态-动画映射表编辑器
  - 技能/招式引用管理

- [ ] 7.4 HitBehavior 增强 Inspector
  - 参数分组显示
  - 受击类型联动

- [ ] 7.5 注册所有自定义 Resource 类型到编辑器
  - add_custom_type 补全所有缺失类型

## Phase 8: 技能帧编辑器面板

- [ ] 8.1 创建 `editor/frame_timeline.gd` 帧时间轴控件
  - 可缩放/滚动的帧条
  - 显示起手/活跃/收招区间
  - 碰撞体激活标记
  - 特效触发标记
  - 僵直帧标记

- [ ] 8.2 创建 `editor/hitbox_preview.gd` 碰撞体预览
  - 2D 画布显示碰撞体矩形
  - 支持选帧切换
  - 叠加角色轮廓

- [ ] 8.3 创建 `editor/skill_editor_panel.gd` 主面板
  - 技能树列表
  - FrameTimeline + HitboxPreview 布局
  - 属性编辑区
  - .tres 导入/导出

- [ ] 8.4 注册为 Bottom Panel 到 EditorPlugin

## Phase 9: 角色配置器 + 模板

- [ ] 9.1 创建 `editor/character_config_editor.gd`
  - 角色属性面板
  - 状态动画预览
  - 技能列表管理
  - 生成角色场景按钮

- [ ] 9.2 创建角色/技能模板 .tres
  - 近战型角色模板
  - 远程型角色模板
  - Boss 角色模板
  - 通用攻击技能模板

- [ ] 9.3 创建 AI 行为配置 Resource
  - ai_behavior.gd (AIBehaviorConfig Resource)
  - 攻击频率/反应距离/连招模式

## Phase 10: 集成示例 + 文档

- [ ] 10.1 用配置器创建完整角色示例
- [ ] 10.2 用配置器创建敌人示例
- [ ] 10.3 创建技能配置工作流教程
- [ ] 10.4 更新 README.md API 文档
- [ ] 10.5 录屏/截图说明编辑器使用方法
