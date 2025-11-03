extends BaseManager
class_name WorkflowManager

## 工作流管理器
## 管理工作流实例、工作流优先级、中断控制

var _workflow_executors: Dictionary = {}  # unit_id -> WorkflowExecutor
var _active_workflows: Dictionary = {}  # unit_id -> WorkflowConfig
var _workflow_registry: WorkflowRegistry = null  # WorkflowRegistry引用

## 初始化管理器
func _initialize() -> void:
	_workflow_executors.clear()
	_active_workflows.clear()

## 清理管理器
func _cleanup() -> void:
	_workflow_executors.clear()
	_active_workflows.clear()

## 设置工作流注册表引用
## registry: WorkflowRegistry实例
func set_registry(registry: WorkflowRegistry) -> void:
	_workflow_registry = registry

## 为单位启动工作流
## unit_id: 单位ID
## workflow_name: 工作流名称
## state_machine: 单位的状态机实例
## 返回: 如果成功启动则返回true
func start_workflow(unit_id: int, workflow_name: String, state_machine: StateMachine) -> bool:
	if not _workflow_registry:
		push_error("WorkflowManager: No registry set")
		return false
	
	# 从注册表获取工作流配置
	var config = _workflow_registry.get_workflow_config(workflow_name)
	if not config:
		push_error("WorkflowManager: Workflow '%s' not found" % workflow_name)
		return false
	
	# 检查是否需要中断当前工作流
	var current_workflow = _active_workflows.get(unit_id)
	if current_workflow:
		if config.priority > current_workflow.priority:
			# 新工作流优先级更高，可以中断
			stop_workflow(unit_id)
		elif not current_workflow.interruptible:
			# 当前工作流不可中断
			return false
	
	# 创建工作流执行器
	var executor = WorkflowExecutor.new(config, state_machine)
	if not executor.initialize():
		push_error("WorkflowManager: Failed to initialize workflow executor")
		return false
	
	_workflow_executors[unit_id] = executor
	_active_workflows[unit_id] = config
	
	return true

## 停止单位的工作流
## unit_id: 单位ID
func stop_workflow(unit_id: int) -> void:
	if _workflow_executors.has(unit_id):
		_workflow_executors.erase(unit_id)
	if _active_workflows.has(unit_id):
		_active_workflows.erase(unit_id)

## 检查单位是否有活动的工作流
## unit_id: 单位ID
## 返回: 如果有活动工作流则返回true
func has_workflow(unit_id: int) -> bool:
	return _active_workflows.has(unit_id) and _workflow_executors.has(unit_id)

## 更新所有工作流
## delta: 帧时间间隔
func update_all(delta: float) -> void:
	var completed_workflows: Array[int] = []
	
	for unit_id in _workflow_executors.keys():
		var executor = _workflow_executors[unit_id]
		executor.update(delta)
		
		if executor.is_complete():
			completed_workflows.append(unit_id)
	
	# 清理完成的工作流
	for unit_id in completed_workflows:
		stop_workflow(unit_id)

## 获取单位的工作流执行器
## unit_id: 单位ID
## 返回: WorkflowExecutor或null
func get_executor(unit_id: int) -> WorkflowExecutor:
	return _workflow_executors.get(unit_id)

## 获取单位的活动工作流
## unit_id: 单位ID
## 返回: WorkflowConfig或null
func get_active_workflow(unit_id: int) -> WorkflowConfig:
	return _active_workflows.get(unit_id)

## 获取所有活动工作流的单位ID
## 返回: 单位ID数组
func get_all_active_unit_ids() -> Array:
	return _workflow_executors.keys()

## 获取工作流调试信息（用于可视化）
## unit_id: 单位ID
## 返回: 调试信息字典
func get_debug_info(unit_id: int) -> Dictionary:
	var executor = get_executor(unit_id)
	var workflow = get_active_workflow(unit_id)
	
	if not executor or not workflow:
		return {}
	
	return {
		"workflow_name": workflow.name,
		"priority": workflow.priority,
		"interruptible": workflow.interruptible,
		"current_state_index": executor.get_current_state_index(),
		"is_complete": executor.is_complete(),
		"total_states": workflow.states.size()
	}

