# Godot 回滚格斗游戏演示
### 基于 [Bimdav 的 Delta Rollback 插件](https://gitlab.com/BimDav/delta-rollback/)
### 使用 [David Snopek 的 SG Physics 2D 插件](https://gitlab.com/snopek-games/sg-physics-2d) 构建
### [David Snopek 原创的 Godot 回滚网络代码插件](https://gitlab.com/snopek-games/godot-rollback-netcode)
![示例剪辑](https://raw.githubusercontent.com/blast-harbour/Godot-Rollback-Fighter-Demo/main/ExampleClip.gif)
## 概述
该项目既是一个资源，用于提供许多常见格斗游戏功能的示例实现，也是使用 SG Physics 2D（一个专为回滚网络代码设计的确定性物理引擎）与 Godot 4.2.2 中的 Godot Rollback 插件结合使用的示例。Bimdav 的 "Delta Rollback" 是 David Snopek 原创 Godot Rollback Netcode 插件的一个分支，它将所有核心功能移植到 C++ 作为 GDExtension，提供了更好的性能！它的使用方式与原始插件大致相同，因此如果您想开始使用，可以按照 [Snopek 非常出色的教程系列](https://www.youtube.com/watch?v=zvqQPbT8rAE&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir) 进行学习！虽然他的教程是一个很好的资源，但由于它是为 Godot 3 制作的，因此在语法上会有差异。我建议您查看我的项目和 BimDav 的示例项目，以了解如何在 Godot 4 中运行该插件。

## 功能
- 一个 "FightManager" 节点，用于管理所有游戏相关节点上方法的调用顺序
- 一个简单的基于节点的状态机实现
- 带有命令缓冲区的输入系统，用于解释动作输入，如四分之一圆（执行为下、下前、前）
- 角色推挤交互
- 角色受击框/攻击框系统，其中攻击框被分配行为，以决定在格挡、命中或空中命中时要做什么
- 高低格挡
- 投射物
- 生命值条和玩家 KO 后重新开始回合

所有功能均完全支持回滚网络代码，这是格斗游戏网络对战的黄金标准解决方案！！！！
