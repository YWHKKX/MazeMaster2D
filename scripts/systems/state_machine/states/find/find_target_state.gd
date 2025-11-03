extends BaseState
class_name FindTargetState

## 查找目标状态
## 根据目标类型、搜索范围、过滤条件查找目标

var _target_type: String = ""  # 目标类型（如"GoldMine", "Enemy"等）
var _search_range: float = 50.0  # 搜索范围（像素）
var _filter_conditions: Dictionary = {}  # 过滤条件

## 构造函数
## target_type: 目标类型
## search_range: 搜索范围
func _init(target_type: String = "", search_range: float = 50.0):
	super._init("FindTargetState")
	_target_type = target_type
	_search_range = search_range

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	# 从上下文获取参数
	if context.has("target_type"):
		var value = context["target_type"]
		if value != null and value is String:
			_target_type = value
	if context.has("search_range"):
		var value = context["search_range"]
		if value != null and value is float:
			_search_range = value
	if context.has("filter_conditions"):
		var value = context["filter_conditions"]
		if value != null and value is Dictionary:
			_filter_conditions = value

## 更新状态
## 返回: 状态执行结果（StateResult.Result），找到目标返回SUCCESS，未找到返回RUNNING，错误返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取管理器引用
	var tile_manager = context.get("tile_manager")
	var unit_position = context.get("unit_position", Vector2i(-1, -1))
	
	if not tile_manager:
		push_warning("FindTargetState: No tile_manager in context")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	if unit_position == Vector2i(-1, -1):
		push_warning("FindTargetState: No unit_position in context")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 检查是否已经有找到的目标（避免重复查找）
	var existing_target = shared_context.get("found_target")
	if existing_target:
		# 验证目标仍然有效
		var target_pos = shared_context.get("found_target_position", Vector2i(-1, -1))
		if target_pos != Vector2i(-1, -1):
			var target_tile = tile_manager.GetResourceTile(target_pos) if _target_type == "GoldMine" else null
			if target_tile and not target_tile.is_depleted():
				# 目标仍然有效，已经找到
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
			else:
				# 目标已失效，清除
				shared_context.erase("found_target")
				shared_context.erase("found_target_position")
	
	# 根据目标类型查找
	var found = false
	
	match _target_type:
		"GoldMine", "gold_mine":
			# 查找金矿资源
			var result = tile_manager.find_nearest_resource(unit_position, Enums.ResourceType.GOLD, _search_range)
			if result.has("resource") and result.has("position"):
				var resource_tile = result["resource"] as ResourceTile
				var resource_pos = result["position"] as Vector2i
				
				# 检查资源是否还有剩余
				if resource_tile and not resource_tile.is_depleted():
					# 存储找到的目标到共享上下文
					shared_context["found_target"] = resource_tile
					shared_context["found_target_position"] = resource_pos
					found = true
					print("FindTargetState: 找到金矿在位置 %s" % resource_pos)
		
		_:
			# 未知目标类型，返回失败
			push_warning("FindTargetState: Unknown target_type: %s" % _target_type)
			set_result(StateResult.Result.FAILURE)
			return StateResult.Result.FAILURE
	
	if found:
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 未找到目标，继续查找（返回RUNNING保持在当前状态）
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

