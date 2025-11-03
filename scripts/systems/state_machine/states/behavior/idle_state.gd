extends BaseState
class_name IdleState

## 空闲状态
## 单位在空闲时停留的状态

var _idle_time: float = 0.0
var _max_idle_time: float = 5.0  # 默认最大空闲时间（秒）

## 构造函数
## max_idle_time: 最大空闲时间（秒）
func _init(max_idle_time: float = 5.0):
	super._init("IdleState")
	_max_idle_time = max_idle_time
	_idle_time = 0.0

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	_idle_time = 0.0
	# 从上下文获取最大空闲时间（如果提供）
	if context.has("max_idle_time"):
		_max_idle_time = context["max_idle_time"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），始终返回RUNNING（等待外部触发或工作流启动）
func update(delta: float, context: Dictionary = {}) -> int:
	_idle_time += delta
	
	# 检查是否有任务需要执行（从上下文获取）
	if context.has("should_work"):
		if context["should_work"]:
			# 应该工作，但IdleState不主动转换，由工作流系统处理
			# 可以尝试启动工作流
			pass
	
	# 如果空闲时间超过最大值，尝试启动工作流
	if _idle_time >= _max_idle_time:
		var workflow_manager = context.get("workflow_manager")
		var unit_id = context.get("unit_id", -1)
		var state_machine = context.get("state_machine")
		
		# 尝试启动挖矿工作流
		if workflow_manager and unit_id >= 0 and state_machine:
			# 检查是否已经有工作流在运行
			var has_workflow = workflow_manager.has_workflow(unit_id)
			
			if not has_workflow:
				# 没有工作流在运行，尝试启动挖矿工作流
				var success = workflow_manager.start_workflow(unit_id, "MiningWorkflow", state_machine)
				if success:
					print("IdleState: 成功启动MiningWorkflow")
					# 工作流启动后会自动切换状态，IdleState只需继续运行
				else:
					print("IdleState: 无法启动MiningWorkflow，将继续空闲")
			
			# 重置空闲时间以定期重试
			_idle_time = 0.0
	
	# 始终返回RUNNING（保持在空闲状态，等待工作流启动或外部触发）
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
	_idle_time = 0.0

