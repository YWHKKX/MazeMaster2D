extends Node2D
class_name StateTransitionEffect

## 状态转换动画效果
## 提供状态切换时的视觉反馈（颜色变化、粒子效果等）

var _unit_id: int = -1
var _last_state_name: String = ""
var _from_state_name: String = ""  # 转换起始状态
var _transition_duration: float = 0.3  # 转换动画时长（秒）
var _elapsed_time: float = 0.0
var _is_transitioning: bool = false
var _blink_effect: bool = false  # 闪烁效果标志

## 颜色配置（所有状态类型的颜色配置）
## 参考：docs/工作流配置系统.md - 状态指示器颜色配置
var _state_colors: Dictionary = {
	# 行为类
	"IdleState": Color(1.0, 1.0, 0.0),                    # 黄色 RGB(255, 255, 0)
	"FleeState": Color(1.0, 0.65, 0.0),                   # 橙色 RGB(255, 165, 0)
	
	# 查找类
	"FindTargetState": Color(0.0, 1.0, 1.0),              # 青色 RGB(0, 255, 255)
	"FindStorageState": Color(0.678, 0.847, 0.902),       # 浅蓝 RGB(173, 216, 230)
	"FindNearestEnemyState": Color(1.0, 0.753, 0.796),    # 粉红 RGB(255, 192, 203)
	
	# 移动类
	"MoveToTargetState": Color(0.0, 0.0, 1.0),            # 蓝色 RGB(0, 0, 255)
	"MoveToPositionState": Color(0.0, 0.0, 0.545),        # 深蓝 RGB(0, 0, 139)
	"PatrolToPointState": Color(0.5, 0.0, 0.5),           # 紫色 RGB(128, 0, 128)
	"MoveAwayFromTargetState": Color(1.0, 0.27, 0.0),      # 橙红 RGB(255, 69, 0)
	
	# 交互类
	"InteractionState": Color(0.0, 1.0, 0.0),             # 绿色 RGB(0, 255, 0)
	"AttackState": Color(1.0, 0.0, 0.0),                  # 红色 RGB(255, 0, 0)
	"TakeResourceState": Color(0.565, 0.933, 0.565),      # 浅绿 RGB(144, 238, 144)
	"StoreResourceState": Color(0.0, 1.0, 0.498),          # 青绿 RGB(0, 255, 127)
	"TransferResourceState": Color(0.604, 0.804, 0.196),  # 黄绿 RGB(154, 205, 50)
	
	# 等待检查类
	"WaitState": Color(0.5, 0.5, 0.5),                     # 灰色 RGB(128, 128, 128)
	"CheckConditionState": Color(0.827, 0.827, 0.827),    # 浅灰 RGB(211, 211, 211)
	"CheckStorageCapacityState": Color(0.753, 0.753, 0.753), # 银灰 RGB(192, 192, 192)
	"CheckTargetStatusState": Color(0.663, 0.663, 0.663), # 暗灰 RGB(169, 169, 169)
	"PatrolState": Color(1.0, 0.0, 1.0),                  # 紫红 RGB(255, 0, 255)
	"GuardState": Color(0.647, 0.165, 0.165),             # 棕色 RGB(165, 42, 42)
	
	# 扩展状态（工作流专用，如有实现）
	"BuildState": Color(0.0, 0.784, 0.392),                # 金绿色 RGB(0, 200, 100)
	"RepairState": Color(1.0, 0.843, 0.0),                 # 金色 RGB(255, 215, 0)
	"CraftState": Color(0.722, 0.451, 0.2),                # 古铜色 RGB(184, 115, 51)
	"ServiceState": Color(1.0, 0.0, 1.0),                  # 品红 RGB(255, 0, 255)
	"HuntState": Color(0.0, 0.392, 0.0),                   # 深绿 RGB(0, 100, 0)
	"TameState": Color(0.294, 0.0, 0.510),                 # 靛蓝 RGB(75, 0, 130)
}

var _default_color: Color = Color(1.0, 1.0, 1.0)  # 白色（未定义状态）

## 初始化
## unit_id: 单位ID
func setup(unit_id: int) -> void:
	_unit_id = unit_id
	_is_transitioning = false
	_elapsed_time = 0.0

## 触发状态转换动画
## from_state: 原状态名称
## to_state: 目标状态名称
func trigger_transition(from_state: String, to_state: String) -> void:
	_from_state_name = from_state
	_last_state_name = to_state
	_is_transitioning = true
	_blink_effect = true
	_elapsed_time = 0.0

## 更新动画效果
## delta: 帧时间间隔
func update(delta: float) -> void:
	if not _is_transitioning:
		return
	
	_elapsed_time += delta
	
	if _elapsed_time >= _transition_duration:
		_is_transitioning = false
		_blink_effect = false
		_elapsed_time = 0.0

## 获取当前颜色（根据状态和动画进度）
## current_state_name: 当前状态名称
## 返回: 当前应该显示的颜色
func get_current_color(current_state_name: String) -> Color:
	var target_color = _state_colors.get(current_state_name, _default_color)
	
	if _is_transitioning and _elapsed_time < _transition_duration:
		# 在转换过程中，进行颜色插值
		var progress = _elapsed_time / _transition_duration
		
		# 使用ease-in-out缓动函数优化插值曲线
		var eased_progress = _ease_in_out(progress)
		
		var from_color = _state_colors.get(_from_state_name, _default_color)
		var interpolated_color = from_color.lerp(target_color, eased_progress)
		
		# 添加闪烁效果（在转换期间周期性改变亮度）
		if _blink_effect:
			var blink_frequency = 8.0  # 闪烁频率（每秒8次）
			var blink_intensity = 0.3   # 闪烁强度（0.3 = 30%亮度变化）
			var blink_value = sin(_elapsed_time * blink_frequency * TAU) * blink_intensity + (1.0 - blink_intensity)
			interpolated_color = interpolated_color * blink_value
		
		return interpolated_color
	
	return target_color

## Ease-in-out缓动函数
## t: 进度值（0.0到1.0）
## 返回: 缓动后的进度值
func _ease_in_out(t: float) -> float:
	if t < 0.5:
		return 2.0 * t * t
	else:
		return -1.0 + (4.0 - 2.0 * t) * t

## 获取转换进度（0.0到1.0）
## 返回: 转换进度
func get_transition_progress() -> float:
	if not _is_transitioning:
		return 1.0
	return min(_elapsed_time / _transition_duration, 1.0)

## 检查是否正在转换
## 返回: 如果正在转换则返回true
func is_transitioning() -> bool:
	return _is_transitioning

