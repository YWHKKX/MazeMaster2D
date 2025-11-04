extends BaseState
class_name InteractionState

## 通用交互状态
## 执行通用交互（挖矿、建造等）

var _interaction_type: String = ""  # 交互类型（如"mine", "build"等）
var _speed: float = 1.0  # 交互速度（资源产出速度）
var _resource_output: Dictionary = {}  # 资源产出（资源类型 -> 数量）
var _interaction_progress: float = 0.0  # 交互进度（0.0-1.0）
var _interaction_duration: float = 2.0  # 交互持续时间（秒）

## 构造函数
## interaction_type: 交互类型
## speed: 交互速度
func _init(interaction_type: String = "", speed: float = 1.0):
	super._init("InteractionState")
	_interaction_type = interaction_type
	_speed = speed

## 进入状态
func enter(context: Dictionary = {}) -> void:
	super.enter(context)
	if context.has("interaction_type"):
		var value = context["interaction_type"]
		if value != null and value is String:
			_interaction_type = value
	if context.has("speed"):
		var value = context["speed"]
		if value != null and (value is float or value is int):
			_speed = float(value)
	if context.has("resource_output"):
		var value = context["resource_output"]
		if value != null and value is Dictionary:
			_resource_output = value
	
	# 从共享上下文获取资源类型，动态设置 resource_output
	var shared_context = get_shared_context(context)
	var resource_type_enum = shared_context.get("resource_type")
	if resource_type_enum is Enums.ResourceType:
		# 根据资源类型动态设置 resource_output
		var resource_type_str = ""
		match resource_type_enum:
			Enums.ResourceType.GOLD:
				resource_type_str = "GOLD"
			Enums.ResourceType.IRON:
				resource_type_str = "IRON"
			Enums.ResourceType.FOOD:
				resource_type_str = "FOOD"
			Enums.ResourceType.MANA:
				resource_type_str = "MANA"
		
		if not resource_type_str.is_empty():
			# 如果 resource_output 为空或未包含当前资源类型，则设置默认值
			if _resource_output.is_empty() or not _resource_output.has(resource_type_str):
				_resource_output = {resource_type_str: 10}  # 默认每次提取10个资源
	
	# 重置交互进度
	_interaction_progress = 0.0
	_interaction_duration = 2.0 / _speed if _speed > 0 else 2.0  # 根据速度调整持续时间

## 更新状态
## 返回: 状态执行结果（StateResult.Result），交互完成返回SUCCESS，交互中返回RUNNING，失败返回FAILURE
func update(delta: float, context: Dictionary = {}) -> int:
	# 获取管理器引用和目标资源点
	var tile_manager = context.get("tile_manager")
	var unit_position = context.get("unit_position", Vector2i(-1, -1))
	
	if not tile_manager:
		push_warning("InteractionState: No tile_manager in context")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 获取共享上下文
	var shared_context = get_shared_context(context)
	
	# 从共享上下文获取目标资源点
	var target_resource = shared_context.get("found_target")
	var target_position = shared_context.get("found_target_position", Vector2i(-1, -1))
	
	if not target_resource or target_position == Vector2i(-1, -1):
		# 目标丢失，返回失败
		push_warning("InteractionState: Target resource lost")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 验证目标资源点仍然有效
	var resource_tile = tile_manager.GetResourceTile(target_position)
	if not resource_tile or resource_tile.is_depleted():
		# 资源已耗尽，返回失败
		print("InteractionState: 资源已耗尽")
		set_result(StateResult.Result.FAILURE)
		return StateResult.Result.FAILURE
	
	# 执行交互（根据交互类型）
	match _interaction_type:
		"mine", "Mine":
			# 挖矿交互
			_interaction_progress += delta / _interaction_duration
			
			# 当进度达到100%时，提取资源
			if _interaction_progress >= 1.0:
				# 从资源点提取资源
				_interaction_progress = 0.0  # 重置进度
				
				# 提取资源（根据resource_output配置）
				var carried_resources = shared_context.get("carried_resources", {})
				
				# 获取单位引用以检查最大携带量
				var unit = context.get("unit")
				var max_gold_capacity: int = -1  # -1 表示无限制
				if unit is Goblin:
					max_gold_capacity = (unit as Goblin).get_max_gold_capacity()
				
				for resource_type_str in _resource_output.keys():
					var resource_type: Enums.ResourceType
					match resource_type_str:
						"GOLD", "gold":
							resource_type = Enums.ResourceType.GOLD
						"MANA", "mana":
							resource_type = Enums.ResourceType.MANA
						"FOOD", "food":
							resource_type = Enums.ResourceType.FOOD
						"IRON", "iron":
							resource_type = Enums.ResourceType.IRON
						_:
							continue
					
					var amount = _resource_output[resource_type_str]
					if amount is int:
						# 检查金币携带量限制（仅对哥布林的金币资源）
						var current_carried = carried_resources.get(resource_type_str, 0)
						if resource_type == Enums.ResourceType.GOLD and max_gold_capacity > 0:
							# 如果已到达最大携带量，不再提取
							if current_carried >= max_gold_capacity:
								print("InteractionState: 哥布林金币携带量已达上限 (%d/%d)" % [current_carried, max_gold_capacity])
								continue
							# 计算还能携带多少
							var remaining_capacity = max_gold_capacity - current_carried
							if amount > remaining_capacity:
								amount = remaining_capacity
								print("InteractionState: 调整提取量以符合携带上限 (%d -> %d)" % [_resource_output[resource_type_str], amount])
						
						# 从资源点提取
						var extracted = resource_tile.extract_resource(amount)
						
						# 将资源添加到单位携带的资源中
						if not carried_resources.has(resource_type_str):
							carried_resources[resource_type_str] = 0
						carried_resources[resource_type_str] = carried_resources[resource_type_str] + extracted
				
				# 存储携带的资源到共享上下文
				shared_context["carried_resources"] = carried_resources
				
				print("InteractionState: 挖矿完成，获得资源: %s" % carried_resources)
				
				# 交互完成
				set_result(StateResult.Result.SUCCESS)
				return StateResult.Result.SUCCESS
		
		_:
			# 未知交互类型
			push_warning("InteractionState: Unknown interaction_type: %s" % _interaction_type)
			set_result(StateResult.Result.FAILURE)
			return StateResult.Result.FAILURE
	
	# 继续交互中
	set_result(StateResult.Result.RUNNING)
	return StateResult.Result.RUNNING

## 退出状态
func exit(context: Dictionary = {}) -> void:
	super.exit(context)

