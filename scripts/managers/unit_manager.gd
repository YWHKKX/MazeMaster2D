extends BaseManager
class_name UnitManager

## 单位管理器
## 管理所有地图上的单位

var _units: Array[Unit] = []

## 初始化管理器
func _initialize() -> void:
	_units.clear()

## 清理管理器
func _cleanup() -> void:
	_units.clear()

## 注册单位
func register_unit(unit: Unit) -> void:
	if _units.has(unit):
		push_warning("Unit already registered")
		return
	_units.append(unit)

## 移除单位
func remove_unit(unit: Unit) -> void:
	var index = _units.find(unit)
	if index >= 0:
		_units.remove_at(index)

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

