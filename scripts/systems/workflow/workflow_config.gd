extends RefCounted
class_name WorkflowConfig

## 工作流配置类
## 统一的工作流配置结构
## 使用GDScript RefCounted配置类，在代码中定义

var name: String = ""  # 工作流名称（唯一标识）
var priority: int = 1  # 优先级（10=最高, 1=最低）
var interruptible: bool = true  # 是否可被高优先级中断

## 状态序列配置
## 数组元素格式：{state: "StateName", params: {...}, transitions: {...}}
var states: Array[Dictionary] = []

## 上下文数据
## input: 需要的输入数据键数组
## output: 输出结果存储键
var context_input: Array[String] = []
var context_output: String = ""

## 构造函数
## p_name: 工作流名称
## p_priority: 优先级
## p_interruptible: 是否可中断
func _init(p_name: String = "", p_priority: int = 1, p_interruptible: bool = true):
	name = p_name
	priority = p_priority
	interruptible = p_interruptible
	states = []
	context_input = []
	context_output = ""

## 添加状态到序列
## state_name: 状态机类名
## params: 状态参数（Dictionary）
## transitions: 转换条件（Dictionary）
func add_state(state_name: String, params: Dictionary = {}, transitions: Dictionary = {}) -> void:
	var state_config = {
		"state": state_name,
		"params": params,
		"transitions": transitions
	}
	states.append(state_config)

## 设置上下文
## inputs: 需要的输入数据键数组
## output: 输出结果存储键
func set_context(inputs: Array[String] = [], output: String = "") -> void:
	context_input = inputs
	context_output = output

## 验证配置有效性
## 返回: 如果配置有效则返回true
func is_valid() -> bool:
	if name.is_empty():
		return false
	if states.is_empty():
		return false
	if priority < 1 or priority > 10:
		return false
	return true

## 获取配置信息（用于调试）
## 返回: 配置信息字符串
func get_info() -> String:
	var info = "Workflow: %s (Priority: %d, Interruptible: %s)\n" % [name, priority, interruptible]
	info += "States: %d\n" % states.size()
	for i in range(states.size()):
		var state = states[i]
		info += "  %d. %s\n" % [i + 1, state.get("state", "Unknown")]
	return info

