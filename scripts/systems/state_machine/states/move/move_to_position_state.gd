extends BaseState
class_name MoveToPositionState

## 移动到位置状态
## 移动到指定的坐标位置

var _target_position: Vector2i = Vector2i(-1, -1)  # 目标位置（网格坐标）
var _arrival_threshold: float = 1.0  # 到达阈值（网格单位）

## 构造函数
## target_position: 目标位置
## arrival_threshold: 到达阈值
func _init(target_position: Vector2i = Vector2i(-1, -1), arrival_threshold: float = 1.0):
	super._init("MoveToPositionState")
	_target_position = target_position
	_arrival_threshold = arrival_threshold

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("target_position"):
		_target_position = context["target_position"]
	if context.has("arrival_threshold"):
		_arrival_threshold = context["arrival_threshold"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），到达位置返回SUCCESS，继续移动返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 移动逻辑
	if context.has("reached_position"):
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续移动
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

