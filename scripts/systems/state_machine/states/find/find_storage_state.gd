extends BaseState
class_name FindStorageState

## 查找存储点状态
## 根据存储点类型、资源类型要求查找存储点

var _storage_type: String = ""  # 存储点类型（如"Treasury", "FoodStorage"等）
var _resource_type: String = ""  # 资源类型要求

## 构造函数
## storage_type: 存储点类型
## resource_type: 资源类型
func _init(storage_type: String = "", resource_type: String = ""):
	super._init("FindStorageState")
	_storage_type = storage_type
	_resource_type = resource_type

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("storage_type"):
		var value = context["storage_type"]
		if value != null and value is String:
			_storage_type = value
	if context.has("resource_type"):
		var value = context["resource_type"]
		if value != null and value is String:
			_resource_type = value

## 更新状态
## 返回: 状态执行结果（StateResult.Result），找到存储点返回SUCCESS，未找到返回RUNNING，错误返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取管理器引用
	var tile_manager = context.get("tile_manager")
	var unit_position = context.get("unit_position", Vector2i(-1, -1))
	
	if not tile_manager:
		push_warning("FindStorageState: No tile_manager in context")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	if unit_position == Vector2i(-1, -1):
		push_warning("FindStorageState: No unit_position in context")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 检查是否已经有找到的存储点（避免重复查找）
	var existing_storage = shared_context.get("found_storage")
	if existing_storage:
		# 验证存储点仍然有效
		var storage_pos = shared_context.get("found_storage_position", Vector2i(-1, -1))
		if storage_pos != Vector2i(-1, -1):
			var storage_building = tile_manager.GetBuildingTile(storage_pos)
			if storage_building and not storage_building.is_destroyed():
				# 存储点仍然有效，已经找到
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
			else:
				# 存储点已失效，清除
				shared_context.erase("found_storage")
				shared_context.erase("found_storage_position")
	
	# 根据存储点类型查找（默认搜索范围较大）
	var search_range = 100.0  # 查找存储点的搜索范围
	var result = tile_manager.find_nearest_building(unit_position, _storage_type, search_range)
	
	if result.has("building") and result.has("position"):
		var building_tile = result["building"] as BuildingTile
		var building_pos = result["position"] as Vector2i
		
		# 检查建筑是否完整
		if building_tile and not building_tile.is_destroyed():
			# 存储找到的存储点到共享上下文
			shared_context["found_storage"] = building_tile
			shared_context["found_storage_position"] = building_pos
			print("FindStorageState: 找到存储点在位置 %s" % building_pos)
			set_result(StateResult.Result.SUCCESS)
			return StateResult.Result.SUCCESS
	
	# 未找到存储点，继续查找（返回RUNNING保持在当前状态）
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)
