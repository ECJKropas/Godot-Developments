# 战场构造指南
## 数据加载
仿照test.tscn，在battle_field.tscn中加载数据。
类似的，加载all effects、all skills、all mechanics。

**与以往不同的是，角色的加载分别从 `user://my_characters.json` 中加载。如果该文件不存在，就先复制 `res://defaultCardSuit.json` 到 `user://my_characters.json`，然后加载。**

同理，enemy的加载分别从 `user://enemy_characters.json` 中加载。如果该文件不存在，就先复制 `res://defaultCardSuit.json` 到 `user://enemy_characters.json`，然后加载。

你需要创建一个函数用来加载单个角色，然后加载文件中的所有角色。默认情况下，一开始的focus给到第一个我方角色。

## 2D部分
将所有角色加载到 `CharacterManager` 节点下，以方便管理。

这里，你需要实现focus机制。

你想要在Godot 2D的Battle Arena游戏中实现这样的focus机制：玩家操控当前角色时，先选定敌方/目标对象，按下Q/E等技能键后，角色会先移动到目标位置（而非原地），到达后再释放对应技能。这个机制的核心是**目标锁定 + 移动到目标 + 到达判定 + 技能释放** 的流程，我会用Godot 4.x（2D）帮你完整实现这个逻辑。

---

### 一、核心实现思路
1. **节点结构准备**：角色用`CharacterBody2D`作为根节点，包含碰撞体、精灵、技能相关节点；
2. **目标锁定**：通过鼠标点击检测敌方角色，记录当前锁定的`focus_target`；
3. **技能触发逻辑**：按下技能键时，先判断是否有锁定目标，若有则启动“移动到目标”流程；
4. **到达判定**：角色移动到目标附近（设置距离阈值，避免重叠）后，触发技能释放；
5. **状态管理**：标记角色是否处于“移动到目标”状态，避免重复触发。

---

### 二、完整代码实现
#### 1. 角色核心脚本（PlayerCharacter.gd）
将此脚本挂载到玩家角色的`CharacterBody2D`节点上，敌方角色只需标记`group = "enemies"`即可。

```gdscript
extends CharacterBody2D

# 核心配置
@export var move_speed: float = 300.0          # 角色移动速度
@export var target_distance_threshold: float = 64.0  # 到达目标的距离阈值（避免重叠）
@export var skill_cooldown: float = 1.0        # 技能冷却时间

# 状态变量
var focus_target: CharacterBody2D = null       # 当前锁定的目标
var is_moving_to_target: bool = false          # 是否正在移动到目标
var is_skill_cooldown: bool = false            # 技能是否在冷却

# 输入映射（需在Godot项目设置→输入映射中添加）：
# - focus_target（鼠标左键）：锁定目标
# - skill_q（Q键）：释放Q技能
# - skill_e（E键）：释放E技能

func _physics_process(delta: float) -> void:
    # 1. 常规移动（如果不是“移动到目标”状态）
    if not is_moving_to_target:
        handle_normal_movement(delta)
    # 2. 移动到目标的逻辑（优先级高于常规移动）
    else:
        handle_move_to_target(delta)

func _input(event: InputEvent) -> void:
    # 1. 锁定目标：鼠标左键点击敌方
    if event.is_action_just_pressed("focus_target"):
        lock_target()
    # 2. 触发技能Q
    if event.is_action_just_pressed("skill_q") and focus_target and not is_skill_cooldown:
        trigger_skill("skill_q")
    # 3. 触发技能E
    if event.is_action_just_pressed("skill_e") and focus_target and not is_skill_cooldown:
        trigger_skill("skill_e")

# 常规移动逻辑（WSAD/方向键）
func handle_normal_movement(delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir.normalized() * move_speed
    move_and_slide()

# 移动到目标的逻辑
func handle_move_to_target(delta: float) -> void:
    # 目标不存在则停止移动
    if not focus_target or focus_target.is_queued_for_deletion():
        is_moving_to_target = false
        return
    
    # 计算角色到目标的方向和距离
    var direction: Vector2 = (focus_target.global_position - global_position).normalized()
    var distance: float = global_position.distance_to(focus_target.global_position)
    
    # 到达目标阈值内：停止移动，释放技能
    if distance <= target_distance_threshold:
        velocity = Vector2.ZERO
        is_moving_to_target = false
        release_skill(current_skill_type)  # 释放技能
    # 未到达：向目标移动
    else:
        velocity = direction * move_speed
        move_and_slide()

# 锁定目标（鼠标点击检测）
func lock_target() -> void:
    # 获取鼠标在世界中的位置
    var mouse_pos: Vector2 = get_global_mouse_position()
    # 检测鼠标位置的碰撞体（只检测敌方组）
    var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
    query.position = mouse_pos
    query.collision_mask = 1  # 确保敌方角色的碰撞层和此mask匹配
    var results: Array = get_world_2d().direct_space_state.intersect_point(query)
    
    # 遍历检测结果，找到敌方角色
    for result in results:
        var body: CharacterBody2D = result.get("collider")
        if body and body.is_in_group("enemies"):
            focus_target = body
            print("锁定目标：", focus_target.name)
            return
    # 未找到目标则清空
    focus_target = null
    print("未锁定任何目标")

# 触发技能（先移动到目标，再释放）
var current_skill_type: String = ""  # 记录当前要释放的技能类型
func trigger_skill(skill_type: String) -> void:
    if not focus_target or is_moving_to_target or is_skill_cooldown:
        return
    
    current_skill_type = skill_type
    is_moving_to_target = true
    print("开始移动到目标，准备释放", skill_type)

# 释放技能（到达目标后执行）
func release_skill(skill_type: String) -> void:
    if is_skill_cooldown or not focus_target:
        return
    
    # 标记技能冷却
    is_skill_cooldown = true
    await get_tree().create_timer(skill_cooldown).timeout
    is_skill_cooldown = false
    
    # 根据技能类型执行不同逻辑
    match skill_type:
        "skill_q":
            print("释放Q技能，攻击目标：", focus_target.name)
            # 这里添加Q技能的具体逻辑（比如播放动画、扣血、生成特效等）
        "skill_e":
            print("释放E技能，攻击目标：", focus_target.name)
            # 这里添加E技能的具体逻辑
    print(skill_type, "释放完成，冷却剩余：", skill_cooldown, "秒")

# 辅助：绘制调试信息（方便开发时查看）
func _draw() -> void:
    # 绘制目标锁定线（如果有目标）
    if focus_target:
        draw_line(Vector2.ZERO, focus_target.global_position - global_position, Color(1, 0, 0))
        # 绘制距离阈值圆圈
        draw_circle(Vector2.ZERO, target_distance_threshold, Color(0, 1, 0, 0.5))
```

