extends IState
class_name BaseState

## 状态基类
## 提供状态的基础实现和上下文数据存储
## 每个State实例独立存储自己的上下文数据

var _context: StateContext
var state_name: String = ""
var _last_result: int = StateResult.Result.RUNNING  # 存储最后的执行结果

## 构造函数
## p_state_name: 状态名称
## initial_context: 初始上下文数据（可选）
func _init(p_state_name: String = "", initial_context: Dictionary = {}):
	state_name = p_state_name
	_context = StateContext.new(initial_context)

## 获取上下文
## 返回: StateContext实例
func get_context() -> StateContext:
	return _context

## 设置上下文数据（便捷方法）
## key: 数据键
## value: 数据值
func set_context_data(key: String, value: Variant) -> void:
	_context.set_data(key, value)

## 获取上下文数据（便捷方法）
## key: 数据键
## default: 默认值
## 返回: 数据值或默认值
func get_context_data(key: String, default: Variant = null) -> Variant:
	return _context.get_data(key, default)

## 进入状态（默认实现）
func enter(context: Dictionary = {}) -> void:
	if not context.is_empty():
		_context.merge(context)
	# 子类可以重写此方法

## 更新状态（默认实现，子类必须重写）
## 返回: 状态执行结果（StateResult.Result），RUNNING表示继续执行，SUCCESS/FAILURE表示可以转换
func update(delta: float, context: Dictionary = {}) -> int:
	if not context.is_empty():
		_context.merge(context)
	# 子类必须重写此方法，并调用set_result()设置执行结果
	_last_result = StateResult.Result.RUNNING
	return StateResult.Result.RUNNING

## 退出状态（默认实现）
func exit(context: Dictionary = {}) -> void:
	# 子类可以重写此方法，执行清理操作
	pass

## 暂停状态（默认实现）
func pause(context: Dictionary = {}) -> void:
	# 子类可以重写此方法
	pass

## 恢复状态（默认实现）
func resume(context: Dictionary = {}) -> void:
	# 子类可以重写此方法
	pass

## 获取状态名称
## 返回: 状态名称字符串
func get_state_name() -> String:
	return state_name

## 获取状态的执行结果
## 返回: 当前状态的执行结果（StateResult.Result）
func get_result() -> int:
	return _last_result

## 设置状态的执行结果
## result: 执行结果（StateResult.Result）
func set_result(result: int) -> void:
	_last_result = result

## 获取共享上下文（通过context中的state_machine引用）
## context: 传入的上下文字典
## 返回: 共享上下文字典，如果无法获取则返回空字典
func get_shared_context(context: Dictionary = {}) -> Dictionary:
	var state_machine = context.get("state_machine")
	if state_machine and state_machine.has_method("get_shared_context"):
		return state_machine.get_shared_context()
	return {}

