extends BaseState
class_name StoreResourceState

## 存储资源状态
## 将资源存储到存储点

var _resource_type: String = ""  # 资源类型
var _storage_key: String = "storage"  # 存储点在上下文中的键

## 构造函数
## resource_type: 资源类型
## storage_key: 存储点键
func _init(resource_type: String = "", storage_key: String = "storage"):
	super._init("StoreResourceState")
	_resource_type = resource_type
	_storage_key = storage_key

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("resource_type"):
		var value = context["resource_type"]
		if value != null and value is String:
			_resource_type = value
	if context.has("storage_key"):
		var value = context["storage_key"]
		if value != null and value is String:
			_storage_key = value

## 更新状态
## 返回: 状态执行结果（StateResult.Result），存储完成返回SUCCESS，失败返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取管理器引用
	var resource_manager = context.get("resource_manager")
	var tile_manager = context.get("tile_manager")
	
	if not resource_manager or not tile_manager:
		push_warning("StoreResourceState: Missing required managers")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 从共享上下文获取存储建筑
	var storage_building = shared_context.get(_storage_key)
	var storage_position = shared_context.get(_storage_key + "_position", Vector2i(-1, -1))
	
	if not storage_building or storage_position == Vector2i(-1, -1):
		# 存储点丢失，返回失败
		push_warning("StoreResourceState: Storage building lost")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 验证存储建筑仍然有效
	var building_tile = tile_manager.GetBuildingTile(storage_position)
	if not building_tile or building_tile.is_destroyed():
		push_warning("StoreResourceState: Storage building destroyed")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 从共享上下文获取单位携带的资源
	var carried_resources = shared_context.get("carried_resources", {})
	
	if carried_resources.is_empty():
		# 没有资源需要存储，返回成功（因为已经完成了）
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 存储资源到建筑（如果是DungeonHeartTile，使用其资源容器）
	var stored_any = false
	
	if storage_building is DungeonHeartTile:
		var dungeon_heart = storage_building as DungeonHeartTile
		
		for resource_type_str in carried_resources.keys():
			var amount = carried_resources[resource_type_str]
			if amount <= 0:
				continue
			
			var resource_type: Enums.ResourceType
			match resource_type_str:
				"GOLD", "gold":
					resource_type = Enums.ResourceType.GOLD
				"MANA", "mana":
					resource_type = Enums.ResourceType.MANA
				"FOOD", "food":
					resource_type = Enums.ResourceType.FOOD
				_:
					continue
			
			# 存储到地牢之心
			dungeon_heart.add_resource(resource_type, amount)
			stored_any = true
			print("StoreResourceState: 存储 %d %s 到地牢之心" % [amount, resource_type_str])
		
		# 同时更新全局资源管理器（用于UI显示）
		if carried_resources.has("GOLD") or carried_resources.has("gold"):
			var gold_amount = carried_resources.get("GOLD", carried_resources.get("gold", 0))
			if gold_amount > 0:
				resource_manager.add_gold(gold_amount)
		
		if carried_resources.has("MANA") or carried_resources.has("mana"):
			var mana_amount = carried_resources.get("MANA", carried_resources.get("mana", 0))
			if mana_amount > 0:
				resource_manager.add_mana(mana_amount)
		
		if carried_resources.has("FOOD") or carried_resources.has("food"):
			var food_amount = carried_resources.get("FOOD", carried_resources.get("food", 0))
			if food_amount > 0:
				resource_manager.add_food(food_amount)
	else:
		# 其他类型的存储建筑，暂时直接添加到全局资源管理器
		for resource_type_str in carried_resources.keys():
			var amount = carried_resources[resource_type_str]
			if amount <= 0:
				continue
			
			match resource_type_str:
				"GOLD", "gold":
					resource_manager.add_gold(amount)
				"MANA", "mana":
					resource_manager.add_mana(amount)
				"FOOD", "food":
					resource_manager.add_food(amount)
			
			stored_any = true
			print("StoreResourceState: 存储 %d %s" % [amount, resource_type_str])
	
	if stored_any:
		# 清除共享上下文中携带的资源
		shared_context.erase("carried_resources")
		print("StoreResourceState: 存储完成")
		set_result(StateResult.Result.SUCCESS)
		return StateResult.Result.SUCCESS
	
	# 没有资源需要存储，返回成功
	set_result(StateResult.Result.SUCCESS)
	return StateResult.Result.SUCCESS

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

