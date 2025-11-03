extends RefCounted
class_name StateMachine

## 状态机主类
## 管理状态转换、当前状态、状态栈
## 独立系统，由UnitManager统一管理，Unit通过ID关联

var _current_state: IState = null
var _state_stack: Array[IState] = []  # 状态栈（用于临时状态如眩晕、技能释放）
var _states: Dictionary = {}  # 状态字典（key=状态名称, value=IState实例）
var _history: Array[Dictionary] = []  # 状态转换历史记录
var _max_history_size: int = 100  # 最大历史记录数量
var _shared_context: Dictionary = {}  # 共享上下文存储（所有状态共享）

var owner_id: int = -1  # 拥有此状态机的Unit ID

## 构造函数
## p_owner_id: 拥有此状态机的Unit ID
func _init(p_owner_id: int):
	owner_id = p_owner_id
	_history.clear()

## 注册状态
## state_name: 状态名称
## state: 状态实例（IState）
func register_state(state_name: String, state: IState) -> void:
	_states[state_name] = state

## 切换状态
## new_state_name: 新状态名称
## context: 传递给新状态的上下文数据
## reason: 状态转换原因（用于历史记录）
func change_state(new_state_name: String, context: Dictionary = {}, reason: String = "") -> bool:
	if not _states.has(new_state_name):
		push_warning("StateMachine: State '%s' not registered" % new_state_name)
		return false
	
	var new_state = _states[new_state_name]
	
	# 在退出当前状态之前，将当前状态的上下文数据合并到context中
	# 这样新状态可以访问之前状态存储的数据（如found_target_position等）
	if _current_state != null:
		# 获取当前状态的上下文数据
		if _current_state.has_method("get_context"):
			var current_context = _current_state.get_context()
			if current_context:
				var current_data = current_context.get_all_data()
				# 合并当前状态的上下文数据到context中（保留外部传入的数据优先级）
				for key in current_data:
					if not context.has(key):  # 只有当context中没有该键时才合并，避免覆盖
						context[key] = current_data[key]
		
		_current_state.exit(context)
		_record_history(_get_state_name(_current_state), new_state_name, reason)
	
	# 进入新状态（传入合并后的context）
	_current_state = new_state
	_current_state.enter(context)
	
	return true

## 推入状态到栈（用于临时状态）
## state_name: 状态名称
## context: 上下文数据
## reason: 推入原因
func push_state(state_name: String, context: Dictionary = {}, reason: String = "") -> bool:
	if not _states.has(state_name):
		push_warning("StateMachine: State '%s' not registered" % state_name)
		return false
	
	var new_state = _states[state_name]
	
	# 暂停当前状态
	if _current_state != null:
		_current_state.pause(context)
		_state_stack.append(_current_state)
		_record_history(_get_state_name(_current_state), state_name, reason + " (pushed)")
	
	# 进入新状态
	_current_state = new_state
	_current_state.enter(context)
	
	return true

## 从栈中弹出状态（恢复之前的状态）
## context: 上下文数据
## reason: 弹出原因
func pop_state(context: Dictionary = {}, reason: String = "") -> bool:
	if _state_stack.is_empty():
		push_warning("StateMachine: State stack is empty, cannot pop")
		return false
	
	# 退出当前状态
	if _current_state != null:
		var current_name = _get_state_name(_current_state)
		_current_state.exit(context)
		
		# 恢复栈顶状态
		var previous_state = _state_stack.pop_back()
		var previous_name = _get_state_name(previous_state)
		
		_current_state = previous_state
		_current_state.resume(context)
		_record_history(current_name, previous_name, reason + " (popped)")
	
	return true

## 更新状态机（每帧调用）
## delta: 帧时间间隔
## context: 可选的上下文数据（从外部传入）
## 注意：不再处理状态转换，由WorkflowExecutor根据状态结果驱动转换
func update(delta: float, context: Dictionary = {}) -> void:
	if _current_state == null:
		return
	
	# 合并共享上下文到传入的context中
	var merged_context = context.duplicate()
	for key in _shared_context:
		merged_context[key] = _shared_context[key]
	
	# 更新当前状态（只执行行为，不处理状态转换）
	_current_state.update(delta, merged_context)

## 获取当前状态
## 返回: 当前状态实例或null
func get_current_state() -> IState:
	return _current_state

## 获取当前状态名称
## 返回: 当前状态名称或空字符串
func get_current_state_name() -> String:
	return _get_state_name(_current_state)

## 检查是否在指定状态
## state_name: 状态名称
## 返回: 如果是当前状态则返回true
func is_in_state(state_name: String) -> bool:
	return _get_state_name(_current_state) == state_name

## 获取状态转换历史
## limit: 限制返回的历史记录数量（0表示返回全部）
## 返回: 历史记录数组
func get_history(limit: int = 0) -> Array[Dictionary]:
	if limit <= 0 or limit >= _history.size():
		return _history.duplicate()
	
	# 返回最近的limit条记录
	var start_index = max(0, _history.size() - limit)
	return _history.slice(start_index)

## 清空历史记录
func clear_history() -> void:
	_history.clear()

## 设置最大历史记录数量
## size: 最大数量
func set_max_history_size(size: int) -> void:
	_max_history_size = max(1, size)

## 获取状态实例
## state_name: 状态名称
## 返回: 状态实例或null
func get_state(state_name: String) -> IState:
	return _states.get(state_name)

## 获取所有已注册的状态名称
## 返回: 状态名称数组
func get_registered_states() -> Array[String]:
	return _states.keys()

## 获取共享上下文
## 返回: 共享上下文字典
func get_shared_context() -> Dictionary:
	return _shared_context

## 设置共享上下文数据
## key: 数据键
## value: 数据值
func set_shared_data(key: String, value: Variant) -> void:
	_shared_context[key] = value

## 获取共享上下文数据
## key: 数据键
## default: 默认值
## 返回: 数据值或默认值
func get_shared_data(key: String, default: Variant = null) -> Variant:
	return _shared_context.get(key, default)

## 清空共享上下文
func clear_shared_context() -> void:
	_shared_context.clear()

## 内部方法：获取状态名称
func _get_state_name(state: IState) -> String:
	if state == null:
		return ""
	if state is BaseState:
		return (state as BaseState).get_state_name()
	return state.get_script().get_path().get_file().get_basename()

## 内部方法：记录状态转换历史
func _record_history(from_state: String, to_state: String, reason: String) -> void:
	var entry = {
		"from": from_state,
		"to": to_state,
		"reason": reason,
		"time": Time.get_ticks_msec()
	}
	_history.append(entry)
	
	# 限制历史记录数量
	if _history.size() > _max_history_size:
		_history.remove_at(0)

