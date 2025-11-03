extends BaseManager
class_name EntityManager

## 实体管理器
## 统一管理所有游戏实体

var _entities: Dictionary = {}  # 所有实体的字典（key=id, value=Entity）
var _next_id: int = 0  # 下一个可用的实体ID

## 初始化管理器
func _initialize() -> void:
	_entities.clear()
	_next_id = 0

## 清理管理器
func _cleanup() -> void:
	_entities.clear()
	_next_id = 0

## 生成新的实体ID
func generate_id() -> int:
	var id = _next_id
	_next_id += 1
	return id

## 注册实体
func register_entity(entity: Entity) -> void:
	if _entities.has(entity.id):
		push_warning("Entity with ID %d already exists" % entity.id)
		return
	_entities[entity.id] = entity

## 获取实体
func get_entity(id: int) -> Entity:
	return _entities.get(id)

## 移除实体
func remove_entity(id: int) -> void:
	if _entities.has(id):
		_entities.erase(id)

## 获取指定位置的所有实体
func get_entities_at_position(pos: Vector2i) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in _entities.values():
		if entity.position == pos:
			result.append(entity)
	return result

## 获取所有实体
func get_all_entities() -> Array[Entity]:
	return _entities.values()

## 检查指定位置是否有实体
func has_entity_at_position(pos: Vector2i) -> bool:
	return not get_entities_at_position(pos).is_empty()

## 获取指定类型的所有实体
func get_entities_by_type(entity_type: Enums.EntityType) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in _entities.values():
		if entity.entity_type == entity_type:
			result.append(entity)
	return result
