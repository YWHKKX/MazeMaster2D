extends BaseManager
class_name UnitManager

## 单位管理器
## 管理所有地图上的单位
## 统一管理StateMachine，通过Unit ID关联
## 在统一update循环中批量更新所有单位的工作流

var _units: Array[Unit] = []
var _state_machines: Dictionary = {}  # unit_id -> StateMachine
var _workflow_manager: WorkflowManager = null
var _workflow_registry: WorkflowRegistry = null

# 管理器引用（用于状态类访问）
var _tile_manager: TileManager = null
var _pathfinding_manager: PathfindingManager = null
var _resource_manager: ResourceManager = null

## 初始化管理器
func _initialize() -> void:
	_units.clear()
	_state_machines.clear()
	
	# 初始化工作流管理器和注册表
	_workflow_manager = WorkflowManager.new()
	_workflow_registry = WorkflowRegistry.new()
	_workflow_manager.set_registry(_workflow_registry)
	
	# 初始化工作流管理器
	if _workflow_manager.has_method("_initialize"):
		_workflow_manager._initialize()

## 清理管理器
func _cleanup() -> void:
	_units.clear()
	_state_machines.clear()
	
	# 清理工作流管理器
	if _workflow_manager and _workflow_manager.has_method("_cleanup"):
		_workflow_manager._cleanup()
	
	_workflow_manager = null
	_workflow_registry = null

## 注册单位
func register_unit(unit: Unit) -> void:
	if _units.has(unit):
		push_warning("Unit already registered")
		return
	_units.append(unit)
	
	# 为单位创建状态机
	var state_machine = StateMachine.new(unit.id)
	_state_machines[unit.id] = state_machine
	
	# 自动注册单位类型的工作流
	_register_unit_workflows(unit)

## 移除单位
func remove_unit(unit: Unit) -> void:
	var index = _units.find(unit)
	if index >= 0:
		_units.remove_at(index)
	
	# 移除状态机和工作流
	if _state_machines.has(unit.id):
		_state_machines.erase(unit.id)
	
	if _workflow_manager:
		_workflow_manager.stop_workflow(unit.id)

## 获取所有单位
func get_all_units() -> Array[Unit]:
	return _units.duplicate()

## 获取指定位置的所有单位
func get_units_at_position(position: Vector2i) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in _units:
		if unit.position == position:
			result.append(unit)
	return result

## 生成单位
## position: 网格坐标位置
## unit_type: 单位类型（目前只支持 Goblin）
## entity_manager: EntityManager 实例（可选，用于注册实体和生成ID）
func spawn_unit(position: Vector2i, unit_type: Enums.SpecificEntityType = Enums.SpecificEntityType.UNIT_GOBLIN, entity_manager: EntityManager = null) -> Unit:
	var id = 0
	if entity_manager:
		id = entity_manager.generate_id()
	else:
		# 如果没有提供 entity_manager，使用随机ID
		id = randi() % 1000000
	
	var unit: Unit = null
	
	match unit_type:
		Enums.SpecificEntityType.UNIT_GOBLIN:
			unit = Goblin.new(id, position)
		_:
			push_error("Unknown unit type: %d" % unit_type)
			return null
	
	register_unit(unit)
	
	# 如果 entity_manager 存在，注册实体
	if entity_manager:
		entity_manager.register_entity(unit)
	
	return unit

## 更新所有单位（统一update循环）
## delta: 帧时间间隔
## 批量更新所有单位的StateMachine和工作流
func update_all_units(delta: float) -> void:
	# 先更新所有状态机（状态机更新可能会触发状态转换）
	for unit_id in _state_machines.keys():
		var state_machine = _state_machines[unit_id]
		
		# 获取单位实例以构建上下文
		var unit = _get_unit_by_id(unit_id)
		var context: Dictionary = {}
		if unit:
			context["unit"] = unit
			context["unit_id"] = unit_id
			context["unit_position"] = unit.position
		
		# 添加管理器引用到上下文（状态类需要访问这些管理器）
		if _tile_manager:
			context["tile_manager"] = _tile_manager
		if _pathfinding_manager:
			context["pathfinding_manager"] = _pathfinding_manager
		if _resource_manager:
			context["resource_manager"] = _resource_manager
		if _workflow_manager:
			context["workflow_manager"] = _workflow_manager
		# 添加状态机引用（IdleState可能需要它来重新启动工作流）
		context["state_machine"] = state_machine
		
		state_machine.update(delta, context)
	
	# 然后更新所有工作流（跟踪工作流进度）
	if _workflow_manager:
		_workflow_manager.update_all(delta)

## 内部方法：根据ID获取单位
## unit_id: 单位ID
## 返回: Unit实例或null
func _get_unit_by_id(unit_id: int) -> Unit:
	for unit in _units:
		if unit.id == unit_id:
			return unit
	return null

## 获取单位的状态机
## unit_id: 单位ID
## 返回: StateMachine或null
func get_state_machine(unit_id: int) -> StateMachine:
	return _state_machines.get(unit_id)

## 获取工作流管理器
## 返回: WorkflowManager实例
func get_workflow_manager() -> WorkflowManager:
	return _workflow_manager

## 获取工作流注册表
## 返回: WorkflowRegistry实例
func get_workflow_registry() -> WorkflowRegistry:
	return _workflow_registry

## 设置管理器引用
## tile_manager: 瓦块管理器
## pathfinding_manager: 寻路管理器
## resource_manager: 资源管理器
func set_managers(tile_manager: TileManager, pathfinding_manager: PathfindingManager, resource_manager: ResourceManager) -> void:
	_tile_manager = tile_manager
	_pathfinding_manager = pathfinding_manager
	_resource_manager = resource_manager

## 内部方法：自动注册单位类型的工作流
## unit: 单位实例
func _register_unit_workflows(unit: Unit) -> void:
	if not _workflow_registry:
		return
	
	# 获取单位类型（需要从unit获取，暂时使用默认方式）
	# 这里需要根据实际的unit类型获取对应的SpecificEntityType
	# 暂时简化处理，假设可以根据unit类名推断
	var state_machine = _state_machines.get(unit.id)
	if not state_machine:
		return
	
	# 第五阶段：注册所有基础状态机到状态机
	StateRegistry.register_all_states(state_machine)
	
	var unit_type: Enums.SpecificEntityType = _get_unit_type(unit)
	
	# 获取该单位类型的工作流列表
	var workflow_names = _workflow_registry.get_unit_workflows(unit_type)
	
	if workflow_names.is_empty():
		# 如果没有注册的工作流，使用默认的空闲状态
		state_machine.change_state("IdleState", {}, "default_idle")
		return
	
	# 启动默认工作流（优先级最高的）
	var default_workflow = workflow_names[0]
	if _workflow_manager:
		_workflow_manager.start_workflow(unit.id, default_workflow, state_machine)

## 内部方法：获取单位类型
## unit: 单位实例
## 返回: SpecificEntityType枚举值
func _get_unit_type(unit: Unit) -> Enums.SpecificEntityType:
	# 根据unit的实际类名推断类型
	if unit is Goblin:
		return Enums.SpecificEntityType.UNIT_GOBLIN
	# 后续添加其他单位类型的判断
	
	return Enums.SpecificEntityType.UNIT_GOBLIN  # 默认返回哥布林

