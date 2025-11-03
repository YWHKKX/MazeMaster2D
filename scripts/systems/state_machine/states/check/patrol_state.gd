extends BaseState
class_name PatrolState

## 巡逻状态
## 在指定区域内巡逻

var _patrol_area: Rect2i = Rect2i()  # 巡逻区域（网格坐标）
var _loop_mode: bool = true  # 循环模式

## 构造函数
## patrol_area: 巡逻区域
## loop_mode: 循环模式
func _init(patrol_area: Rect2i = Rect2i(), loop_mode: bool = true):
	super._init("PatrolState")
	_patrol_area = patrol_area
	_loop_mode = loop_mode

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("patrol_area"):
		_patrol_area = context["patrol_area"]
	if context.has("loop_mode"):
		_loop_mode = context["loop_mode"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），发现敌人返回SUCCESS，继续巡逻返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 巡逻逻辑
	# 实际实现时需要：
	# 1. 在巡逻区域内生成巡逻点
	# 2. 移动到巡逻点
	# 3. 到达后选择下一个巡逻点
	
	if context.has("enemy_detected"):
		# 发现敌人，返回SUCCESS让工作流处理
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续巡逻
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

