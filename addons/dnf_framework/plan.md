# DNF Framework — 编辑器配置器开发计划

## 目标

将 dnf_framework 从"纯代码驱动"升级为"编辑器可视化配置 + 代码驱动"的完整格斗游戏框架。
用户可以在 Godot 编辑器中通过 Inspector、Resource 文件、和自定义 Dock 面板来：

1. 配置角色的各状态动画帧（idle/walk/run/jump/attack 等）
2. 配置技能/招式的帧数据（起手帧、活跃帧、收招帧、碰撞体范围）
3. 配置每个技能的特效帧动画和产生僵直的帧
4. 配置技能的 UI 图标和显示信息
5. 配置敌人 AI 行为模板

后续增加角色、敌人、技能都可以直接在编辑器界面中完成配置。

---

## 当前架构（已完成 Phase 1-5）

```
dnf_framework/
├── frame_animation/    # FrameAnimationPlayer — 帧动画播放
├── frame_input/        # InputBuffer — 输入缓冲 + 指令
├── frame_physics/      # FrameCharacterBody2D — 帧物理
├── state_machine/      # DNFCharacter / DNFStates / DNFStateMachine
├── combat/             # DNFHitbox / DNFHurtbox / DNFCombatManager / DNFHitBehavior
├── move_system/        # DNFMove / DNFInputType / Cancel
├── skill_system/       # DNFSkillComponent / DNFSkillData / SkillEvents
├── examples/           # Phase 1-5 示例
└── tests/              # 152 个自动化测试
```

---

## 重构后目标架构

```
dnf_framework/
├── core/                          # 核心基础模块（不变）
│   ├── frame_animation/           # FrameAnimationPlayer
│   ├── frame_input/               # InputBuffer
│   └── frame_physics/             # FrameCharacterBody2D
│
├── character/                     # 角色系统（原 state_machine/ 重组）
│   ├── dnf_character.gd           # 角色基类
│   ├── dnf_states.gd              # 状态枚举
│   └── character_config.gd        # [新] CharacterConfig Resource
│
├── combat/                        # 战斗系统（保留）
│   ├── dnf_hitbox.gd
│   ├── dnf_hurtbox.gd
│   ├── hit_behavior.gd
│   ├── combat_manager.gd
│   └── hitbox_data.gd             # [新] 碰撞体配置 Resource
│
├── skill/                         # 技能系统（原 move_system + skill_system 合并重组）
│   ├── skill_data.gd              # 技能/招式数据 Resource
│   ├── skill_frame_data.gd        # [新] 帧数据配置（每帧的碰撞体/特效/状态）
│   ├── skill_component.gd         # 技能执行组件
│   ├── skill_event.gd             # 帧事件基类
│   ├── skill_effect_event.gd      # 特效事件
│   ├── skill_hitbox_event.gd      # 碰撞体事件
│   ├── skill_movement_event.gd    # 位移事件
│   ├── skill_ui_data.gd           # [新] 技能 UI 配置（图标/名称/描述/快捷键）
│   └── input_condition.gd         # 输入条件（原 input_type + equal_check + command_motion 合并）
│
├── state/                         # 状态机（原 state_machine/ 精简）
│   ├── state_machine.gd
│   ├── fighter_state.gd
│   ├── state_event.gd
│   └── state_transition_event.gd
│
├── editor/                        # [新] 编辑器扩展
│   ├── dnf_inspector_plugin.gd    # Inspector 自定义面板
│   ├── skill_editor_panel.gd      # 技能帧数据编辑器（Bottom Panel）
│   ├── character_config_editor.gd # 角色配置编辑器
│   ├── frame_timeline.gd          # 帧时间轴控件
│   └── hitbox_preview.gd          # 碰撞体预览控件
│
├── examples/                      # 示例
├── tests/                         # 测试
├── plugin.gd                      # 插件入口
└── plugin.cfg
```

---

## 分阶段开发

### Phase 6: Resource 数据层重构

