extends BaseState
class_name FleeState

## 逃跑状态
## 单位遇到敌人时逃跑的状态

var _flee_distance: float = 50.0  # 逃跑距离（像素）
var _safe_area: Vector2i = Vector2i(-1, -1)  # 安全区域（网格坐标）

## 构造函数
## flee_distance: 逃跑距离
func _init(flee_distance: float = 50.0):
	super._init("FleeState")
	_flee_distance = flee_distance

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	# 从上下文获取逃跑距离和安全区域
	if context.has("flee_distance"):
		_flee_distance = context["flee_distance"]
	if context.has("safe_area"):
		_safe_area = context["safe_area"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），逃到安全距离返回SUCCESS，继续逃跑返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	if context.has("enemy_detected"):
		# 检查是否已经逃到安全距离
		if context.has("distance_to_enemy"):
			var distance = context["distance_to_enemy"]
			if distance >= _flee_distance:
				# 已经逃到安全距离
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
	
	# 继续逃跑
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

