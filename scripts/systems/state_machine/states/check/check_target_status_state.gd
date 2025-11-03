extends BaseState
class_name CheckTargetStatusState

## 检查目标状态
## 检查目标的指定属性状态

var _check_property: String = ""  # 检查属性（如"health", "is_complete"等）
var _status_threshold: Variant = null  # 状态阈值

## 构造函数
## check_property: 检查属性
## status_threshold: 状态阈值
func _init(check_property: String = "", status_threshold: Variant = null):
	super._init("CheckTargetStatusState")
	_check_property = check_property
	_status_threshold = status_threshold

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("check_property"):
		_check_property = context["check_property"]
	if context.has("status_threshold"):
		_status_threshold = context["status_threshold"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），条件满足返回SUCCESS，不满足返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 检查目标状态
	if context.has("status_check_result"):
		var result = context["status_check_result"]
		if result == "met":
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
		else:
			set_result(StateResult.Result.FAILURE)
			return StateResult.Result.FAILURE
	
	# 默认返回失败（无法确定状态）
	set_result(StateResult.Result.FAILURE)
	return StateResult.Result.FAILURE

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

