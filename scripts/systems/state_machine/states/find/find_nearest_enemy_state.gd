extends BaseState
class_name FindNearestEnemyState

## 查找最近敌人状态
## 根据警戒范围、敌对阵营查找最近的敌人

var _alert_range: float = 30.0  # 警戒范围（像素）
var _enemy_faction: String = "ENEMY"  # 敌对阵营

## 构造函数
## alert_range: 警戒范围
## enemy_faction: 敌对阵营
func _init(alert_range: float = 30.0, enemy_faction: String = "ENEMY"):
	super._init("FindNearestEnemyState")
	_alert_range = alert_range
	_enemy_faction = enemy_faction

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("alert_range"):
		_alert_range = context["alert_range"]
	if context.has("enemy_faction"):
		_enemy_faction = context["enemy_faction"]

## 更新状态
## 返回: 状态执行结果（StateResult.Result），找到敌人返回SUCCESS，未找到返回RUNNING
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 查找最近敌人的逻辑
	# 实际实现时需要访问UnitManager查找敌对单位
	
	if context.has("found_enemy"):
		# 存储到共享上下文
		shared_context["found_enemy"] = context["found_enemy"]
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 继续查找
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
