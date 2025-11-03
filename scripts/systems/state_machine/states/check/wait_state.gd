extends BaseState
class_name WaitState

## 等待状态
## 等待指定时间或等待条件满足

var _wait_time: float = 0.0  # 等待时间（秒）
var _elapsed_time: float = 0.0  # 已过时间
var _wait_condition: String = ""  # 等待条件（可选）

## 构造函数
## wait_time: 等待时间
func _init(wait_time: float = 1.0):
	super._init("WaitState")
	_wait_time = wait_time
	_elapsed_time = 0.0

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("wait_time"):
		_wait_time = context["wait_time"]
	if context.has("wait_condition"):
		_wait_condition = context["wait_condition"]
	_elapsed_time = 0.0

## 更新状态
## 返回: 状态执行结果（StateResult.Result），等待完成返回SUCCESS，继续等待返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	_elapsed_time += delta
	
	# 检查条件（如果设置了）
	if _wait_condition != "":
		if context.has("condition_met"):
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
	
	# 检查时间
	if _elapsed_time >= _wait_time:
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续等待
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
	_elapsed_time = 0.0

