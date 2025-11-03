extends RefCounted
class_name IState

## 状态接口定义
## 所有状态必须实现此接口

## 进入状态时调用
## context: 状态上下文数据（Dictionary）
func enter(context: Dictionary = {}) -> void:
	pass

## 更新状态（每帧调用）
## delta: 帧时间间隔
## context: 状态上下文数据
## 返回: 状态执行结果（StateResult.Result），RUNNING表示继续执行，SUCCESS/FAILURE表示可以转换
func update(delta: float, context: Dictionary = {}) -> int:
	return StateResult.Result.RUNNING

## 获取状态的执行结果
## 返回: 当前状态的执行结果（StateResult.Result）
func get_result() -> int:
	return StateResult.Result.RUNNING

## 退出状态时调用
## context: 状态上下文数据
func exit(context: Dictionary = {}) -> void:
	pass

## 暂停状态时调用
## context: 状态上下文数据
func pause(context: Dictionary = {}) -> void:
	pass

## 恢复状态时调用（从暂停状态恢复）
## context: 状态上下文数据
func resume(context: Dictionary = {}) -> void:
	pass

