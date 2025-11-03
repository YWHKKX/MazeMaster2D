extends BaseState
class_name AttackState

## 攻击状态
## 对目标进行攻击

var _attack_range: float = 30.0  # 攻击范围（像素）
var _attack_power: int = 10  # 攻击力
var _cooldown: float = 1.0  # 攻击冷却时间（秒）
var _current_cooldown: float = 0.0  # 当前冷却时间

## 构造函数
## attack_range: 攻击范围
## attack_power: 攻击力
## cooldown: 冷却时间
func _init(attack_range: float = 30.0, attack_power: int = 10, cooldown: float = 1.0):
	super._init("AttackState")
	_attack_range = attack_range
	_attack_power = attack_power
	_cooldown = cooldown
	_current_cooldown = 0.0

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("attack_range"):
		_attack_range = context["attack_range"]
	if context.has("attack_power"):
		_attack_power = context["attack_power"]
	if context.has("cooldown"):
		_cooldown = context["cooldown"]
	_current_cooldown = 0.0

## 更新状态
## 返回: 状态执行结果（StateResult.Result），目标死亡返回SUCCESS，继续攻击返回RUNNING，目标丢失返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 检查目标是否仍然有效
	var target = shared_context.get("target")
	if target == null:
		# 目标丢失，返回失败
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 检查冷却时间
	_current_cooldown -= delta
	if _current_cooldown <= 0.0:
		# 执行攻击
		# 实际实现时需要：
		# 1. 检查目标是否在攻击范围内
		# 2. 计算伤害并应用到目标
		# 3. 重置冷却时间
		_current_cooldown = _cooldown
		
		# 检查目标是否死亡
		if context.has("target_dead"):
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
	
	# 保持在攻击状态
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
	_current_cooldown = 0.0

