extends BaseState
class_name TransferResourceState

## 转移资源状态
## 将资源从一个地方转移到另一个地方

var _resource_type: String = ""  # 资源类型
var _amount: int = 0  # 转移数量

## 构造函数
## resource_type: 资源类型
## amount: 转移数量
func _init(resource_type: String = "", amount: int = 0):
	super._init("TransferResourceState")
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
## 返回: 状态执行结果（StateResult.Result），转移完成返回SUCCESS，继续转移返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 转移资源逻辑
	if context.has("transfer_complete"):
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续转移
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

