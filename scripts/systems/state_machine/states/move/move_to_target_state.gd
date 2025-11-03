extends BaseState
class_name MoveToTargetState

## 移动到目标状态
## 移动到指定的目标位置，在交互范围内停止

var _target_key: String = "target" # 上下文中目标对象的键
var _interaction_range: float = 1.0 # 交互范围（网格单位）
var _current_path: Array[Vector2i] = [] # 当前移动路径
var _path_index: int = 0 # 当前路径索引
var _current_target_world_pos: Vector2 = Vector2.ZERO # 当前目标的世界坐标位置
var _tile_size: Vector2i = Vector2i(32, 32) # 瓦块大小（用于坐标转换）

## 构造函数
## target_key: 目标在上下文中的键
## interaction_range: 交互范围
func _init(target_key: String = "target", interaction_range: float = 1.0):
	super._init("MoveToTargetState")
	_target_key = target_key
	_interaction_range = interaction_range

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("target_key"):
		var value = context["target_key"]
		if value != null and value is String:
			_target_key = value
	if context.has("interaction_range"):
		var value = context["interaction_range"]
		if value != null and (value is float or value is int):
			_interaction_range = float(value)
	
	# 获取瓦块大小（如果提供）
	var tile_manager = context.get("tile_manager")
	if tile_manager and tile_manager.has_method("GetTileSize"):
		_tile_size = tile_manager.GetTileSize()
	
	# 重置路径
	_current_path.clear()
	_path_index = 0
	_current_target_world_pos = Vector2.ZERO

## 更新状态
## 返回: 状态执行结果（StateResult.Result），到达目标返回SUCCESS，移动中返回RUNNING，无法移动返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取管理器引用和单位信息
	var pathfinding_manager = context.get("pathfinding_manager")
	var tile_manager = context.get("tile_manager")
	var unit = context.get("unit")
	var unit_position = context.get("unit_position", Vector2i(-1, -1))
	
	if not pathfinding_manager or not tile_manager or not unit:
		push_warning("MoveToTargetState: Missing required managers or unit")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	if unit_position == Vector2i(-1, -1):
		push_warning("MoveToTargetState: Invalid unit position")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 根据_target_key获取目标位置键（可能是found_target_position或found_storage_position）
	var target_position_key = "found_target_position" if _target_key == "found_target" else "found_storage_position"
	
	# 从共享上下文获取目标位置
	var target_position = shared_context.get(target_position_key, Vector2i(-1, -1))
	
	if target_position == Vector2i(-1, -1):
		# 目标位置丢失，返回失败（让工作流转换到查找状态）
		push_warning("MoveToTargetState: Target position not found, key=%s" % target_position_key)
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取单位的世界坐标
	var unit_world_pos = unit.get_world_position(_tile_size)
	
	# 计算目标的世界坐标（网格中心）
	var target_world_pos = Vector2(
		float(target_position.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
		float(target_position.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
	)
	
	# 计算到目标的距离（世界坐标，像素）
	var distance_to_target = unit_world_pos.distance_to(target_world_pos)
	var interaction_range_pixels = _interaction_range * float(_tile_size.x) # 交互范围转换为像素
	
	# 检查是否在交互范围内
	if distance_to_target <= interaction_range_pixels:
		# 已到达目标
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 计算或更新路径
	if _current_path.is_empty() or _path_index >= _current_path.size():
		# 需要重新计算路径
		_current_path = pathfinding_manager.find_path(unit_position, target_position)
		_path_index = 0
		_current_target_world_pos = Vector2.ZERO
		
		if _current_path.is_empty():
			# 无法找到路径，尝试直接移动（简化处理：移动到最近的可通行相邻位置）
			var direction = Vector2i(
				sign(target_position.x - unit_position.x),
				sign(target_position.y - unit_position.y)
			)
			var next_pos = unit_position + direction
			if tile_manager.IsWalkable(next_pos):
				# 设置下一个目标位置的世界坐标
				_current_target_world_pos = Vector2(
					float(next_pos.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
					float(next_pos.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
				)
			else:
				# 无法移动，返回失败
				push_warning("MoveToTargetState: Cannot move to target")
				set_result(StateResult.Result.FAILURE)
				return StateResult.Result.FAILURE
	
	# 如果当前目标位置未设置，或已到达当前路径节点，移动到下一个节点
	if _current_target_world_pos == Vector2.ZERO or unit_world_pos.distance_to(_current_target_world_pos) < 1.0:
		if _path_index < _current_path.size():
			var next_pos = _current_path[_path_index]
			
			# 检查下一个位置是否仍然可通行
			if tile_manager.IsWalkable(next_pos):
				# 设置下一个目标位置的世界坐标
				_current_target_world_pos = Vector2(
					float(next_pos.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
					float(next_pos.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
				)
				_path_index += 1
			else:
				# 路径被阻塞，重新计算路径
				_current_path.clear()
				_path_index = 0
				_current_target_world_pos = Vector2.ZERO
				set_result(StateResult.Result.RUNNING)
				return StateResult.Result.RUNNING
	
	# 使用基于速度的平滑移动朝向当前目标位置
	if _current_target_world_pos != Vector2.ZERO:
		unit.move_towards(_current_target_world_pos, delta, 1.0)
		# 如果到达当前路径节点，会在下次循环时移动到下一个节点
	
	# 继续移动中
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
