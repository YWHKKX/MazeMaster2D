extends RefCounted
class_name WorkflowExecutor

## 工作流执行器
## 执行工作流状态序列，处理状态转换

var _config: WorkflowConfig = null
var _state_machine: StateMachine = null
var _current_state_index: int = -1
var _is_complete: bool = false

## 构造函数
## config: 工作流配置
## state_machine: 状态机实例
func _init(config: WorkflowConfig, state_machine: StateMachine):
	_config = config
	_state_machine = state_machine
	_current_state_index = -1
	_is_complete = false

## 初始化工作流（启动第一个状态）
## 注意：假设所有状态类已经通过StateRegistry注册到状态机
func initialize() -> bool:
	if not _config or not _config.is_valid():
		push_error("WorkflowExecutor: Invalid config")
		return false
	
	if not _state_machine:
		push_error("WorkflowExecutor: No state machine")
		return false
	
	# 检查所有状态是否已注册
	for state_config in _config.states:
		var state_name = state_config.get("state", "")
		if not _state_machine.get_state(state_name):
			push_warning("WorkflowExecutor: State '%s' not registered, will be registered automatically" % state_name)
			# 注意：如果状态未注册，这里应该自动注册
			# 但为了简化，我们假设所有状态已通过StateRegistry注册
			# 如果状态确实未注册，initialize会失败，这有助于发现配置错误
	
	# 启动第一个状态
	if not _config.states.is_empty():
		_current_state_index = 0
		var first_state = _config.states[0]
		var state_name = first_state.get("state", "")
		var params = first_state.get("params", {})
		
		# 合并上下文输入数据到参数
		for input_key in _config.context_input:
			if not params.has(input_key):
				params[input_key] = null # 占位符，实际值应该从单位上下文获取
		
		_state_machine.change_state(state_name, params, "workflow_start")
		_is_complete = false
		return true
	
	push_error("WorkflowExecutor: No states in workflow config")
	return false

## 更新工作流执行
## _delta: 帧时间间隔（保留用于将来扩展）
## 注意：主动检查状态的执行结果，并根据结果驱动状态转换
func update(_delta: float) -> void:
	if _is_complete:
		return
	
	if _current_state_index < 0 or _current_state_index >= _config.states.size():
		_is_complete = true
		return
	
	# 获取当前状态配置
	var current_state_config = _config.states[_current_state_index]
	var expected_state_name = current_state_config.get("state", "")
	var transitions = current_state_config.get("transitions", {})
	
	# 检查状态机当前状态是否匹配工作流配置
	var current_state_name = _state_machine.get_current_state_name()
	if current_state_name != expected_state_name:
		# 状态不匹配，可能被中断或手动切换了
		# 尝试查找新状态在工作流中的位置
		var new_state_index = _find_state_index_in_workflow(current_state_name)
		if new_state_index >= 0:
			_current_state_index = new_state_index
			# 应用新状态的params（但不重新调用enter，避免覆盖数据）
			var new_state_config = _config.states[new_state_index]
			var params = new_state_config.get("params", {})
			var state_instance = _state_machine.get_current_state()
			if state_instance:
				state_instance.enter(params)
		else:
			# 状态不在工作流中，可能被中断了
			return
	
	# 获取当前状态的执行结果
	var active_state = _state_machine.get_current_state()
	if not active_state:
		return
	
	var state_result = _check_state_result(active_state)
	
	# 根据状态结果决定是否转换
	if state_result == StateResult.Result.SUCCESS or state_result == StateResult.Result.FAILURE:
		var next_state = _evaluate_transitions(state_result, transitions)
		if next_state:
			_advance_to_next_state(next_state)

## 检查状态的执行结果
## state: 状态实例
## 返回: 状态的执行结果（StateResult.Result）
func _check_state_result(state: IState) -> int:
	if state.has_method("get_result"):
		return state.get_result()
	return StateResult.Result.RUNNING

## 根据状态结果和转换条件决定下一状态
## result: 状态执行结果（StateResult.Result）
## transitions: 转换条件配置
## 返回: 下一状态名称或空字符串
func _evaluate_transitions(result: int, transitions: Dictionary) -> String:
	match result:
		StateResult.Result.SUCCESS:
			if transitions.has("success"):
				var next_state = transitions["success"]
				if next_state is String:
					return next_state
		StateResult.Result.FAILURE:
			if transitions.has("failure"):
				var next_state = transitions["failure"]
				if next_state is String:
					return next_state
		StateResult.Result.RUNNING:
			# 继续运行，不转换
			return ""
	return ""

## 在工作流中查找状态索引
## state_name: 状态名称
## 返回: 状态在工作流中的索引，如果未找到则返回-1
func _find_state_index_in_workflow(state_name: String) -> int:
	# 优先从当前索引之后查找
	for i in range(_current_state_index + 1, _config.states.size()):
		if _config.states[i].get("state", "") == state_name:
			return i
	
	# 如果没找到，再从开头查找（处理循环回退的情况）
	for i in range(_current_state_index):
		if _config.states[i].get("state", "") == state_name:
			return i
	
	return -1

## 前进到下一个状态
## next_state_name: 下一个状态名称
func _advance_to_next_state(next_state_name: String) -> void:
	# 查找下一个状态在工作流中的位置
	var next_state_index = _find_state_index_in_workflow(next_state_name)
	
	if next_state_index >= 0:
		_current_state_index = next_state_index
		var state_config = _config.states[next_state_index]
		var params = state_config.get("params", {})
		
		# 合并共享上下文数据（确保之前状态存储的数据能传递）
		var shared_context = _state_machine.get_shared_context()
		var merged_context = params.duplicate()
		for key in shared_context:
			if not merged_context.has(key):  # params优先级更高
				merged_context[key] = shared_context[key]
		
		_state_machine.change_state(next_state_name, merged_context, "workflow_transition")
		return
	
	# 如果找不到下一个状态，检查是否是循环回到第一个状态
	if next_state_name == _config.states[0].get("state", ""):
		_current_state_index = 0
		var params = _config.states[0].get("params", {})
		
		# 合并共享上下文
		var shared_context = _state_machine.get_shared_context()
		var merged_context = params.duplicate()
		for key in shared_context:
			if not merged_context.has(key):
				merged_context[key] = shared_context[key]
		
		_state_machine.change_state(next_state_name, merged_context, "workflow_loop")
	else:
		# 无法找到下一个状态，标记为完成
		_is_complete = true

## 检查工作流是否完成
## 返回: 如果完成则返回true
func is_complete() -> bool:
	return _is_complete

## 获取当前状态索引
## 返回: 当前状态在工作流中的索引
func get_current_state_index() -> int:
	return _current_state_index

## 获取工作流配置
## 返回: 工作流配置
func get_config() -> WorkflowConfig:
	return _config

## 获取工作流名称
## 返回: 工作流名称
func get_workflow_name() -> String:
	if _config:
		return _config.name
	return ""

## 获取工作流进度
## 返回: 进度字典 {current_index, total_count, percentage}
func get_progress() -> Dictionary:
	if not _config or _config.states.is_empty():
		return {"current_index": 0, "total_count": 0, "percentage": 0.0}
	
	var total = _config.states.size()
	var current = _current_state_index
	if current < 0:
		current = 0
	if current >= total:
		current = total - 1
	
	var percentage = 0.0
	if total > 0:
		percentage = float(current + 1) / float(total)
	
	return {
		"current_index": current,
		"total_count": total,
		"percentage": percentage
	}
