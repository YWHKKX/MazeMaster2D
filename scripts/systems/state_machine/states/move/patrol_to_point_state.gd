extends BaseState
class_name PatrolToPointState

## 巡逻至点状态
## 按照巡逻路径移动到指定点

var _patrol_path: Array[Vector2i] = []  # 巡逻路径点数组
var _current_point_index: int = 0  # 当前巡逻点索引
var _loop_mode: bool = true  # 是否循环巡逻

## 构造函数
## patrol_path: 巡逻路径
## loop_mode: 循环模式
func _init(patrol_path: Array[Vector2i] = [], loop_mode: bool = true):
	super._init("PatrolToPointState")
	_patrol_path = patrol_path
	_loop_mode = loop_mode
	_current_point_index = 0

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("patrol_path"):
		_patrol_path = context["patrol_path"]
	if context.has("loop_mode"):
		_loop_mode = context["loop_mode"]
	_current_point_index = 0

## 更新状态
## 返回: 状态执行结果（StateResult.Result），巡逻完成返回SUCCESS，继续巡逻返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	if _patrol_path.is_empty():
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 检查是否到达当前巡逻点
	if context.has("reached_patrol_point"):
		_current_point_index += 1
		
		if _current_point_index >= _patrol_path.size():
			if _loop_mode:
				_current_point_index = 0  # 循环
				# 循环模式，返回SUCCESS让工作流决定是否继续
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
			else:
				# 巡逻结束
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
	
	# 继续巡逻
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

