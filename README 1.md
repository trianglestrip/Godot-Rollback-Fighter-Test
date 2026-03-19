Delta Rollback
==============

![Logo](icon.png)

这是一个用于在 Godot 游戏引擎中实现回滚和预测网络代码的插件。

它基于 [Snopek Games Godot Rollback Netcode](https://gitlab.com/snopek-games/godot-rollback-netcode)。
这个大型分支源于我们注意到原始仓库对于我们正在开发的游戏来说太慢了。
我们通过以下方式解决这个问题：

 - 使用 GDExtension，这使得我们可以用 C++ 重写关键循环。
 - 利用观察到的优化：回滚（rolling **back**）是关键的，必须非常快，而前滚（rolling **forward**）则用于更罕见的情况，如调试或让玩家加入已开始的比赛，这允许（非常轻微地）慢一些。

除了基础功能（收集输入、保存/加载状态、发送消息、检测不匹配等）之外，这个库还旨在支持在真实游戏中实现回滚的许多其他方面，包括计时器、动画、随机数生成和声音 - 以及高质量的调试工具，使解决问题更容易。

实现回滚和预测是困难的，因此每一点帮助都很重要。:-)

教程
---------

David Snopek 为他的 Godot Rollback Netcode 插件制作了一系列精彩的 YouTube 视频教程 - 这里是
[播放列表](https://www.youtube.com/playlist?list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir)，
以下是截至上次更新此 README 时已发布的部分：

- [Godot 中的回滚网络代码（第 1 部分）：什么是回滚和预测？](https://www.youtube.com/watch?v=zvqQPbT8rAE&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=1)
- [Godot 中的回滚网络代码（第 2 部分）：开始使用 Godot Rollback Netcode 插件！](https://www.youtube.com/watch?v=NsA-lz2B5Sw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=2)
- [Godot 中的回滚网络代码（第 3 部分）：制作自定义 MessageSerializer](https://www.youtube.com/watch?v=Bxao6x8-2vw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=3)
- [Godot 中的回滚网络代码（第 4 部分）：生成场景和 NetworkTimer](https://www.youtube.com/watch?v=iQtodIxM2-0&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=4)
- [Godot 中的回滚网络代码（第 5 部分）：状态、哈希和不匹配](https://www.youtube.com/watch?v=PK4jsbUPC38&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=5)
- [Godot 中的回滚网络代码（第 6 部分）：离线游玩！](https://www.youtube.com/watch?v=Yk7sLEK2vCg&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=6)
- [Godot 中的回滚网络代码（第 7 部分）：输入延迟和插值](https://www.youtube.com/watch?v=Y45rWIS3Qag&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=7)
- [Godot 中的回滚网络代码（第 8 部分）：动画播放器](https://www.youtube.com/watch?v=avCF3BQV15U&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=8)
- [Godot 中的回滚网络代码（第 9 部分）：音效](https://www.youtube.com/watch?v=qY7IVObS2Rw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=9)
- [Godot 中的回滚网络代码（第 10 部分）：随机数](https://www.youtube.com/watch?v=jjoRxXoTpPQ&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=10)
- [Godot 中的回滚网络代码（第 11 部分）：高级输入预测](https://www.youtube.com/watch?v=fgzEBHQyf2k&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=11)

更多视频即将推出！

安装
----------

这个插件是作为编辑器插件实现的。

如果您以前从未安装过插件，请参阅
[关于如何安装插件的官方文档](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)。

不过，简短的版本是：

1. 将此项目中的 `addons/delta_rollback` 目录和 `bin/` 目录复制到您的 Godot 项目中 *完全相同的路径*。最简单的方法是在 Godot 编辑器中的 AssetLib 中 - 搜索 "Delta Rollback"。

2. 通过点击 **项目** -> **项目设置...**，进入 "插件" 选项卡，然后点击 "Delta Rollback" 旁边的 "启用" 复选框来启用插件。

使用此插件的游戏
----------------------

- [Jewel Run](https://store.steampowered.com/app/2097850/Jewel_Run/)

如果您发布了使用此插件的游戏，请提交 MR（合并请求）将其添加到列表中！

概述
--------

这是对插件包含的不同部分的快速概述。

### 单例 ###

- `res://addons/godot-rollback-netcode/SyncManager.gd`：这是插件的核心。启用插件时，它会自动添加到您的项目中。它必须命名为 `SyncManager` 才能正常工作。

- `res://addons/godot-rollback-netcode/SyncDebugger.gd`：添加此单例会导致更多调试消息打印到控制台（并捕获在正常的 Godot 日志中），并提供调试覆盖层。默认情况下，按 F11 可以显示覆盖层，但您可以在项目设置的输入映射中将任何输入事件分配给 "sync_debug" 操作。

- `res://addons/godot-rollback-netcode/SyncReplay.gd`：添加此单例将允许您使用添加到 Godot 编辑器中的 "日志检查器" 工具从日志文件回放匹配。有关更多信息，请参阅下面的 "设置回放" 小节。

### `SyncManager` 上的重要属性、方法和信号 ###

`SyncManager` 单例是此插件的核心，也是您的游戏与插件交互的主要方式之一。（另一种主要方式是通过您将在节点脚本中实现的虚拟方法 - 有关更多信息，请参阅下面的 "虚拟方法" 部分。）

#### 属性：####

- `current_tick: int`：我们正在执行的当前 tick。在回滚期间，这将更新为当前正在重新执行的 tick。

- `input_tick: int`：我们当前正在收集本地输入的 tick。如果在项目设置中配置了输入延迟，这将比 `current_tick` 提前输入延迟的帧数。在回滚期间，这不会改变。

- `started: bool`：如果同步已开始，则为 true；否则为 false。此属性是只读的 - 您应该调用 `start()` 或 `stop()` 方法来开始或停止同步。

#### 方法：####

- `add_peer(peer_id: int) -> void`：使用其在 Godot 的 [高级多人游戏 API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) 中的 ID 添加一个对等体。添加对等体后，`SyncManager` 将立即开始对其进行 ping。在调用 `SyncManager.start()` 之前，应添加所有对等体。

- `start() -> void`：开始同步！这应该只在 "主机"（ID 为 1 的对等体）上调用，这将告诉所有其他客户端也开始同步。调用此方法后，下面描述的 "虚拟方法" 才会开始被调用。

- `stop() -> void`：停止同步。如果在 "主机"（ID 为 1 的对等体）上调用，它将告诉所有客户端也停止同步。

- `clear_peers() -> void`：清除对等体列表。

- `start_logging(log_file_path: String, match_info: Dictionary = {}) -> void`：
  开始将当前匹配的详细信息记录到给定的日志文件中。常见的约定是将日志文件放在 "user://detailed_logs/" 下。`match_info` 存储在日志的开头，用于加载匹配的回放。此方法应在 `SyncManager.start()` 之前或响应 "sync_started" 信号时调用。

- `stop_logging() -> void`：停止日志记录。此方法应在 `SyncManager.stop()` 之后或响应 "sync_stopped" 信号时调用。

- `set_synced(node: Node, property: String, value, interpolate:=false) -> void`：
  以回滚安全的方式将 `node` 上的 `property` 设置为 `value`。如果 `interpolate` 为 true，它将在帧之间插值值。

- `spawn(name: String, parent: Node, scene: PackedScene, data: Dictionary = {}, rename: bool = true) -> Node`：
  生成一个场景，并在状态中创建一个 "生成记录"，以便可以作为回滚的结果取消生成或重新生成。

  它返回生成的顶级节点。

  * `name`：用于生成的顶级节点的基本名称。
  * `parent`：生成的场景将添加到的父节点。
  * `scene`：要生成的场景。
  * `data`：将传递给顶级节点上的 `_network_spawn_preprocess()` 和 `_network_spawn()` 的数据。有关更多信息，请参阅下面描述的 "虚拟方法"。
  * `rename`：如果为 true，生成的顶级节点的实际名称将附加一个递增的整数。如果为 false，它将尝试使用 `name`，但这可能会导致冲突。只有在您确定没有其他同级节点会使用该名称时，才将其设置为 false。

- `despawn(node: Node) -> void`：取消生成之前通过 `SyncManager.spawn()` 生成的节点。它调用 `_network_despawn()` 并移除状态中的 "生成记录"。默认情况下，这也会将节点从其父节点中移除并调用 `node.queue_free()`。但是，如果您在项目设置中启用了 "重用已取消生成的节点"，则节点将被保存，并在以后需要生成相同场景时重用。这使得在 `_network_prepare_for_reuse()` 中清理节点的内部状态变得尤为重要，以便节点在重用时 "像新的一样"。

- `play_sound(identifier: String, sound: AudioStream, info: Dictionary = {}) -> void`：
  播放声音并记录我们在当前 tick 上播放了这个特定声音，这样如果我们由于回滚而再次执行相同的 tick，就不会再次播放它。
  * `identifier`：声音的唯一标识符。在当前 tick 上，只有一个具有此标识符的声音会被播放。常见的约定是使用播放声音的节点的路径，并附加某种 "标签"，例如：
	```
	SyncManager.play_sound(str(get_path()) + ':shoot', shoot_sound)
	```
  * `sound`：要播放的声音资源。
  * `info`：一组可选参数，包括：
	- `position`：一个 `Vector2`，给出声音应该来自的位置。如果省略，则不使用位置音频。
	- `volume_db`：一个 `float`，给出音量（分贝）。
	- `pitch_scale`：一个 `float`，用于缩放音高。
	- `bus`：播放声音的总线名称。如果未给出，则使用项目设置中配置的默认总线。
- `connect_signal(node: Node, name: String, target: Node, method: String, binds := [], flags := 0) -> void`：
  使用此方法将信号连接到节点，以便将其写入状态：例如，在 LogInspector 中回放游戏时，信号将自动连接。以这种方式连接的信号将在节点 `prepared_for_reuse` 时自动移除。

#### 信号：####

- `sync_started ()`：当同步开始时发出，这是在 "主机" 上调用 `SyncManager.start()` 的结果。即使 `SyncManager.start()` 只在 "主机" 上调用，此信号也会在 _所有_ 对等体上发出。

- `sync_stopped ()`：当同步因任何原因停止时发出 - 可能是由于错误（在这种情况下，"sync_error" 会在此信号之前发出）或在本地或 "主机" 上调用了 `SyncManager.stop()`。

- `sync_lost ()`：当此客户端与其他客户端的同步偏差足够大，以至于我们需要暂停一段时间并尝试重新获得同步时发出。您的游戏应该向玩家显示一些指示（消息或加载图标），以便他们知道为什么比赛突然停止。

- `sync_regained ()`：如果我们在失去同步后设法重新获得同步，则发出此信号。当 "sync_lost" 发出时，您的游戏向玩家显示的消息或图标应该被移除。

- `sync_error (msg: String)`：当发生致命同步错误且比赛无法继续时发出。这可能有多种原因，这些原因将在 `msg` 中的人类可读消息中标识。

- `interpolation_frame ()`：如果在项目设置中启用了插值，`SyncManager` 的工作将分为 "tick 帧"（收集输入、执行回滚和执行 tick 的地方）和它们之间发生的可变数量的 "插值帧"。此信号在每个插值帧结束时发出，以便您可以在有更多时间预算的帧中执行某些操作（在 tick 帧期间需要发生更多事情）。

### 节点类型 ###

此插件包含一些支持回滚的节点类型：

- `NetworkTimer`：`Timer` 节点的替代品。与 `Timer` 不同，它不等待若干秒，而是等待若干 tick（`wait_ticks` 属性）。

  如果 `hash_state` 设置为 false，则计时器的状态不会包含在用于检测状态不匹配的哈希中。如果计时器可能只在单个客户端上运行，而不是在所有客户端上运行，这很有用。

- `NetworkAnimationPlayer`：继承自内置的 `AnimationPlayer`，但只会在每个 tick 前进（而不是随着时间推移），并且支持回滚。

  如果 `auto_reset` 设置为 true，它将在每次加载没有动画播放的状态时自动播放 "RESET" 动画。这有助于防止动画开始，但在回滚时确定它不应该开始，导致动画处于中间状态的问题。

- `NetworkRandomNumberGenerator`：用于以支持回滚的确定性方式生成随机数。在比赛开始时，客户端需要使用相同的种子初始化节点。每次生成随机数时，其内部状态都会以确定性方式更改，使得它在每个客户端上生成的数字序列相同。当回滚发生时，其内部状态将回滚，从而再次生成相同的数字序列。

  避免为游戏中的每个 `NetworkRandomNumberGenerator` 共享种子的一种方法是共享单个 "母种子"，该种子用于一个 `NetworkRandomNumberGenerator`，该生成器生成游戏所需的所有其他种子。我喜欢将此称为 "Johnny Appleseed 方法"，其中 "Johnny" 分发从 "母种子" 生长的种子。只要节点始终以确定性顺序初始化，这就会起作用！

### 虚拟方法 ###

要让节点参与回滚，它必须位于 "network_sync" 组中，这将导致 `SyncManager` 在节点上调用各种虚拟方法：

- `_save_state() -> Dictionary`：返回当前节点状态。执行回滚时，此相同状态将传递给 `_load_state()`。

  _警告：不要将任何 `Reference`、`Object`、`Array` 或 `Dictionary` 放入状态中，除非您可以先复制它们。这是因为稍后更改对象也会更改状态缓冲区中的数据。并且永远不要将 `Node` 放入状态中，而是使用节点路径或其他方式在以后定位正确的节点，因为原始节点可能不再存在。放入状态中的任何 `Object` 都需要在您的 `HashSerializer`（见下文）中提供特殊支持，以防止错误地检测到状态不匹配。_

- `_load_state(state: Dictionary) -> void`：调用以将节点回滚到之前的状态，该状态源自此节点的 `_save_state()` 方法。

- `_interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void`：
  使用从旧状态到新状态插值的值更新节点的当前状态。只有在项目设置中启用了 "插值" 时，才会调用此方法。

- `_get_local_input() -> Dictionary`：返回此节点操作所需的本地输入。这只会在 "网络主节点"（通过 `Node.set_network_master()` 设置） matches the peer id of the current
  client. Not all nodes need input, in fact, most do not. This is used most
  commonly on the node representing a player. This input will be passed into
  `_network_process()`.

- `_predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary`:
  Returns predicted remote input based on the input from the previous tick,
  which may itself be predicted. This will only be called for nodes whose
  "network master" DOES NOT match the peer id of the current client. If this
  method isn't provided, the same input from the last tick will be used as-is.
  This input will be passed into `_network_process()` when using predicted
  input. If `ticks_since_real_input` is negative, we haven't received any remote
  inputs yet, which happens at the very start of the game.

- `_network_process(input: Dictionary) -> void`: Processes this node for the
  current tick. The input will contain data from either `_get_local_input()`
  (if it's real user input) or `_predict_remote_input()` (if it's predicted).
  If this node doesn't implement those methods, it'll always be empty.

  This method is meant to do what `_process()` or `_physics_process()` would
  have done in most other Godot games.

- `_network_preprocess(input: Dictionary) -> void`: Works just like
  `_network_process()` but all the `_network_preprocess()` methods are run
  _before_ all the `_network_process()` methods.

- `_network_postprocess(input: Dictionary) -> void`: Works just like
  `_network_process()` but all the `_network_postprocess()` methods are run
  _after_ all the `_network_process()` methods.

The following methods are only called on scenes that are spawned/de-spawned
using `SyncManager.spawn()` and `SyncManager.despawn()`:

- `_network_spawn_preprocess(data: Dictionary) -> Dictionary`: Pre-processes
  the data passed to `SyncManager.spawn()` before it gets passed to
  `_network_spawn()`. The modified data returned by this method is what will
  get saved in state. This allows passing developer-friendly data to
  `SyncManager.spawn()` and this method can convert it into data that is
  safe to store in state.

  For example, you may pass a `Node` object into `SyncManager.spawn()` and
  this method could convert it into a `String` representing the node path.
  This is important because storing a `Node` in state can cause weird
  problems, because it could continue to change (or even get deleted!) by the
  time that state needs to be loaded again.

- `_network_spawn(data: Dictionary) -> void`: Called when a scene is spawned
  by `SyncManager.spawn()`.

- `_network_despawn() -> void`: Called when a node is de-spawned by
  `SyncManager.despawn()`.

### Project settings ###

The recommended way to configure `SyncManager` is via Project Settings
(although, you can change its properties in code at runtime as well).

You can find its project settings under **Network** -> **Rollback**, after the
plugin is enabled.

![Screenshot of "Rollback" section in Project Settings](assets/screenshots/project_settings.png)

- **Max Buffer Size**: The number of state and input frames to keep in the
  buffer. This defines the maximum number of ticks that the game can rollback.
- **Ticks To Calculate Advantage**: The number of ticks that we collect
  advantage calculations from each peer before calculating an average, and
  possibly skipping some frames so that other clients can catch up.
- **Input Delay**: The number of frames of input delay.
- **Ping Frequency**: The number of seconds between each ping.
- **Interpolation**: If enabled, we'll do 1 tick of interpolation. This
  allows the simulation frequency to be set lower than the rendering FPS,
  while still rendering smoothly.

**Limits:**

- **Max Input Frames Per Message**: The maximum number of input frames that
  will be sent in a single message. If there are more input frames, then
  multiple messages will be sent.
- **Max Messages At Once**: The maximum messages that will be sent to one
  peer at a time. If there are more messages, then the middle ones will be
  omitted (so the newest and oldest input frames will be sent).
- **Max Ticks To Regain Sync**: If the clients get out of sync, and they
  don't manage to regain sync after this many ticks have been skipped, then
  `SyncManager` will emit "sync_error" and kill the match.
- **Min Lag To Regain Sync**: If we've lost sync due to an input buffer
  underrun, then `SyncManager` won't start running again until the minimum
  lag with all clients is above this value. This is to prevent the game
  immediately losing sync right after it has regained it, meaning it will
  pause a slightly longer time, to avoid a series of smaller pauses.
- **Max State Mismatch Count**: If more than this many state mismatches are
  detected in a row, it's considered a fatal state mismatch, and
  `SyncManager` will emit "sync_error" and kill the match.

**Spawn Manager:**

- **Reuse Despawned Nodes**: If enabled, de-spawned nodes will be reused
  rather than instancing the scene every time. This is can provide a large
  performance boost in games that do a lot of spawning, but it requires the
  developer to carefully reset state during `_network_despawn()`.

**Sound Manager:**

- **Default Sound Bus**: The name of the default sound bus to use when
  playing sounds via `SyncManager.play_sound()`. If omitted, then "Master"
  will be used.

**Classes:**

These are all paths to classes that override the default implementations of
the "Adaptor classes" described in the section of the same name below.

If any are omitted, then the default implementation will be used.

**Debug:**

*WARNING: Do not keep these settings enabled in the release version of your
game!*

- **Rollback Ticks**: If set, every tick, the game will rollback at least the
  number of ticks given here. This is a great setting to have enabled when
  implementing new game logic, as some problems won't be apparent until
  a series of rollbacks occur.
- **Random Rollback Ticks**: If set, every tick, the game will rollback a
  random number of ticks up to the given value. This can help find bugs that
  only appear when two clients rollback a different number of ticks when
  executing the same logic.  If "Rollback Ticks" is also set, it will
  effectively set a minimum value.
- **Message Bytes**: If any message exceeds the given number of bytes, an
  error will be pushed to the editor and console, including the size of the
  offending message.
- **Skip Nth Message**: If set, every nth message will not be sent. This is a
  quick way to simulate packet loss, but it isn't very accurate. System-level
  tools or a proxy that simulates packet loss will always make for more
  accurate testing.
- **Physics Process Msecs**: If `SyncManager._physics_process()` takes more
  than this many milliseconds, then an error will be pushed to the editor and
  console, including how long it actually took.
- **Process Msecs**: If `SyncManager._process()` takes more than this many
  milliseconds, then an error will be push to the editor and console,
  including how long it actually took.

**Log Inspector:**

- **Replay Match Scene Path**: The path to the scene to load when launching
  the game as a replay client.
- **Replay Match Scene Method**: The method on the above scene to call in
  order to setup the match to run as a replay. While this method can be named
  anything, it must accept the following arguments (in this order):
  - `my_peer_id: int`: The peer id that the replay client will be displaying.
  - `peer_ids: Array`: An array of the other peer ids in the match.
  - `match_info: Dictionary`: The `match_info` Dictionary that was passed to
	`SyncManager.start_logging()` when creating the log that we are replaying
	from. This should be used to initialize the match to the same state as
	the match that was logged.
- **Replay Arguments**: The arguments to pass to the game on the command-line
  when launching it as a replay client.
- **Replay Port**: The TCP port used by the Godot editor to communicate with
  the replay client.

#### Other important settings not under "Rollback": ####

- **Physics** -> **Common** -> **Physics FPS**: Since `SyncManager` uses
  `_physics_process()` to run tick frames, this controls the simulation
  frequency. If you're using interpolation, it's best if this value can
  evenly divide the rendering FPS, for example, if rendering at 60 fps,
  then 60, 30, 20, or 10 are all good values.

### Adaptor classes ###

There are a few adaptor classes that can be used to modify the behavior of
`SyncManager`.

#### `NetworkAdaptor` ####

All network communication from `SyncManager` passes through its
`NetworkAdaptor`. The default implementation uses Godot RPCs.

You can replace the network adaptor with your own class, in order to
customize network communications. This could even allow you to avoid using
Godot's High-level Multiplayer API in favor of some other underlying
communication layer, for example,
[Steam's peer-to-peer networking](https://partner.steamgames.com/doc/features/multiplayer/networking).

**Parent class:** `res://addons/godot-rollback-netcode/NetworkAdaptor.gd`

**Default implementation:** `res://addons/godot-rollback-network/RPCNetworkAdaptor.gd`

**Additional implementations:**

- `res://addons/godot-rollback-network/NakamaWebRTCNetworkAdaptor.gd`:
  Integrates with the
  [WebRTC and Nakama addon for Godot](https://gitlab.com/snopek-games/godot-nakama-webrtc).

- `res://addons/godot-rollback-network/DummyNetworkAdaptor.gd`:
  Allows using the addon without any real networking. It's used by the replay
  system in Log Inspector, and can also be used to implement an offline mode
  in your game - see the demo project for an example of how to do this.

#### `MessageSerializer` ####

The message serializer will convert input messages to bytes for sending to
the other clients.

The default implementation is relatively wasteful (it will likely lead to
messages exceeding the [MTU](https://en.wikipedia.org/wiki/Maximum_transmission_unit))
so you will **ALMOST ALWAYS** want to replace it with your own implementation
that can pack the data as small as possible. This can only be done by knowing
the structure and meaning of the data, which is why the game developer needs
to do it.

**Parent class and default implementation:** `res://addons/godot-rollback-netcode/MessageSerializer.gd`

#### `HashSerializer` ####

The hash serializer will convert state or input into primitive types so that
we can hash the Dictionary for use in comparisons. It is also used to convert
*back* from these primitive types in the "Log inspector" tool.

The default implementation can't handle `Object`s in a smart way, so if you
include any in your input or state, it could lead to `SyncManager` detecting
a false state or input mismatch. Replace this with your own implementation to
convert any of your objects into primitive types.

**Parent class and default implementation:** `res://addons/godot-rollback-netcode/HashSerializer.gd`

### "Log Inspector" tool in Godot editor: ###

The "Log Inspector" can be opened by clicking **Project** -> **Tools** ->
**Log inspector...** in the Godot editor.

It allows you to load the logs (generated by `SyncManager.start_logging()`)
from all the clients in a match and examine the data in detail.

**Note:** Each client generates its own seperate log file for the match, so
you'll need to collect them from the other players, and open ALL of them in
the "Log Inspector" together.

At the top there is a view selector which lets you switch between a "Frame"
and a "State/Input" view of the data.

#### Frame viewer: ###

![Screenshot of the "Frame viewer" in the "Log Inspector" tool in the Godot editor](assets/screenshots/log_inspector_frame.png)

The "Frame" viewer shows data about each frame executed, including tick
frames, interpolation frames and skipped frames. The x-axis is milliseconds
since the match began. It uses the system clock of the computer the client
ran on, so data may not be line up correctly. You can correct for this
by adding or subtracting milliseconds from each peer in the "Settings" dialog.

You can click anywhere on the graph, and it will show all the data logged on
the most recent frame for each client in the lower part of the window. This
data includes timing information, the number of rollbacks executed, messages
received and much more.

If you click the "Previous frame" or "Next frame" buttons, the cursor will
move forward or backward to the next frame on any peer. However, if "Seek only
on replay peer" is checked, it'll only jump to the next or previous frame
on the peer selected in the dropdown in the replay toolbar.

The arrows connect from the tick when input was generated, to the frame when
the other peer receives that input. This gives a visual representation of the
network traffic between those two peers. The pair of peers can be selected in
the "Settings" dialog.

The orange line represents the number of rollbacks performed on a given
"tick frame", allowing you to easily see how many mispredictions occurred
and during which portions of the match.

#### State/Input viewer: ####

![Screenshot of the "State/Input viewer" in the "Log Inspector" tool in the Godot editor](assets/screenshots/log_inspector_state_input.png)

The "State/Input" viewer allows you to look at the final state and input on
every tick in the match.

If there are any input or state mismatches (where one or more clients
recorded state or input that was different than the other clients), the
differences will be shown on the right side of the window.

Using the "Previous mismatch" or "Next mismatch" buttons, you can jump to the
previous or next mismatch found in the data.

You are likely to spend a large amount of time chasing down issues in your
game logic that lead to state mismatches. Input mismatches are much rarer,
but they are a super critical problem if they do occur.

#### How to setup replay ####

The "Log Inspector" can allow you to replay the match from the logs, by either
loading state (in the "State/Input viewer") or re-executing frames (in the
"Frame viewer").

This can be very helpful in debugging issues, by allowing you to visually
_see_ the state on a particular peer, when there is a state mismatch, or
re-execute frames as they happened during a match with breakpoints set in the
Godot debugger.

This works by launching a special instance of the game (called a "replay
client") which connects to the "Log Inspector" via a TCP port (this component
is called the "replay server").

However, there is a little bit of setup required to allow your game to
support this:

1. Add the `res://addons/godot-rollback-netcode/SyncReplay.gd` script as an
   autoload singleton in **Project** -> **Project settings...** and the
   "Autoload" tab.

2. Pass a `match_info` Dictionary to `SyncManager.start_logging()` with
   enough info to setup the match for replay.

3. Ensure that your game _doesn't_ do any logging when launched as a replay
   client. You can do this by checking if `SyncReplay.active` is true.

4. Set "Replay Match Scene Path" in "Project settings" to the match scene
   to load when showing a replay. Frequently, my games have a "Match.tscn"
   that runs the match when played normally, so this is also what's used for
   showing a replay, but you could create a unique replay scene as well.

5. Set "Replay Match Scene Method" in "Project settings" to the method on
   the scene set in the previous step, which will be able to setup the match
   to show the replay using the `match_info` from step number 2. Its
   implementation will look something like:
   ```
   func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
	 # Setup the match using 'match_info' and disable anything we don't
	 # want or need during replay.
	 pass
   ```
   For more details on the individual arguments, see what the "Project
   Settings" section above says about this setting.

6. (Optional) If you have a custom `HashSerializer`, ensure that it can
   unserialize any of the custom data it serializes, since this is what will
   be used to load the state and input data from the logs.

After completing all of these steps, you should be able to click the "Launch"
button on the replay toolbar in the "Log Inspector" and see your game launch
as a replay client. Then, in the "State/Input viewer", if you view a
particular tick, it should load the state from that tick in the replay client.

You can use the dropdown on the replay toolbar to configure which peer's data
you would like to use in the replay.

#### Manually reading log files ####

Starting with v1.0.0-alpha8, the log files are stored in a binary format.
However, a script is included in the addon to convert them to JSON, so that
humans or external tools can read them, if necessary.

You can run it like this:

```
godot --no-window --script addons/godot-rollback-netcode/log2json.gd --input=INPUT.log --output=OUTPUT.json
```

... replacing INPUT.log with a full path to the log file, and OUTPUT.json with
a path to the JSON file that will be created.

The most common "match flow"
----------------------------

While there's sure to be edge cases, this is this most common "match flow", or
the process your game goes through to start, play and stop a match using this
addon:

1. Get all players connected via Godot's
   [High-Level Multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html).

2. Call `SyncManager.add_peer()` for each peer in the match.

3. Initialize the match to its initial state on all clients. Sharing match
   configuration and letting the "host" know when each client is ready to
   start can be done using Godot's RPC mechanism. Make sure that all nodes
   representing players have their "network master" set (via
   `set_network_master()`) to the peer id of the client that is local for that
   player, so that the virtual `_get_local_input()` and
   `_predict_remote_input()` methods will be called.

4. Call `SyncManager.start()` on the "host".

5. Begin the match in all clients in response to the "sync_started" signal.

6. When the match is over, call `SyncManager.stop()` on the "host". (If a
   client needs to leave the match early, they should inform the other
   clients via an RPC or some other mechanism, and then call
   `SyncManager.stop()` locally.)

7. Clean-up after the match in all clients in response to the "sync_stopped"
   signal.

8. If these same players wish to play another match (which can be worked out
   over RPC), then return to step number 2.

9. If this client wishes to disconnect from these players entirely, call
   `SyncManager.clear_peers()` and disconnect from the High-Level Multiplayer
   API, possibly via `get_tree().multiplayer.close_connection()` (with ENet)
   or `get_tree.multiplayer.close()` (with WebRTC).

It's also a good idea to connect to the "sync_lost", "sync_regained" and
"sync_error" signals so you can provide the player with useful error messages
if something goes wrong.

If you are logging, you'll want to call `SyncManager.start_logging()` sometime
before calling `SyncManager.start()` (but after all match setup is complete)
or in response to the 'sync_started' signal, and call
`SyncManager.stop_logging()` just after calling `SyncManager.stop()` or in
response to the 'sync_stopped' signal. The logs are meant to contain data from
just a single match, which is what the "Log inspector" tool will expect.

Logo credits
------------

The logo is composed of these images:

- https://pxhere.com/en/photo/1451861 (License: CC0)
- https://godotengine.org/press (License: CC-BY-4.0 by Andrea Calabró)

License
-------

Copyright 2021-2022 David Snopek.

Licensed under the [MIT License](LICENSE.txt).Godot Rollback Netcode
======================

![Logo](icon.png)

This is an addon for implementing rollback and prediction netcode in the Godot
game engine.

Beyond the basics (gathering input, saving/loading state, sending messages,
detecting mismatches, etc) this library aims to provide support for many of
the other aspects of implementing rollback in a real game, including timers,
animation, random number generation, and sound - along with high-quality
debugging tools to make solving problems easier.

Implementing rollback and prediction is HARD, and so every little bit of help
is important. :-)

Tutorials
---------

I'm working on a series of video tutorials on YouTube - here's the
[playlist](https://www.youtube.com/playlist?list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir),
and these are the parts that are published as of the last time this README was
updated:

- [Rollback netcode in Godot (part 1): What is rollback and prediction?](https://www.youtube.com/watch?v=zvqQPbT8rAE&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=1)
- [Rollback netcode in Godot (part 2): Getting Started with the Godot Rollback Netcode addon!](https://www.youtube.com/watch?v=NsA-lz2B5Sw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=2)
- [Rollback netcode in Godot (part 3): Making a custom MessageSerializer](https://www.youtube.com/watch?v=Bxao6x8-2vw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=3)
- [Rollback netcode in Godot (part 4): Spawning scenes and NetworkTimer](https://www.youtube.com/watch?v=iQtodIxM2-0&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=4)
- [Rollback netcode in Godot (part 5): State, hashing and mismatches](https://www.youtube.com/watch?v=PK4jsbUPC38&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=5)
- [Rollback netcode in Godot (part 6): Playing offline!](https://www.youtube.com/watch?v=Yk7sLEK2vCg&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=6)
- [Rollback netcode in Godot (part 7): Input Delay and Interpolation](https://www.youtube.com/watch?v=Y45rWIS3Qag&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=7)
- [Rollback netcode in Godot (part 8): Animation Players](https://www.youtube.com/watch?v=avCF3BQV15U&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=8)
- [Rollback netcode in Godot (part 9): Sound Effects](https://www.youtube.com/watch?v=qY7IVObS2Rw&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=9)
- [Rollback netcode in Godot (part 10): Random Numbers](https://www.youtube.com/watch?v=jjoRxXoTpPQ&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=10)
- [Rollback netcode in Godot (part 11): Advanced Input Prediction](https://www.youtube.com/watch?v=fgzEBHQyf2k&list=PLCBLMvLIundBXwTa6gwlOUNc29_9btoir&index=11)

More videos are coming soon!

Installing
----------

This addon is implemented as an editor plugin.

If you've never installed a plugin before, please see the
[official docs on how to install plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

However, the short version is:

1. Copy the `addons/godot-rollback-netcode` directory from this project into
your Godot project *at the exact same path*. The easiest way to do this is in
the AssetLib right in the Godot editor - search for "Godot Rollback Netcode".

2. Enable the plugin by clicking **Project** -> **Project settings...**, going
to the "Plugins" tab, and clicking the "Enable" checkbox next to "Godot
Rollback Netcode".

Games using this addon
----------------------

- [Retro Tank Party](https://www.snopekgames.com/games/retro-tank-party)
- [Kronian Titans](http://www.kroniantitans.com/)
- [Castagne (Fighting Game Creator)](http://castagneengine.com)

If you release a game using this addon, please make an MR (Merge Request) to
add it to the list!

Overview
--------

This is a quick overview of the different pieces that the addon includes.

### Singletons ###

- `res://addons/godot-rollback-netcode/SyncManager.gd`: This is the core of
  the addon. It will be added to your project automatically when you enable
  the plugin. It must be named `SyncManager` for everything to work
  correctly.

- `res://addons/godot-rollback-netcode/SyncDebugger.gd`: Adding this
  singleton will cause more debug messages to be printed to the console (and
  captured in the normal Godot logs) and make a debug overlay available. By
  default, the overlay can be shown by pressing F11, but you can assign any
  input event to the "sync_debug" action in the Input Map in your project's
  settings.

- `res://addons/godot-rollback-netcode/SyncReplay.gd`: Adding this singleton
  will allow you to replay matches from log files, using the "Log Inspector"
  tool that is added to the Godot editor. See the "Setting up replay"
  sub-section below for more information.

### Important properties, methods and signals on `SyncManager` ###

The `SyncManager` singleton is the core of this addon, and one of the primary
ways that your game will interact with the addon. (The other primary way is
via virtual methods that you'll implement in scripts on your nodes - see the
section called "Virtual methods" below for more information.)

#### Properties: ####

- `current_tick: int`: The current tick that we are executing. This will
  update during rollback to be the tick that is presently being re-executed.

- `input_tick: int`: The tick we are currently gathering local input for. If
  there is an input delay configured in Project Settings, this will be ahead
  of `current_tick` by the number of frames of input delay. This doesn't
  change during rollback.

- `started: bool`: will be true if synchronization has started; otherwise
  it'll be false. This property is read-only - you should call the `start()`
  or `stop()` methods to start or stop synchronizing.

#### Methods: ####

- `add_peer(peer_id: int) -> void`: Adds a peer using its ID within Godot's
  [High-Level Multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html).
  Once a peer is added, the `SyncManager` will start pinging it right away.
  All peers should be added before calling `SyncManager.start()`.

- `start() -> void`: Starts synchronizing! This should only be called on the
  "host" (the peer with id 1), which will tell all the other clients to start
  as well. It's after calling this that the "Virtual methods" described below
  will start getting called.

- `stop() -> void`: Stops synchronizing. If called on the "host" (the
  peer with id 1) it will tell all the clients to stop as well.

- `clear_peers() -> void`: Clears the list of peers.

- `start_logging(log_file_path: String, match_info: Dictionary = {}) -> void`:
  Starts logging detailed information about the current match to the given
  log file. The common convention is to put the log files under
  "user://detailed_logs/". The `match_info` is stored at the start of the
  log, and is used when loading a replay of the match. This method should
  be called before `SyncManager.start()` or in response to the "sync_started"
  signal.

- `stop_logging() -> void`: Stops logging. This method should be called
  after `SyncManager.stop()` or in response to the "sync_stopped" signal.

- `spawn(name: String, parent: Node, scene: PackedScene, data: Dictionary = {}, rename: bool = true, signal_name: String = '') -> Node`:
  Spawns a scene and makes a "spawn record" in state so that it can be
  de-spawned or re-spawned as the result of a rollback.

  It returns the top-level node that was spawned, however, rather than doing
  most setup on the returned node, you should do it in response to the
  "scene_spawned" signal. This is because the scene could be re-spawned due
  to a rollback, and you probably want all the same setup to happen then as
  when it was originally spawned. (Note: there are rare cases when you do want
  to do setup *only* when spawned initially, and not when re-spawned.)

  * `name`: The base name to use for the top-level node that is spawned.
  * `parent`: The parent node the spawned scene will be added to.
  * `scene`: The scene to spawn.
  * `data`: Data that will be passed to `_network_spawn_preprocess()` and
	`_network_spawn()` on the top-level node. See the "Virtual methods"
	described below for more information.
  * `rename`: If true, the actual name of the top-level node that is spawned
	will have an incrementing integer appended to it. If false, it'll try to
	use the `name` but this could lead to conflicts. Only set to false if you
	know for sure that no other sibling node will use that name.
  * `signal_name`: If provided, this is the name that'll be passed to the
	"scene_spawned" signal; otherwise the `name` will be used.

- `despawn(node: Node) -> void`: De-spawns a node that was previously
  spawned via `SyncManager.spawn()`. It calls `_network_despawn()` and removes
  the "spawn record" in state.  By default, this will also remove the node
  from its parent and call `node.queue_free()`. However, if you have enabled
  "Reuse despawned nodes" in Project Settings, then the node will be saved and
  reused when the same scene needs to be spawned later. This makes it
  especially important to clean-up the nodes internal state in
  `_network_despawn()` so that the node is "like new" when reused.

- `play_sound(identifier: String, sound: AudioStream, info: Dictionary = {}) -> void`:
  Plays a sound and records that we played this specific sound on the
  current tick, so that we won't play it again if we re-execute the same
  tick again due to a rollback.
  * `identifier`: A unique identifier for the sound. Only one sound with this
	identifier will be played on the current tick. The common convention is
	to use the node path of the node playing the sound, with some sort of
	"tag" appended, for example:
	```
	SyncManager.play_sound(str(get_path()) + ':shoot', shoot_sound)
	```
  * `sound`: The sound resource to play.
  * `info`: A set of optional parameters, including:
	- `position`: A `Vector2` giving the position the sound should originate
	  from. If omitted, positional audio won't be used.
	- `volume_db`: A `float` giving the volume in decibels.
	- `pitch_scale`: A `float` to scale the pitch.
	- `bus`: The name of the bus to play the sound to. If none is given, the
	  default bus configured in Project Settings will be used.

#### Signals: ####

- `sync_started ()`: Emitted when synchronization has started, as a result of
  calling `SyncManager.start()` on the "host". Even though
  `SyncManager.start()` is only called on the "host", this signal will be
  emitted on _all_ peers.

- `sync_stopped ()`: Emitted when synchronization has stopped for any reason -
  it could be due to an error (in which case "sync_error" will have been
  emitted before this signal) or `SyncManager.stop()` being called locally or
  on the "host".

- `sync_lost ()`: Emitted when this client has gone far enough out of sync with
  the other clients that we need to pause for a period of time and attempt to
  regain synchronization. Your game should show some indication (a message or
  loading icon) to the player so that they know why the match has suddenly
  come to a stop.

- `sync_regained ()`: Emitted if we've managed to regain sync after it had been
  lost. The message or icon your game showed to the player when "sync_lost" was
  emitted should be removed.

- `sync_error (msg: String)`: Emitted when a fatal synchronization error has
  occurred and the match cannot continue. This could be for a number of
  reasons, which will be identified in a human-readable message in `msg`.

- `scene_spawned (name: String, spawned_node: Node, scene: PackedScene, data: Dictionary)`:
  Emitted when a scene is spawned via `SyncManager.spawn()` or re-spawned due
  to a rollback. Connect to this signal when you want to do some setup on a
  scene that was spawned, and you need to ensure that that setup also happens
  if the scene is re-spawned during rollback (you want to do this most of the
  time).

- `scene_despawned (name: String, node: Node)`:
  Emitted when a scene is despawned via `SyncManager.despawn()` or due
  to a rollback. Connect to this signal when you want to do some cleanup on a
  scene that was despawned.

- `interpolation_frame ()`: If interpolation is enabled in Project Settings,
  the work of the `SyncManager` will be split between "tick frames" (where
  input is gathered, rollbacks are performed and ticks are executed) and
  a variable number of "interpolation frames" that happen between them.
  This signal is emitted at the end of each interpolation frame, so that
  you can perform some operations during a frame with more time budget
  to spare (a lot more needs to happen during tick frames).

### 节点类型 ###

此插件包含一些支持回滚的节点类型：

- `NetworkTimer`：`Timer` 节点的替代品。与 `Timer` 不同，它不等待若干秒，而是等待若干 tick（`wait_ticks` 属性）。

  如果 `hash_state` 设置为 false，则计时器的状态不会包含在用于检测状态不匹配的哈希中。如果计时器可能只在单个客户端上运行，而不是在所有客户端上运行，这很有用。

- `NetworkAnimationPlayer`：继承自内置的 `AnimationPlayer`，但只会在每个 tick 前进（而不是随着时间推移），并且支持回滚。

  如果 `auto_reset` 设置为 true，它将在每次加载没有动画播放的状态时自动播放 "RESET" 动画。这有助于防止动画开始，但在回滚时确定它不应该开始，导致动画处于中间状态的问题。

- `NetworkRandomNumberGenerator`：用于以支持回滚的确定性方式生成随机数。在比赛开始时，客户端需要使用相同的种子初始化节点。每次生成随机数时，其内部状态都会以确定性方式更改，使得它在每个客户端上生成的数字序列相同。当回滚发生时，其内部状态将回滚，从而再次生成相同的数字序列。

  避免为游戏中的每个 `NetworkRandomNumberGenerator` 共享种子的一种方法是共享单个 "母种子"，该种子用于一个 `NetworkRandomNumberGenerator`，该生成器生成游戏所需的所有其他种子。我喜欢将此称为 "Johnny Appleseed 方法"，其中 "Johnny" 分发从 "母种子" 生长的种子。只要节点始终以确定性顺序初始化，这就会起作用！

### 虚拟方法 ###

要让节点参与回滚，它必须位于 "network_sync" 组中，这将导致 `SyncManager` 在节点上调用各种虚拟方法：

- `_save_state() -> Dictionary`：返回当前节点状态。执行回滚时，此相同状态将传递给 `_load_state()`。

  _警告：不要将任何 `Reference`、`Object`、`Array` 或 `Dictionary` 放入状态中，除非您可以先复制它们。这是因为稍后更改对象也会更改状态缓冲区中的数据。并且永远不要将 `Node` 放入状态中，而是使用节点路径或其他方式在以后定位正确的节点，因为原始节点可能不再存在。放入状态中的任何 `Object` 都需要在您的 `HashSerializer`（见下文）中提供特殊支持，以防止错误地检测到状态不匹配。_

- `_load_state(state: Dictionary) -> void`：调用以将节点回滚到之前的状态，该状态源自此节点的 `_save_state()` 方法。

- `_interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void`：
  使用从旧状态到新状态插值的值更新节点的当前状态。只有在项目设置中启用了 "插值" 时，才会调用此方法。

- `_get_local_input() -> Dictionary`：返回此节点操作所需的本地输入。这只会在 "网络主节点"（通过 `Node.set_network_master()` 设置） matches the peer id of the current
  client. Not all nodes need input, in fact, most do not. This is used most
  commonly on the node representing a player. This input will be passed into
  `_network_process()`.

- `_predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary`:
  Returns predicted remote input based on the input from the previous tick,
  which may itself be predicted. This will only be called for nodes whose
  "network master" DOES NOT match the peer id of the current client. If this
  method isn't provided, the same input from the last tick will be used as-is.
  This input will be passed into `_network_process()` when using predicted
  input. If `ticks_since_real_input` is negative, we haven't received any remote
  inputs yet, which happens at the very start of the game.

- `_network_process(input: Dictionary) -> void`: Processes this node for the
  current tick. The input will contain data from either `_get_local_input()`
  (if it's real user input) or `_predict_remote_input()` (if it's predicted).
  If this node doesn't implement those methods, it'll always be empty.

  This method is meant to do what `_process()` or `_physics_process()` would
  have done in most other Godot games.

- `_network_preprocess(input: Dictionary) -> void`: Works just like
  `_network_process()` but all the `_network_preprocess()` methods are run
  _before_ all the `_network_process()` methods.

- `_network_postprocess(input: Dictionary) -> void`: Works just like
  `_network_process()` but all the `_network_postprocess()` methods are run
  _after_ all the `_network_process()` methods.

The following methods are only called on scenes that are spawned/de-spawned
using `SyncManager.spawn()` and `SyncManager.despawn()`:

- `_network_spawn_preprocess(data: Dictionary) -> Dictionary`: Pre-processes
  the data passed to `SyncManager.spawn()` before it gets passed to
  `_network_spawn()`. The modified data returned by this method is what will
  get saved in state. This allows passing developer-friendly data to
  `SyncManager.spawn()` and this method can convert it into data that is
  safe to store in state.

  For example, you may pass a `Node` object into `SyncManager.spawn()` and
  this method could convert it into a `String` representing the node path.
  This is important because storing a `Node` in state can cause weird
  problems, because it could continue to change (or even get deleted!) by the
  time that state needs to be loaded again.

- `_network_spawn(data: Dictionary) -> void`: Called when a scene is spawned
  by `SyncManager.spawn()` or in rollback when this node needs to be
  re-spawned (ex. when we rollback to a tick before this node was de-spawned).

- `_network_despawn() -> void`: Called when a node is de-spawned by
  `SyncManager.despawn()` or in rollback when this node needs to be de-spawned
  (ex. when we rollback to a tick before this node was spawned).

### Project settings ###

The recommended way to configure `SyncManager` is via Project Settings
(although, you can change its properties in code at runtime as well).

You can find its project settings under **Network** -> **Rollback**, after the
plugin is enabled.

![Screenshot of "Rollback" section in Project Settings](assets/screenshots/project_settings.png)

- **Max Buffer Size**: The number of state and input frames to keep in the
  buffer. This defines the maximum number of ticks that the game can rollback.
- **Ticks To Calculate Advantage**: The number of ticks that we collect
  advantage calculations from each peer before calculating an average, and
  possibly skipping some frames so that other clients can catch up.
- **Input Delay**: The number of frames of input delay.
- **Ping Frequency**: The number of seconds between each ping.
- **Interpolation**: If enabled, we'll do 1 tick of interpolation. This
  allows the simulation frequency to be set lower than the rendering FPS,
  while still rendering smoothly.

**Limits:**

- **Max Input Frames Per Message**: The maximum number of input frames that
  will be sent in a single message. If there are more input frames, then
  multiple messages will be sent.
- **Max Messages At Once**: The maximum messages that will be sent to one
  peer at a time. If there are more messages, then the middle ones will be
  omitted (so the newest and oldest input frames will be sent).
- **Max Ticks To Regain Sync**: If the clients get out of sync, and they
  don't manage to regain sync after this many ticks have been skipped, then
  `SyncManager` will emit "sync_error" and kill the match.
- **Min Lag To Regain Sync**: If we've lost sync due to an input buffer
  underrun, then `SyncManager` won't start running again until the minimum
  lag with all clients is above this value. This is to prevent the game
  immediately losing sync right after it has regained it, meaning it will
  pause a slightly longer time, to avoid a series of smaller pauses.
- **Max State Mismatch Count**: If more than this many state mismatches are
  detected in a row, it's considered a fatal state mismatch, and
  `SyncManager` will emit "sync_error" and kill the match.

**Spawn Manager:**

- **Reuse Despawned Nodes**: If enabled, de-spawned nodes will be reused
  rather than instancing the scene every time. This is can provide a large
  performance boost in games that do a lot of spawning, but it requires the
  developer to carefully reset state during `_network_despawn()`.

**Sound Manager:**

- **Default Sound Bus**: The name of the default sound bus to use when
  playing sounds via `SyncManager.play_sound()`. If omitted, then "Master"
  will be used.

**Classes:**

These are all paths to classes that override the default implementations of
the "Adaptor classes" described in the section of the same name below.

If any are omitted, then the default implementation will be used.

**Debug:**

*WARNING: Do not keep these settings enabled in the release version of your
game!*

- **Rollback Ticks**: If set, every tick, the game will rollback at least the
  number of ticks given here. This is a great setting to have enabled when
  implementing new game logic, as some problems won't be apparent until
  a series of rollbacks occur.
- **Random Rollback Ticks**: If set, every tick, the game will rollback a
  random number of ticks up to the given value. This can help find bugs that
  only appear when two clients rollback a different number of ticks when
  executing the same logic.  If "Rollback Ticks" is also set, it will
  effectively set a minimum value.
- **Message Bytes**: If any message exceeds the given number of bytes, an
  error will be pushed to the editor and console, including the size of the
  offending message.
- **Skip Nth Message**: If set, every nth message will not be sent. This is a
  quick way to simulate packet loss, but it isn't very accurate. System-level
  tools or a proxy that simulates packet loss will always make for more
  accurate testing.
- **Physics Process Msecs**: If `SyncManager._physics_process()` takes more
  than this many milliseconds, then an error will be pushed to the editor and
  console, including how long it actually took.
- **Process Msecs**: If `SyncManager._process()` takes more than this many
  milliseconds, then an error will be push to the editor and console,
  including how long it actually took.

**Log Inspector:**

- **Replay Match Scene Path**: The path to the scene to load when launching
  the game as a replay client.
- **Replay Match Scene Method**: The method on the above scene to call in
  order to setup the match to run as a replay. While this method can be named
  anything, it must accept the following arguments (in this order):
  - `my_peer_id: int`: The peer id that the replay client will be displaying.
  - `peer_ids: Array`: An array of the other peer ids in the match.
  - `match_info: Dictionary`: The `match_info` Dictionary that was passed to
	`SyncManager.start_logging()` when creating the log that we are replaying
	from. This should be used to initialize the match to the same state as
	the match that was logged.
- **Replay Arguments**: The arguments to pass to the game on the command-line
  when launching it as a replay client.
- **Replay Port**: The TCP port used by the Godot editor to communicate with
  the replay client.

#### Other important settings not under "Rollback": ####

- **Physics** -> **Common** -> **Physics FPS**: Since `SyncManager` uses
  `_physics_process()` to run tick frames, this controls the simulation
  frequency. If you're using interpolation, it's best if this value can
  evenly divide the rendering FPS, for example, if rendering at 60 fps,
  then 60, 30, 20, or 10 are all good values.

### Adaptor classes ###

There are a few adaptor classes that can be used to modify the behavior of
`SyncManager`.

#### `NetworkAdaptor` ####

All network communication from `SyncManager` passes through its
`NetworkAdaptor`. The default implementation uses Godot RPCs.

You can replace the network adaptor with your own class, in order to
customize network communications. This could even allow you to avoid using
Godot's High-level Multiplayer API in favor of some other underlying
communication layer, for example,
[Steam's peer-to-peer networking](https://partner.steamgames.com/doc/features/multiplayer/networking).

**Parent class:** `res://addons/godot-rollback-netcode/NetworkAdaptor.gd`

**Default implementation:** `res://addons/godot-rollback-network/RPCNetworkAdaptor.gd`

**Additional implementations:**

- `res://addons/godot-rollback-network/NakamaWebRTCNetworkAdaptor.gd`:
  Integrates with the
  [WebRTC and Nakama addon for Godot](https://gitlab.com/snopek-games/godot-nakama-webrtc).

- `res://addons/godot-rollback-network/DummyNetworkAdaptor.gd`:
  Allows using the addon without any real networking. It's used by the replay
  system in Log Inspector, and can also be used to implement an offline mode
  in your game - see the demo project for an example of how to do this.

#### `MessageSerializer` ####

The message serializer will convert input messages to bytes for sending to
the other clients.

The default implementation is relatively wasteful (it will likely lead to
messages exceeding the [MTU](https://en.wikipedia.org/wiki/Maximum_transmission_unit))
so you will **ALMOST ALWAYS** want to replace it with your own implementation
that can pack the data as small as possible. This can only be done by knowing
the structure and meaning of the data, which is why the game developer needs
to do it.

**Parent class and default implementation:** `res://addons/godot-rollback-netcode/MessageSerializer.gd`

#### `HashSerializer` ####

The hash serializer will convert state or input into primitive types so that
we can hash the Dictionary for use in comparisons. It is also used to convert
*back* from these primitive types in the "Log inspector" tool.

The default implementation can't handle `Object`s in a smart way, so if you
include any in your input or state, it could lead to `SyncManager` detecting
a false state or input mismatch. Replace this with your own implementation to
convert any of your objects into primitive types.

**Parent class and default implementation:** `res://addons/godot-rollback-netcode/HashSerializer.gd`

### "Log Inspector" tool in Godot editor: ###

The "Log Inspector" can be opened by clicking **Project** -> **Tools** ->
**Log inspector...** in the Godot editor.

It allows you to load the logs (generated by `SyncManager.start_logging()`)
from all the clients in a match and examine the data in detail.

**Note:** Each client generates its own seperate log file for the match, so
you'll need to collect them from the other players, and open ALL of them in
the "Log Inspector" together.

At the top there is a view selector which lets you switch between a "Frame"
and a "State/Input" view of the data.

#### Frame viewer: ###

![Screenshot of the "Frame viewer" in the "Log Inspector" tool in the Godot editor](assets/screenshots/log_inspector_frame.png)

The "Frame" viewer shows data about each frame executed, including tick
frames, interpolation frames and skipped frames. The x-axis is milliseconds
since the match began. It uses the system clock of the computer the client
ran on, so data may not be line up correctly. You can correct for this
by adding or subtracting milliseconds from each peer in the "Settings" dialog.

You can click anywhere on the graph, and it will show all the data logged on
the most recent frame for each client in the lower part of the window. This
data includes timing information, the number of rollbacks executed, messages
received and much more.

If you click the "Previous frame" or "Next frame" buttons, the cursor will
move forward or backward to the next frame on any peer. However, if "Seek only
on replay peer" is checked, it'll only jump to the next or previous frame
on the peer selected in the dropdown in the replay toolbar.

The arrows connect from the tick when input was generated, to the frame when
the other peer receives that input. This gives a visual representation of the
network traffic between those two peers. The pair of peers can be selected in
the "Settings" dialog.

The orange line represents the number of rollbacks performed on a given
"tick frame", allowing you to easily see how many mispredictions occurred
and during which portions of the match.

#### State/Input viewer: ####

![Screenshot of the "State/Input viewer" in the "Log Inspector" tool in the Godot editor](assets/screenshots/log_inspector_state_input.png)

The "State/Input" viewer allows you to look at the final state and input on
every tick in the match.

If there are any input or state mismatches (where one or more clients
recorded state or input that was different than the other clients), the
differences will be shown on the right side of the window.

Using the "Previous mismatch" or "Next mismatch" buttons, you can jump to the
previous or next mismatch found in the data.

You are likely to spend a large amount of time chasing down issues in your
game logic that lead to state mismatches. Input mismatches are much rarer,
but they are a super critical problem if they do occur.

#### How to setup replay ####

The "Log Inspector" can allow you to replay the match from the logs, by either
loading state (in the "State/Input viewer") or re-executing frames (in the
"Frame viewer").

This can be very helpful in debugging issues, by allowing you to visually
_see_ the state on a particular peer, when there is a state mismatch, or
re-execute frames as they happened during a match with breakpoints set in the
Godot debugger.

This works by launching a special instance of the game (called a "replay
client") which connects to the "Log Inspector" via a TCP port (this component
is called the "replay server").

However, there is a little bit of setup required to allow your game to
support this:

1. Add the `res://addons/godot-rollback-netcode/SyncReplay.gd` script as an
   autoload singleton in **Project** -> **Project settings...** and the
   "Autoload" tab.

2. Pass a `match_info` Dictionary to `SyncManager.start_logging()` with
   enough info to setup the match for replay.

3. Ensure that your game _doesn't_ do any logging when launched as a replay
   client. You can do this by checking if `SyncReplay.active` is true.

4. Set "Replay Match Scene Path" in "Project settings" to the match scene
   to load when showing a replay. Frequently, my games have a "Match.tscn"
   that runs the match when played normally, so this is also what's used for
   showing a replay, but you could create a unique replay scene as well.

5. Set "Replay Match Scene Method" in "Project settings" to the method on
   the scene set in the previous step, which will be able to setup the match
   to show the replay using the `match_info` from step number 2. Its
   implementation will look something like:
   ```
   func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
	 # Setup the match using 'match_info' and disable anything we don't
	 # want or need during replay.
	 pass
   ```
   For more details on the individual arguments, see what the "Project
   Settings" section above says about this setting.

6. (Optional) If you have a custom `HashSerializer`, ensure that it can
   unserialize any of the custom data it serializes, since this is what will
   be used to load the state and input data from the logs.

After completing all of these steps, you should be able to click the "Launch"
button on the replay toolbar in the "Log Inspector" and see your game launch
as a replay client. Then, in the "State/Input viewer", if you view a
particular tick, it should load the state from that tick in the replay client.

You can use the dropdown on the replay toolbar to configure which peer's data
you would like to use in the replay.

#### Manually reading log files ####

Starting with v1.0.0-alpha8, the log files are stored in a binary format.
However, a script is included in the addon to convert them to JSON, so that
humans or external tools can read them, if necessary.

You can run it like this:

```
godot --no-window --script addons/godot-rollback-netcode/log2json.gd --input=INPUT.log --output=OUTPUT.json
```

... replacing INPUT.log with a full path to the log file, and OUTPUT.json with
a path to the JSON file that will be created.

The most common "match flow"
----------------------------

While there's sure to be edge cases, this is this most common "match flow", or
the process your game goes through to start, play and stop a match using this
addon:

1. Get all players connected via Godot's
   [High-Level Multiplayer API](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html).

2. Call `SyncManager.add_peer()` for each peer in the match.

3. Initialize the match to its initial state on all clients. Sharing match
   configuration and letting the "host" know when each client is ready to
   start can be done using Godot's RPC mechanism. Make sure that all nodes
   representing players have their "network master" set (via
   `set_network_master()`) to the peer id of the client that is local for that
   player, so that the virtual `_get_local_input()` and
   `_predict_remote_input()` methods will be called.

4. Call `SyncManager.start()` on the "host".

5. Begin the match in all clients in response to the "sync_started" signal.

6. When the match is over, call `SyncManager.stop()` on the "host". (If a
   client needs to leave the match early, they should inform the other
   clients via an RPC or some other mechanism, and then call
   `SyncManager.stop()` locally.)

7. Clean-up after the match in all clients in response to the "sync_stopped"
   signal.

8. If these same players wish to play another match (which can be worked out
   over RPC), then return to step number 2.

9. If this client wishes to disconnect from these players entirely, call
   `SyncManager.clear_peers()` and disconnect from the High-Level Multiplayer
   API, possibly via `get_tree().multiplayer.close_connection()` (with ENet)
   or `get_tree.multiplayer.close()` (with WebRTC).

It's also a good idea to connect to the "sync_lost", "sync_regained" and
"sync_error" signals so you can provide the player with useful error messages
if something goes wrong.

If you are logging, you'll want to call `SyncManager.start_logging()` sometime
before calling `SyncManager.start()` (but after all match setup is complete)
or in response to the 'sync_started' signal, and call
`SyncManager.stop_logging()` just after calling `SyncManager.stop()` or in
response to the 'sync_stopped' signal. The logs are meant to contain data from
just a single match, which is what the "Log inspector" tool will expect.

Logo credits
------------

The logo is composed of these images:

- https://pxhere.com/en/photo/1451861 (License: CC0)
- https://godotengine.org/press (License: CC-BY-4.0 by Andrea Calabró)

License
-------

Copyright 2021-2022 Cerbere Games.

Original Copyright 2021-2022 David Snopek. (Licensed under the [MIT License](LICENSE.txt))

Licensed under the [MIT License](LICENSE.txt).
