extends BaseState
class_name CheckConditionState

## 条件检查状态
## 检查指定条件并根据结果分支

var _check_condition: String = ""  # 检查条件（逻辑表达式）
var _branch_mapping: Dictionary = {}  # 分支映射（条件结果 -> 下一状态）

## 构造函数
## check_condition: 检查条件
func _init(check_condition: String = ""):
	super._init("CheckConditionState")
	_check_condition = check_condition

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("check_condition"):
		_check_condition = context["check_condition"]
	if context.has("branch_mapping"):
		_branch_mapping = context["branch_mapping"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），条件满足返回SUCCESS，不满足返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 执行条件检查
	# 实际实现时需要解析条件表达式并评估
	
	if context.has("condition_result"):
		var result = context["condition_result"]
		# 根据结果返回SUCCESS或FAILURE（具体映射由工作流配置处理）
		if result == "true" or result == true:
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
		else:
			set_result(StateResult.Result.FAILURE)
			return StateResult.Result.FAILURE
	
	# 如果没有结果，默认返回失败
	set_result(StateResult.Result.FAILURE)
	return StateResult.Result.FAILURE

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

