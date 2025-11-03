extends RefCounted
class_name WorkflowRegistry

## 统一工作流注册API
## 支持配置驱动注册
## 新增单位只需创建工作流+注册工作流

var _workflows: Dictionary = {}  # workflow_name -> WorkflowConfig
var _unit_workflows: Dictionary = {}  # unit_type (SpecificEntityType) -> Array[String] (workflow names)

## 注册工作流配置
## config: 工作流配置实例
func register_workflow(config: WorkflowConfig) -> void:
	if not config or not config.is_valid():
		push_error("WorkflowRegistry: Invalid workflow config")
		return
	
	_workflows[config.name] = config

## 注册工作流配置（别名方法，保持向后兼容）
## config: 工作流配置实例
func register_workflow_config(config: WorkflowConfig) -> void:
	register_workflow(config)

## 注册单位类型的工作流列表
## unit_type: 单位类型（SpecificEntityType枚举）
## workflow_names: 工作流名称数组（按优先级排序）
func register_unit_workflows(unit_type: Enums.SpecificEntityType, workflow_names: Array[String]) -> void:
	# 验证所有工作流都已注册
	for workflow_name in workflow_names:
		if not _workflows.has(workflow_name):
			push_warning("WorkflowRegistry: Workflow '%s' not registered yet" % workflow_name)
	
	_unit_workflows[unit_type] = workflow_names.duplicate()

## 获取工作流配置
## workflow_name: 工作流名称
## 返回: WorkflowConfig或null
func get_workflow_config(workflow_name: String) -> WorkflowConfig:
	return _workflows.get(workflow_name)

## 获取单位类型的所有工作流名称
## unit_type: 单位类型
## 返回: 工作流名称数组
func get_unit_workflows(unit_type: Enums.SpecificEntityType) -> Array[String]:
	return _unit_workflows.get(unit_type, []).duplicate()

## 获取单位的默认工作流（优先级最高的）
## unit_type: 单位类型
## 返回: 工作流名称或空字符串
func get_unit_default_workflow(unit_type: Enums.SpecificEntityType) -> String:
	var workflows = get_unit_workflows(unit_type)
	if workflows.is_empty():
		return ""
	
	# 返回第一个工作流（假设按优先级排序）
	return workflows[0]

## 检查工作流是否已注册
## workflow_name: 工作流名称
## 返回: 如果已注册则返回true
func has_workflow(workflow_name: String) -> bool:
	return _workflows.has(workflow_name)

## 获取所有已注册的工作流名称
## 返回: 工作流名称数组
func get_all_workflow_names() -> Array[String]:
	return _workflows.keys()

## 获取所有已注册的单位类型
## 返回: 单位类型数组
func get_all_unit_types() -> Array:
	return _unit_workflows.keys()

