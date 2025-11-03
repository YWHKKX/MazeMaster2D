extends BaseState
class_name TakeResourceState

## 拿取资源状态
## 从资源点拿取资源

var _resource_type: String = ""  # 资源类型
var _amount: int = 0  # 获取数量

## 构造函数
## resource_type: 资源类型
## amount: 获取数量
func _init(resource_type: String = "", amount: int = 0):
	super._init("TakeResourceState")
	_resource_type = resource_type
	_amount = amount

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("resource_type"):
		_resource_type = context["resource_type"]
	if context.has("amount"):
		_amount = context["amount"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），拿取完成返回SUCCESS，继续拿取返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 拿取资源逻辑
	# 实际实现时需要：
	# 1. 从资源点提取资源
	# 2. 存储到共享上下文
	
	if context.has("resource_taken"):
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续拿取
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