**目标**: 建立完整的数据驱动 Resource 层，所有配置都通过 .tres 文件完成。

1. **CharacterConfig** — 角色配置 Resource
   - 角色名称、显示名称
   - 各状态对应的动画名称映射 (Dictionary: State → anim_name)
   - 基础属性 (速度/血量/重力等)
   - 技能列表引用 (Array[SkillData])
   - 招式列表引用 (Array[DNFMove])

2. **SkillFrameData** — 帧数据 Resource
   - 总帧数
   - 每帧的碰撞体配置 (Array[HitboxFrameEntry])
   - 每帧的特效配置 (Array[EffectFrameEntry])
   - 每帧的状态效果 (哪一帧产生僵直/击退/击飞)
   - 取消窗口范围

3. **HitboxData** — 碰撞体帧条目
   - 矩形范围 (Rect2)
   - 绑定的 HitBehavior
   - 激活帧范围

4. **SkillUIData** — 技能 UI 数据
   - 图标纹理 (Texture2D)
   - 显示名称
   - 描述文本
   - 快捷键绑定
   - 冷却显示

5. **重构 SkillData** — 整合 DNFMove
   - SkillData 统一表示技能和招式
   - 包含 SkillFrameData（帧级配置）
   - 包含 SkillUIData（UI 配置）
   - 包含输入条件
   - 取消列表
   - 连段链

### Phase 7: 编辑器 Inspector 增强

**目标**: 让 Resource 在 Inspector 中的编辑体验更好。

1. **DNFInspectorPlugin** — 注册到 EditorPlugin
   - 识别 CharacterConfig / SkillData / SkillFrameData 等 Resource
   - 为复杂字段提供自定义 EditorProperty

2. **SkillFrameData Inspector**
   - 帧范围滑块
   - 碰撞体矩形可视化预览
   - 特效帧标记

3. **CharacterConfig Inspector**
   - 状态-动画映射表
   - 技能列表管理
   - 属性概览

4. **HitBehavior Inspector**
   - 伤害/僵直/击退参数组
   - 受击类型下拉
   - 参数预览

### Phase 8: 技能帧编辑器面板 (Bottom Panel)

**目标**: 提供一个专用的底部面板来可视化编辑技能的帧数据。

1. **FrameTimeline 控件**
   - 水平帧时间轴
   - 显示起手帧/活跃帧/收招帧区间
   - 可拖拽调整帧范围
   - 帧标记 (碰撞体激活/特效触发/僵直产生)

2. **HitboxPreview 控件**
   - 2D 画布预览碰撞体范围
   - 叠加角色 Sprite 显示
   - 帧切换实时预览

3. **SkillEditorPanel**
   - 技能列表树
   - 选中技能显示 FrameTimeline + HitboxPreview
   - 特效帧配置面板
   - 导入/导出 .tres

### Phase 9: 角色配置器 + 模板系统

**目标**: 支持从模板快速创建新角色/敌人。

1. **CharacterConfigEditor**
   - 角色属性编辑面板
   - 状态动画预览
   - 技能/招式列表管理
   - 一键生成角色场景

2. **模板系统**
   - 预设角色模板 (近战型/远程型/Boss型)
   - 预设技能模板 (普通攻击/上挑/特殊技)
   - 复制/继承配置

3. **敌人 AI 配置**
   - AI 行为模板 Resource
   - 攻击频率/反应距离/连招模式
   - Inspector 可配置

### Phase 10: 完整集成示例 + 文档

1. 使用配置器创建完整角色示例
2. 使用配置器创建敌人示例
3. 演示技能配置工作流
4. 更新 README 和 API 文档

---

## 关键设计原则

1. **纯 Resource 数据驱动** — 所有配置都是 .tres 文件，不硬编码
2. **Editor-first** — 编辑器体验优先，减少写代码
3. **向后兼容** — 现有代码仍然可用，配置器是增强
4. **Rollback-friendly** — 所有新增数据都支持 save/load_state
5. **模块化** — 每个编辑器组件独立可用
