extends Node2D
class_name StateVisualizer

## 状态机可视化器
## 在单位上显示当前状态和转换动画
## 状态指示器：单位右上角的长方体空心矩形

var _unit_id: int = -1
var _state_machine: StateMachine = null
var _transition_effect: StateTransitionEffect = null
var _last_state_name: String = ""
var _workflow_manager: WorkflowManager = null  # 工作流管理器引用

## 状态指示器配置
var _indicator_position: Vector2 = Vector2(12, -14)  # 相对于单位中心的右上角偏移（单位32x32像素）
var _indicator_size: Vector2 = Vector2(8, 12)  # 宽度x高度（像素）
var _base_indicator_size: Vector2 = Vector2(8, 12)  # 基础尺寸（用于缩放动画）
var _border_width: float = 2.0  # 边框宽度（像素）
var _base_border_width: float = 2.0  # 基础边框宽度（用于动画）
var _scale_effect: float = 1.0  # 缩放效果值（1.0 = 正常大小）

## 初始化
## unit_id: 单位ID
## state_machine: 状态机实例
## workflow_manager: 工作流管理器（可选）
func setup(unit_id: int, state_machine: StateMachine, workflow_manager: WorkflowManager = null) -> void:
	_unit_id = unit_id
	_state_machine = state_machine
	_workflow_manager = workflow_manager
	_last_state_name = ""
	
	# 设置 z_index 确保状态指示器显示在单位之上
	z_index = 20  # 高于 EntityRenderer 的 z_index (10)，确保显示在最上层
	
	# 创建状态转换效果
	_transition_effect = StateTransitionEffect.new()
	_transition_effect.setup(unit_id)
	add_child(_transition_effect)
	
	# 启用绘制
	queue_redraw()

## 更新可视化（每帧调用）
## delta: 帧时间间隔
## unit_position: 单位位置（世界坐标）
func update_visualization(delta: float, unit_position: Vector2) -> void:
	if not _state_machine:
		return
	
	# 更新位置（跟随单位）
	global_position = unit_position
	
	# 获取当前状态名称
	var current_state_name = _state_machine.get_current_state_name()
	
	# 检查状态是否变化
	if current_state_name != _last_state_name:
		if _last_state_name != "":
			# 触发转换动画
			_transition_effect.trigger_transition(_last_state_name, current_state_name)
		_last_state_name = current_state_name
		queue_redraw()  # 状态变化时重绘
	
	# 更新转换效果
	_transition_effect.update(delta)
	
	# 更新缩放效果（状态转换时临时增大）
	var transition_progress = _transition_effect.get_transition_progress()
	if _transition_effect.is_transitioning():
		# 缩放动画：从1.0增长到1.3，然后回到1.0（使用缓动函数）
		var scale_peak = 1.3
		if transition_progress < 0.5:
			# 前半段：增长到峰值
			_scale_effect = 1.0 + (scale_peak - 1.0) * (transition_progress * 2.0)
		else:
			# 后半段：回到正常
			_scale_effect = scale_peak - (scale_peak - 1.0) * ((transition_progress - 0.5) * 2.0)
		_indicator_size = _base_indicator_size * _scale_effect
	else:
		# 不在转换时，保持正常大小
		_scale_effect = 1.0
		_indicator_size = _base_indicator_size
	
	# 持续重绘以确保状态指示器始终显示（即使没有转换也在绘制）
	queue_redraw()

## 绘制状态指示器（空心矩形）
func _draw() -> void:
	if not _state_machine:
		return
	
	# 获取当前状态颜色
	var current_state_name = _state_machine.get_current_state_name()
	var color = _transition_effect.get_current_color(current_state_name)
	
	# 绘制空心矩形（边框）
	var rect = Rect2(_indicator_position, _indicator_size)
	
	# 根据转换进度调整边框宽度（转换时加粗）
	var border_width = _base_border_width
	if _transition_effect.is_transitioning():
		var transition_progress = _transition_effect.get_transition_progress()
		# 在转换期间，边框宽度从2.0增加到3.5，然后回到2.0
		var max_width = 3.5
		if transition_progress < 0.5:
			border_width = _base_border_width + (max_width - _base_border_width) * (transition_progress * 2.0)
		else:
			border_width = max_width - (max_width - _base_border_width) * ((transition_progress - 0.5) * 2.0)
	
	# 绘制四个边框线段
	var top_left = rect.position
	var top_right = Vector2(rect.position.x + rect.size.x, rect.position.y)
	var bottom_left = Vector2(rect.position.x, rect.position.y + rect.size.y)
	var bottom_right = rect.position + rect.size
	
	# 上边框
	draw_line(top_left, top_right, color, border_width)
	# 右边框
	draw_line(top_right, bottom_right, color, border_width)
	# 下边框
	draw_line(bottom_right, bottom_left, color, border_width)
	# 左边框
	draw_line(bottom_left, top_left, color, border_width)
	
	# 绘制工作流信息（如果可用）
	if _workflow_manager:
		var workflow_name = ""
		var progress_text = ""
		
		# 获取工作流执行器
		var executor = _workflow_manager.get_executor(_unit_id)
		if executor:
			workflow_name = executor.get_workflow_name()
			var progress = executor.get_progress()
			if progress.has("current_index") and progress.has("total_count"):
				var current = progress["current_index"]
				var total = progress["total_count"]
				if total > 0:
					progress_text = "%d/%d" % [current + 1, total]
		
		# 在工作流名称下方显示工作流信息（小字体）
		if workflow_name != "":
			var text_position = Vector2(_indicator_position.x, _indicator_position.y + _indicator_size.y + 4)
			# 绘制工作流名称（小字体）
			var font = ThemeDB.fallback_font
			var font_size = 10
			draw_string(font, text_position, workflow_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1.0, 1.0, 1.0))
			
			# 如果有进度信息，在下一行显示
			if progress_text != "":
				var progress_position = Vector2(_indicator_position.x, text_position.y + font_size + 2)
				draw_string(font, progress_position, progress_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.9, 0.9, 0.9))

## 获取状态指示器颜色
## 返回: 当前应该显示的颜色
func get_status_color() -> Color:
	if _transition_effect:
		var current_state = _state_machine.get_current_state_name() if _state_machine else ""
		return _transition_effect.get_current_color(current_state)
	return Color.WHITE

## 清理
func cleanup() -> void:
	if _transition_effect:
		_transition_effect.queue_free()
		_transition_effect = null

