extends RefCounted
class_name Entity

## 实体基类
## 所有游戏实体的基础类（单位、建筑、资源节点等）

var id: int
var position: Vector2i  # 网格坐标位置
var entity_type: Enums.EntityType  # 实体类型（单位/建筑/资源）

## 构造函数
func _init(p_id: int, p_position: Vector2i, p_entity_type: Enums.EntityType):
	id = p_id
	position = p_position
	entity_type = p_entity_type

## 获取世界坐标位置
## tile_size: 瓦块大小（像素）
func get_world_position(tile_size: Vector2i = Vector2i(32, 32)) -> Vector2:
	return Vector2(position.x * tile_size.x, position.y * tile_size.y)

## 设置位置（网格坐标）
func set_position(new_position: Vector2i) -> void:
	position = new_position

## 获取位置（网格坐标）
func get_position() -> Vector2i:
	return position


