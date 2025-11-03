extends RefCounted
class_name BuildingTile

## 建筑瓦块基类
## 继承自Tile，包含建筑类型（地牢之心、仓库等）
## 注意：BuildingTile 不直接继承 Tile，而是作为 Tile 的数据存储在 tile.building_data 中

var size: Vector2i  # 建筑大小（占用网格数量）
var health: int  # 当前生命值
var max_health: int  # 最大生命值
var is_complete: bool  # 是否建造完成

## 构造函数
func _init(p_size: Vector2i, p_max_health: int = 100):
	size = p_size
	max_health = p_max_health
	health = max_health
	is_complete = true  # 默认已完成（后续阶段可以支持建造中状态）

## 获取建筑占用的边界框（相对于瓦块位置）
## tile_position: 瓦块位置（左上角）
## 返回：边界框
func get_bounds(tile_position: Vector2i) -> Rect2i:
	return Rect2i(tile_position, size)

## 检查指定位置是否在建筑范围内
## tile_position: 瓦块位置（左上角）
## pos: 要检查的位置
func contains_position(tile_position: Vector2i, pos: Vector2i) -> bool:
	var bounds = get_bounds(tile_position)
	return bounds.has_point(pos)

## 受到伤害
func take_damage(amount: int) -> void:
	if amount < 0:
		push_warning("Cannot take negative damage: %d" % amount)
		return
	
	health -= amount
	if health < 0:
		health = 0

## 治疗
func heal(amount: int) -> void:
	if amount < 0:
		push_warning("Cannot heal negative amount: %d" % amount)
		return
	
	health += amount
	if health > max_health:
		health = max_health

## 检查是否被摧毁
func is_destroyed() -> bool:
	return health <= 0

## 获取生命值百分比
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)