#### 2. 项目配置补充
你需要在Godot中完成以下配置，确保代码能正常运行：
1. **输入映射**：
   - 打开`项目 → 项目设置 → 输入映射`；
   - 添加`focus_target`：绑定鼠标左键（Mouse Button Left）；
   - 添加`move_left`：绑定A键/左方向键；
   - 添加`move_right`：绑定D键/右方向键；
   - 添加`move_up`：绑定W键/上方向键；
   - 添加`move_down`：绑定S键/下方向键；
   - 添加`skill_q`：绑定Q键；
   - 添加`skill_e`：绑定E键。
2. **敌方角色配置**：
   - 将敌方角色的`CharacterBody2D`节点添加到`enemies`组（右键节点→添加到组→输入enemies）；
   - 确保敌方角色的碰撞体（如`CollisionShape2D`）启用，且碰撞层/掩码和玩家角色匹配。

---

### 三、关键逻辑解释
1. **目标锁定（lock_target函数）**：
   - 通过`PhysicsPointQuery2D`检测鼠标点击位置的碰撞体，只筛选`enemies`组的对象作为目标；
   - 锁定后会打印目标名称，开发时可通过`_draw`函数看到红色锁定线和绿色阈值圆圈，方便调试。

2. **移动到目标（handle_move_to_target函数）**：
   - 计算角色到目标的方向，向目标移动；
   - 设置`target_distance_threshold`（比如64像素），避免角色和目标重叠，到达阈值后停止移动并释放技能。

3. **技能触发与冷却**：
   - 按下Q/E时，先检查是否有目标、是否在移动/冷却，避免重复触发；
   - 技能释放后启动冷却，防止短时间内多次释放。

4. **状态优先级**：
   - “移动到目标”状态优先级高于常规移动，确保角色优先完成技能流程。

---

### 四、扩展建议（可选）
1. **目标丢失处理**：如果目标死亡/消失，自动清空`focus_target`，并停止移动；
2. **技能动画**：在`release_skill`中添加动画播放（如`$AnimationPlayer.play("skill_q")`）；
3. **范围技能**：如果是范围技能，可将`target_distance_threshold`设为技能有效范围；
4. **切换角色**：若要实现多角色切换，只需维护一个“当前操控角色”变量，将focus机制逻辑复用即可。

---

### 总结
1. 该focus机制的核心是**先锁定目标→移动到目标（阈值判定）→释放技能** 的流程，通过`is_moving_to_target`状态避免重复操作；
2. `target_distance_threshold`是关键参数，既避免角色与目标重叠，也能适配不同技能的释放距离；
3. 代码中分离了“常规移动”和“技能移动”逻辑，保证操控的优先级和流畅性，且预留了技能动画、冷却等扩展空间。

你可以直接复制代码到Godot中，按配置步骤完成输入映射和敌方分组，就能快速测试这个focus机制了。如果需要调整某个细节（比如技能逻辑、移动方式），可以随时告诉我。


## UI部分
该部分所有节点都位于`control`节点下。
将原有的一些必要日志转移到`logplace`节点中。

实时更新`PlayerBasics`节点中的信息。它显示的是当前focus的角色的信息。

注意看`ExampleEffectBackground`节点，它只是一个示例，实际上应当通过`EffectDisplayManager`节点来管理所有特效显示，并用代码生成
