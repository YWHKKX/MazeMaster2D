extends BaseState
class_name CheckStorageCapacityState

## 检查容量状态
## 检查存储点的容量

var _capacity_threshold: int = 0  # 容量阈值
var _compare_type: String = "greater_than"  # 比较类型（greater_than, less_than, equal）

## 构造函数
## capacity_threshold: 容量阈值
## compare_type: 比较类型
func _init(capacity_threshold: int = 0, compare_type: String = "greater_than"):
	super._init("CheckStorageCapacityState")
	_capacity_threshold = capacity_threshold
	_compare_type = compare_type

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("capacity_threshold"):
		_capacity_threshold = context["capacity_threshold"]
	if context.has("compare_type"):
		_compare_type = context["compare_type"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），容量充足返回SUCCESS，不足返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 检查存储容量
	# 实际实现时需要：
	# 1. 获取存储点容量
	# 2. 比较容量和阈值
	# 3. 根据结果返回SUCCESS或FAILURE
	
	if context.has("capacity_check_result"):
		var result = context["capacity_check_result"]
		if result == "sufficient":
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
		else:
			set_result(StateResult.Result.FAILURE)
			return StateResult.Result.FAILURE
	
	# 默认返回失败（无法确定容量状态）
	set_result(StateResult.Result.FAILURE)
	return StateResult.Result.FAILURE

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

