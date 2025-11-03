extends BaseState
class_name GuardState

## 守卫状态
## 在指定位置守卫，扫描威胁

var _guard_position: Vector2i = Vector2i(-1, -1)  # 守卫位置（网格坐标）
var _scan_range: float = 30.0  # 扫描范围（像素）

## 构造函数
## guard_position: 守卫位置
## scan_range: 扫描范围
func _init(guard_position: Vector2i = Vector2i(-1, -1), scan_range: float = 30.0):
	super._init("GuardState")
	_guard_position = guard_position
	_scan_range = scan_range

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("guard_position"):
		_guard_position = context["guard_position"]
	if context.has("scan_range"):
		_scan_range = context["scan_range"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），发现威胁返回SUCCESS，继续守卫返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 守卫逻辑
	# 实际实现时需要：
	# 1. 保持在守卫位置附近
	# 2. 扫描范围内的威胁
	# 3. 发现威胁时返回SUCCESS让工作流处理
	
	if context.has("threat_detected"):
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续守卫
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

