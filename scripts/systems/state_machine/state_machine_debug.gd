extends RefCounted
class_name StateMachineDebug

## 状态机可视化调试工具
## 显示当前状态、状态栈、状态转换历史

## 获取状态机的调试信息
## state_machine: 状态机实例
## 返回: 调试信息字典
static func get_debug_info(state_machine: StateMachine) -> Dictionary:
	if not state_machine:
		return {}
	
	var info = {
		"current_state": state_machine.get_current_state_name(),
		"state_stack": [],
		"history": state_machine.get_history(10),  # 最近10条历史
		"registered_states": state_machine.get_registered_states()
	}
	
	# 注意：StateMachine的状态栈是内部变量，需要通过扩展方法访问
	# 这里暂时返回空数组
	info["state_stack"] = []
	
	return info

## 获取调试信息字符串（用于控制台输出）
## state_machine: 状态机实例
## 返回: 调试信息字符串
static func get_debug_string(state_machine: StateMachine) -> String:
	var info = get_debug_info(state_machine)
	if info.is_empty():
		return "No state machine"
	
	var text = "State Machine Debug Info:\n"
	text += "  Current State: %s\n" % info.get("current_state", "None")
	text += "  Registered States: %d\n" % info.get("registered_states", []).size()
	
	var history = info.get("history", [])
	if not history.is_empty():
		text += "  Recent History (%d entries):\n" % history.size()
		for entry in history.slice(-5):  # 只显示最后5条
			text += "    %s -> %s (%s)\n" % [
				entry.get("from", ""),
				entry.get("to", ""),
				entry.get("reason", "")
			]
	
	return text

## 获取工作流的调试信息
## workflow_executor: 工作流执行器实例
## 返回: 调试信息字典
static func get_workflow_debug_info(workflow_executor: WorkflowExecutor) -> Dictionary:
	if not workflow_executor:
		return {}
	
	var config = workflow_executor.get_config()
	var info = {
		"workflow_name": config.name if config else "",
		"priority": config.priority if config else 0,
		"current_state_index": workflow_executor.get_current_state_index(),
		"is_complete": workflow_executor.is_complete()
	}
	
	return info

## 获取工作流调试信息字符串
## workflow_executor: 工作流执行器实例
## 返回: 调试信息字符串
static func get_workflow_debug_string(workflow_executor: WorkflowExecutor) -> String:
	var info = get_workflow_debug_info(workflow_executor)
	if info.is_empty():
		return "No workflow executor"
	
	var text = "Workflow Debug Info:\n"
	text += "  Name: %s\n" % info.get("workflow_name", "Unknown")
	text += "  Priority: %d\n" % info.get("priority", 0)
	text += "  Current State Index: %d\n" % info.get("current_state_index", -1)
	text += "  Is Complete: %s\n" % info.get("is_complete", false)
	
	return text

