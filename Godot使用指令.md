# Godot 使用指令

本文档整理自 Godot 官方文档和社区教程，涵盖了 Godot 引擎的基础用法和常用内置类的使用方法。

---

## 目录

1. [核心概念](#核心概念)
2. [编辑器基础](#编辑器基础)
3. [节点系统](#节点系统)
4. [场景系统](#场景系统)
5. [GDScript 基础](#gdscript-基础)
6. [常用内置类](#常用内置类)
7. [信号系统](#信号系统)
8. [场景树操作](#场景树操作)
9. [常用 API 和方法](#常用-api-和方法)
10. [2D 游戏开发要点](#2d-游戏开发要点)

---

## 核心概念

### 节点（Node）

节点是 Godot 中最基本的构建单元，所有游戏对象都是节点。节点以树状结构组织，形成场景树（Scene Tree）。

**节点特性**：
- 节点可以包含子节点，形成层次结构
- 每个节点都有唯一名称
- 节点有生命周期方法（`_ready()`, `_process()`, `_physics_process()`）
- 节点可以附加脚本（GDScript、C# 等）

### 场景（Scene）

场景是一个保存的节点树，是游戏的基本单元。场景可以嵌套（实例化其他场景作为子节点）。

**场景特性**：
- 场景文件扩展名：`.tscn`（2D场景）或 `.scn`（3D场景）
- 场景可以作为节点树保存和加载
- 场景可以实例化到其他场景中（复用）
- 主场景是游戏启动时自动加载的场景

### 场景树（Scene Tree）

场景树是运行时的节点层次结构，从根节点开始，包含所有已加载的场景和节点。

**场景树特点**：
- 根节点是 `Main`（自动创建）
- 通过 `get_tree()` 可以访问场景树
- 场景树负责节点生命周期管理
- 节点必须添加到场景树才能运行

---

## 编辑器基础

### 界面布局

**主要面板**：
- **场景面板**：左侧，显示节点树
- **文件系统**：左侧底部，显示项目文件
- **检查器面板**：右侧，显示选中节点的属性
- **视口**：中央，2D/3D 视图
- **底部面板**：输出、调试、动画等

### 常用快捷键

| 操作          | 快捷键   | 说明               |
| ------------- | -------- | ------------------ |
| 运行场景      | `F5`     | 运行当前场景       |
| 运行项目      | `F6`     | 运行主场景         |
| 停止运行      | `F7`     | 停止运行           |
| 切换脚本/场景 | `F3`     | 在脚本和场景间切换 |
| 搜索节点      | `Ctrl+F` | 在场景中搜索       |
| 查看文档      | `F1`     | 打开帮助文档       |
| 复制节点      | `Ctrl+D` | 复制选中节点       |
| 删除节点      | `Delete` | 删除选中节点       |
| 保存场景      | `Ctrl+S` | 保存当前场景       |

### 场景操作

1. **添加节点**：在场景面板点击 `+` 按钮，或按 `Ctrl+A`
2. **选中节点**：在场景面板或视口中点击
3. **重命名节点**：选中后按 `F2` 或双击名称
4. **移动节点**：拖拽节点改变父子关系
5. **复制节点**：选中后按 `Ctrl+D` 或右键菜单

---

## 节点系统

### 节点生命周期

节点在场景树中的生命周期方法：

**`_ready()`**：
- 节点首次进入场景树时调用一次
- 用于初始化操作
- 此时子节点已准备好

**`_process(delta)`**：
- 每帧调用
- `delta` 是上一帧到当前帧的时间间隔（秒）
- 用于帧率相关的逻辑

**`_physics_process(delta)`**：
- 每物理帧调用（通常 60 FPS）
- `delta` 是固定的物理时间步长
- 用于物理相关逻辑

**`_exit_tree()`**：
- 节点离开场景树时调用
- 用于清理操作

### 节点属性访问

**通过路径访问**：
```gdscript
# 通过节点路径访问
var child = get_node("子节点名称")
var grandchild = get_node("子节点名称/孙节点名称")

# 使用 $ 快捷语法
var child = $子节点名称
var grandchild = $子节点名称/孙节点名称
```

**通过查找访问**：
```gdscript
# 查找子节点
var child = find_child("节点名称", true, false)

# 查找父节点
var parent = get_parent()

# 查找根节点
var root = get_tree().root
```

**节点存在性检查**：
```gdscript
# 检查节点是否存在
if has_node("子节点名称"):
    var node = get_node("子节点名称")
```

---

## 场景系统

### 场景实例化

**在代码中加载场景**：
```gdscript
# 加载场景资源
var scene = preload("res://path/to/scene.tscn")

# 或运行时加载
var scene = load("res://path/to/scene.tscn")

# 实例化场景
var instance = scene.instantiate()

# 添加到场景树
add_child(instance)
```

**场景切换**：
```gdscript
# 切换到新场景
get_tree().change_scene_to_file("res://path/to/scene.tscn")

# 或使用 PackedScene
var scene = preload("res://path/to/scene.tscn")
get_tree().change_scene_to_packed(scene)
```

### 场景保存和加载

**保存场景状态**：
- 场景文件（`.tscn`）自动保存节点树结构
- 节点属性值保存在场景文件中
- 脚本附加在节点上

**运行时加载**：
```gdscript
# 保存场景引用
var saved_scene = get_tree().current_scene

# 加载场景
get_tree().change_scene_to_file("res://scene.tscn")
```

---

## GDScript 基础

### 脚本语法

**基本结构**：
```gdscript
extends Node  # 继承自 Node 类

# 类变量
var speed = 100
var direction = Vector2(1, 0)

# 常量
const MAX_HEALTH = 100

# 信号定义
signal health_changed(new_health)

# 节点引用
@onready var sprite = $Sprite2D
```

### 变量和类型

**类型声明**：
```gdscript
# 显式类型
var health: int = 100
var velocity: Vector2 = Vector2.ZERO
var is_alive: bool = true

# 类型推断
var name = "Player"  # String
var count = 5        # int
var ratio = 3.14     # float
```

**常用类型**：
- `int`：整数
- `float`：浮点数
- `String`：字符串
- `bool`：布尔值
- `Vector2`：2D 向量
- `Vector3`：3D 向量
- `Array`：数组
- `Dictionary`：字典

### 函数定义

```gdscript
# 普通函数
func move(direction: Vector2):
    position += direction * speed * delta

# 带返回值
func get_health() -> int:
    return health

# 带参数默认值
func attack(target: Node, damage: int = 10):
    # 攻击逻辑
    pass
```

### 继承和扩展

```gdscript
# 继承自特定类
extends CharacterBody2D

# 调用父类方法
func _ready():
    super._ready()  # 调用父类的 _ready()
```

---

## 常用内置类

### Node 类

所有节点的基类，提供基本功能。

**常用属性**：
- `name`：节点名称
- `scene_file_path`：场景文件路径
- `owner`：场景所有者

**常用方法**：
- `add_child(node)`：添加子节点
- `remove_child(node)`：移除子节点
- `get_child(index)`：获取子节点
- `get_children()`：获取所有子节点
- `get_parent()`：获取父节点
- `get_tree()`：获取场景树

### Node2D 类

2D 节点的基类，提供 2D 变换。

**常用属性**：
- `position`：位置（Vector2）
- `rotation`：旋转角度（弧度）
- `scale`：缩放（Vector2）
- `global_position`：全局位置
- `global_rotation`：全局旋转

**常用方法**：
- `look_at(target)`：朝向目标
- `to_local(global_pos)`：全局坐标转本地坐标
- `to_global(local_pos)`：本地坐标转全局坐标

### Sprite2D 类

用于显示 2D 纹理精灵。

**常用属性**：
- `texture`：纹理资源
- `modulate`：颜色调制
- `flip_h`：水平翻转
- `flip_v`：垂直翻转

### CharacterBody2D 类

用于 2D 角色控制（Godot 4.x）。

**常用属性**：
- `velocity`：速度向量
- `max_slides`：最大碰撞滑动次数

**常用方法**：
- `move_and_slide()`：移动并处理碰撞
- `move_and_collide()`：移动并检测碰撞

**示例**：
```gdscript
extends CharacterBody2D

var speed = 200

func _physics_process(delta):
    var direction = Vector2.ZERO
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1
    
    velocity = direction.normalized() * speed
    move_and_slide()
```

### Area2D 类

用于检测区域，常用于触发器、拾取物等。

**常用属性**：
- `monitoring`：是否监控碰撞
- `monitorable`：是否可被监控

**常用信号**：
- `body_entered(body)`：物体进入区域
- `body_exited(body)`：物体离开区域
- `area_entered(area)`：区域进入区域
- `area_exited(area)`：区域离开区域

**示例**：
```gdscript
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    print("物体进入：", body.name)

func _on_body_exited(body):
    print("物体离开：", body.name)
```

### CollisionShape2D / CollisionPolygon2D 类

用于定义碰撞形状。

**常用属性**：
- `shape`：碰撞形状资源
- `disabled`：是否禁用碰撞

### Timer 类

定时器节点，用于延迟和重复执行。

**常用属性**：
- `wait_time`：等待时间（秒）
- `one_shot`：是否只执行一次
- `autostart`：是否自动启动

**常用信号**：
- `timeout`：时间到达时触发

**常用方法**：
- `start()`：启动定时器
- `stop()`：停止定时器
- `is_stopped()`：检查是否停止

**示例**：
```gdscript
extends Node

@onready var timer = $Timer

func _ready():
    timer.wait_time = 2.0
    timer.one_shot = false
    timer.timeout.connect(_on_timer_timeout)
    timer.start()

func _on_timer_timeout():
    print("定时器触发")
```

### AnimationPlayer 类

动画播放器，用于播放动画。

**常用方法**：
- `play(name)`：播放动画
- `stop()`：停止动画
- `queue(name)`：队列播放动画
- `is_playing()`：检查是否正在播放

**常用属性**：
- `current_animation`：当前动画名称
- `speed_scale`：播放速度倍数

### Tween 类

补间动画系统（Godot 4.x）。

**示例**：
```gdscript
extends Node2D

func fade_out():
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 1.0)
    tween.tween_callback(queue_free)
```

### Input 类

输入系统，用于处理键盘、鼠标输入。

**常用方法**：
- `is_action_pressed(action)`：动作是否按下
- `is_action_just_pressed(action)`：动作是否刚按下
- `is_action_just_released(action)`：动作是否刚释放
- `get_vector()`：获取方向向量

**常用属性**：
- `mouse_position`：鼠标位置（全局坐标）

### ResourceLoader 类

资源加载器。

**常用方法**：
- `load(path)`：加载资源
- `exists(path)`：检查资源是否存在

---

## 信号系统

### 信号定义和发射

**定义信号**：
```gdscript
extends Node

# 定义信号
signal health_changed(new_health)
signal player_died
signal item_collected(item_name, count)
```

**发射信号**：
```gdscript
func take_damage(amount):
    health -= amount
    health_changed.emit(health)  # 发射信号
    
    if health <= 0:
        player_died.emit()
```

### 信号连接

**在代码中连接**：
```gdscript
func _ready():
    # 连接信号到方法
    health_changed.connect(_on_health_changed)
    
    # 连接信号到其他节点的方法
    $OtherNode.signal_name.connect(_on_signal)
    
    # 使用 Callable 连接
    health_changed.connect(func(new_health): print("生命值：", new_health))
```

**在编辑器中连接**：
1. 选中发出信号的节点
2. 在检查器面板找到"节点"标签页
3. 双击信号名称
4. 选择目标节点和方法

**断开连接**：
```gdscript
health_changed.disconnect(_on_health_changed)
```

### 常用内置信号

**Timer 信号**：
- `timeout`：定时器到期

**Area2D 信号**：
- `body_entered(body)`：物体进入区域
- `body_exited(body)`：物体离开区域
- `area_entered(area)`：区域进入区域
- `area_exited(area)`：区域离开区域

**Button 信号**：
- `pressed()`：按钮被按下
- `button_down()`：按钮按下时
- `button_up()`：按钮释放时

**CharacterBody2D 信号**：
- `moved()`：移动完成时触发

---

## 场景树操作

### 获取场景树

```gdscript
# 获取场景树
var tree = get_tree()

# 获取根节点
var root = get_tree().root

# 获取当前场景
var current_scene = get_tree().current_scene
```

### 场景树遍历

```gdscript
# 遍历所有节点（递归）
func traverse_tree(node: Node):
    print(node.name)
    for child in node.get_children():
        traverse_tree(child)

# 查找所有特定类型的节点
func find_nodes_by_type(type: String):
    var found = []
    func _find(node: Node):
        if node.get_class() == type:
            found.append(node)
        for child in node.get_children():
            _find(child)
    _find(get_tree().root)
    return found
```

### 场景树操作

**添加节点**：
```gdscript
# 添加子节点
var child = Node.new()
child.name = "NewNode"
add_child(child)

# 添加到指定位置
add_child(child, true)  # force_readable_name = true
move_child(child, 0)    # 移动到第一个位置
```

**移除节点**：
```gdscript
# 移除子节点
remove_child(node)

# 从场景树中移除并释放
node.queue_free()

# 立即释放（谨慎使用）
node.free()
```

**节点查询**：
```gdscript
# 获取所有子节点
var children = get_children()

# 根据名称查找子节点
var child = get_node_or_null("ChildName")

# 查找所有子孙节点
var all_descendants = []
func collect_descendants(node: Node):
    for child in node.get_children():
        all_descendants.append(child)
        collect_descendants(child)
```

---

## 常用 API 和方法

### Math 和 Vector 操作

**Vector2 常用方法**：
```gdscript
var v1 = Vector2(10, 20)
var v2 = Vector2(5, 10)

# 向量运算
var sum = v1 + v2          # 加法
var diff = v1 - v2         # 减法
var scaled = v1 * 2.0      # 缩放
var dot = v1.dot(v2)       # 点积
var cross = v1.cross(v2)   # 叉积

# 向量属性
var length = v1.length()           # 长度
var normalized = v1.normalized()   # 归一化
var angle = v1.angle()             # 角度
var distance = v1.distance_to(v2)  # 距离

# 向量常量
var zero = Vector2.ZERO    # (0, 0)
var one = Vector2.ONE      # (1, 1)
var up = Vector2.UP        # (0, -1)
var down = Vector2.DOWN    # (0, 1)
var left = Vector2.LEFT    # (-1, 0)
var right = Vector2.RIGHT  # (1, 0)
```

**数学函数**：
```gdscript
# 角度和弧度转换
var deg_to_rad = deg_to_rad(90.0)  # 度转弧度
var rad_to_deg = rad_to_deg(PI)    # 弧度转度

# 常用数学函数
var abs_val = abs(-5)              # 绝对值
var max_val = max(10, 20)          # 最大值
var min_val = min(10, 20)          # 最小值
var clamped = clamp(value, 0, 100) # 限制范围
var lerped = lerp(start, end, 0.5) # 线性插值

# 随机数
var random = randf()              # 0.0 到 1.0
var random_int = randi()         # 随机整数
var random_range = randf_range(10.0, 20.0)  # 范围内随机
```

### 字符串操作

```gdscript
var text = "Hello World"

# 字符串方法
var length = text.length()              # 长度
var upper = text.to_upper()            # 转大写
var lower = text.to_lower()            # 转小写
var split_result = text.split(" ")      # 分割
var replaced = text.replace("World", "Godot")  # 替换

# 格式化
var formatted = "Health: %d / %d" % [current, max_health]
var padded = str(5).pad_zeros(3)       # "005"
```

### 数组和字典操作

**数组操作**：
```gdscript
var arr = [1, 2, 3, 4, 5]

# 基本操作
arr.append(6)           # 添加元素
arr.insert(0, 0)        # 插入元素
arr.erase(3)            # 移除元素
var size = arr.size()   # 长度
var has = arr.has(3)   # 是否包含

# 数组方法
var filtered = arr.filter(func(x): return x > 2)  # 过滤
var mapped = arr.map(func(x): return x * 2)       # 映射
var reduced = arr.reduce(func(acc, x): return acc + x, 0)  # 归约

# 排序和查找
arr.sort()              # 排序
arr.reverse()           # 反转
var index = arr.find(3) # 查找索引
```

**字典操作**：
```gdscript
var dict = {"name": "Player", "health": 100}

# 基本操作
dict["level"] = 5       # 添加/修改
dict.erase("health")    # 删除
var has_key = dict.has("name")  # 检查键
var keys = dict.keys()  # 获取所有键
var values = dict.values()  # 获取所有值

# 遍历
for key in dict:
    print(key, dict[key])

for key_value in dict:
    var key = key_value[0]
    var value = key_value[1]
```

### 资源加载和管理

**资源加载**：
```gdscript
# 预加载（编译时加载）
var texture = preload("res://textures/sprite.png")
var scene = preload("res://scenes/player.tscn")

# 运行时加载
var texture = load("res://textures/sprite.png")
var scene = load("res://scenes/player.tscn")

# 检查资源是否存在
if ResourceLoader.exists("res://path/to/resource.tres"):
    var resource = load("res://path/to/resource.tres")
```

**资源保存**：
```gdscript
# 保存资源
var resource = Resource.new()
ResourceSaver.save(resource, "res://path/to/resource.tres")
```

### 时间操作

```gdscript
# 获取时间
var current_time = Time.get_ticks_msec()  # 毫秒
var elapsed = Time.get_time_dict_from_system()  # 系统时间字典

# 等待
await get_tree().create_timer(2.0).timeout  # 等待2秒
```

### 调试和日志

```gdscript
# 打印信息
print("普通信息")
prints("打印多个值", value1, value2)  # 自动用空格分隔
print_rich("[color=red]红色文本[/color]")  # 富文本

# 警告和错误
push_warning("警告信息")
push_error("错误信息")

# 断言
assert(condition, "错误信息")  # 仅在调试模式有效

# 断点
breakpoint  # 在调试器中暂停
```

---

## 2D 游戏开发要点

### 坐标系统

**Godot 2D 坐标系统**：
- 原点 `(0, 0)` 位于左上角
- X 轴向右为正
- Y 轴向下为正（与数学坐标系相反）
- 角度：0° 指向右侧，顺时针为正

**坐标转换**：
```gdscript
# 本地坐标转全局坐标
var global_pos = to_global(local_position)

# 全局坐标转本地坐标
var local_pos = to_local(global_position)

# 屏幕坐标转世界坐标
var world_pos = get_global_mouse_position()

# 世界坐标转屏幕坐标（需要 Camera2D）
var screen_pos = camera.get_screen_center_position()
```

### 2D 渲染顺序

**Z-index 和渲染顺序**：
```gdscript
# 设置渲染顺序（越大越靠前）
z_index = 1

# Y-sort（按 Y 坐标排序，用于等距视角）
var ysort = YSort.new()
add_child(ysort)
ysort.add_child(sprite)  # 子节点按 Y 坐标自动排序
```

### 2D 物理和碰撞

**RigidBody2D**（刚体）：
```gdscript
extends RigidBody2D

func _ready():
    # 设置物理属性
    gravity_scale = 1.0
    linear_damp = 0.5
    angular_damp = 0.5
    
func _physics_process(delta):
    # 应用力
    apply_central_force(Vector2(100, 0))
    apply_impulse(Vector2(0, -100))
```

**CharacterBody2D**（角色控制）：
```gdscript
extends CharacterBody2D

var speed = 200
var jump_velocity = -400

func _physics_process(delta):
    # 处理输入
    var direction = Input.get_axis("ui_left", "ui_right")
    
    # 应用重力
    if not is_on_floor():
        velocity.y += get_gravity() * delta
    
    # 跳跃
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
    
    # 移动
    velocity.x = direction * speed
    move_and_slide()
```

**Area2D 碰撞检测**：
```gdscript
extends Area2D

func _ready():
    # 设置碰撞层和遮罩
    collision_layer = 1  # 在第1层
    collision_mask = 2    # 检测第2层的物体
    
    # 连接信号
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
```

### TileMap 系统

**TileMap 基础**：
```gdscript
extends TileMap

func _ready():
    # 获取瓦片位置
    var tile_pos = local_to_map(global_position)
    
    # 设置瓦片
    set_cell(0, tile_pos, 0, Vector2i(0, 0))
    
    # 获取瓦片数据
    var tile_data = get_cell_source_id(0, tile_pos)
    
    # 清除瓦片
    erase_cell(0, tile_pos)
```

### Camera2D 控制

**摄像机跟随**：
```gdscript
extends Camera2D

@export var target: Node2D
@export var smoothing_speed: float = 5.0

func _process(delta):
    if target:
        global_position = global_position.lerp(
            target.global_position, 
            smoothing_speed * delta
        )
```

**摄像机限制**：
```gdscript
extends Camera2D

func _ready():
    # 限制摄像机范围
    limit_left = -1000
    limit_right = 1000
    limit_top = -1000
    limit_bottom = 1000
    
    # 启用边界平滑
    limit_smoothed = true
```

### UI 系统（Control 节点）

**Label 文本显示**：
```gdscript
extends Label

func _ready():
    text = "生命值: 100"
    # 富文本
    text = "[color=red]警告[/color]：生命值过低"
```

**Button 按钮**：
```gdscript
extends Button

func _ready():
    pressed.connect(_on_button_pressed)
    text = "点击我"

func _on_button_pressed():
    print("按钮被点击")
```

**ProgressBar 进度条**：
```gdscript
extends ProgressBar

func _ready():
    min_value = 0
    max_value = 100
    value = 50
    show_percentage = true
```

### 性能优化建议

**对象池**：
```gdscript
extends Node

var bullet_pool = []
var pool_size = 20

func _ready():
    # 预创建对象
    for i in range(pool_size):
        var bullet = preload("res://bullet.tscn").instantiate()
        bullet_pool.append(bullet)

func get_bullet():
    for bullet in bullet_pool:
        if not bullet.is_inside_tree():
            return bullet
    return null
```

**节点复用**：
```gdscript
# 使用 queue_free() 而不是 free()
node.queue_free()  # 安全释放，在帧末执行

# 禁用不需要的节点
node.process_mode = Node.PROCESS_MODE_DISABLED
```

**批量操作**：
```gdscript
# 使用 set_process(false) 暂停不需要的更新
set_process(false)

# 减少物理更新频率
get_tree().paused = true  # 暂停整个场景树
```

### 常用模式

**单例模式（AutoLoad）**：
1. 创建脚本并附加到节点
2. 在项目设置 → AutoLoad 中添加
3. 全局访问：`GameManager.some_method()`

**状态机模式**：
```gdscript
extends Node

enum State { IDLE, WALKING, ATTACKING }
var current_state = State.IDLE

func change_state(new_state: State):
    exit_state(current_state)
    current_state = new_state
    enter_state(new_state)

func enter_state(state: State):
    match state:
        State.IDLE:
            # 进入空闲状态
            pass
        State.WALKING:
            # 进入行走状态
            pass
```

**对象工厂模式**：
```gdscript
extends Node

static func create_enemy(type: String) -> Node2D:
    var scene_path = "res://enemies/" + type + ".tscn"
    if ResourceLoader.exists(scene_path):
        return load(scene_path).instantiate()
    return null
```

---

## 总结

本文档涵盖了 Godot 引擎的核心概念和常用功能，适合作为快速参考手册。建议结合实际项目实践，逐步掌握各个系统的使用方法。

**学习资源**：
- Godot 官方文档：https://docs.godotengine.org/
- GDScript 参考：https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/
- 社区教程：Godot 中文社区、B站相关教程

**开发建议**：
1. 先理解节点和场景系统
2. 掌握 GDScript 基础语法
3. 熟悉常用内置类
4. 学习信号系统实现解耦
5. 通过小项目练习巩固知识

祝开发顺利！