extends BaseState
class_name MoveAwayFromTargetState

## 远离目标状态
## 远离指定的目标，用于逃跑

var _target_key: String = "target"  # 目标在上下文中的键
var _flee_distance: float = 50.0  # 逃跑距离（像素）

## 构造函数
## target_key: 目标键
## flee_distance: 逃跑距离
func _init(target_key: String = "target", flee_distance: float = 50.0):
	super._init("MoveAwayFromTargetState")
	_target_key = target_key
	_flee_distance = flee_distance

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("target_key"):
		_target_key = context["target_key"]
	if context.has("flee_distance"):
		_flee_distance = context["flee_distance"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），逃到安全距离返回SUCCESS，继续逃跑返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	var target = shared_context.get(_target_key)
	if target == null:
		# 目标丢失，可以停止逃跑
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 检查是否已经逃到安全距离
	if context.has("safe_distance_reached"):
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续逃跑
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

