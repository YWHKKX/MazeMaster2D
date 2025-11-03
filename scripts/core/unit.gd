extends Entity
class_name Unit

## 单位基类
## 表示地图上的单位（哥布林、地精等）

var faction: Enums.Faction # 阵营
var health: int # 当前生命值
var max_health: int # 最大生命值
var speed: float # 移动速度（像素/秒，基于瓦块/秒配置转换：1瓦块/秒 = 32像素/秒）
var world_position: Vector2 # 世界坐标位置（用于平滑移动，像素坐标）
var _tile_size: Vector2i = Vector2i(32, 32) # 瓦块大小（默认32x32像素）

## 构造函数
## 默认速度：1瓦块/秒 = 32像素/秒（基准速度）
func _init(p_id: int, p_position: Vector2i, p_faction: Enums.Faction, p_max_health: int = 50, p_speed: float = 32.0, tile_size: Vector2i = Vector2i(32, 32)):
	super._init(p_id, p_position, Enums.EntityType.UNIT)
	faction = p_faction
	max_health = p_max_health
	health = max_health
	speed = p_speed
	_tile_size = tile_size
	# 初始化世界坐标（基于网格坐标）
	world_position = Vector2(
		float(position.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
		float(position.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
	)

## 设置瓦块大小（用于坐标转换）
func set_tile_size(tile_size: Vector2i) -> void:
	_tile_size = tile_size
	# 更新世界坐标以匹配当前网格位置
	world_position = Vector2(
		float(position.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
		float(position.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
	)

## 移动到指定位置（网格坐标）- 瞬移版本
## 注意：此方法用于立即设置位置（如初始化、传送等），不会使用速度
func move_to(new_position: Vector2i) -> void:
	position = new_position
	# 同步更新世界坐标到新网格位置的中心
	world_position = Vector2(
		float(position.x) * float(_tile_size.x) + float(_tile_size.x) / 2.0,
		float(position.y) * float(_tile_size.y) + float(_tile_size.y) / 2.0
	)

## 基于速度的平滑移动
## 朝向目标世界坐标移动，每帧移动 speed * delta 像素
## 返回: 是否到达目标位置（距离小于阈值）
func move_towards(target_world_pos: Vector2, delta: float, arrival_threshold: float = 2.0) -> bool:
	var direction = target_world_pos - world_position
	var distance = direction.length()
	
	# 如果已经到达目标，返回true
	if distance <= arrival_threshold:
		world_position = target_world_pos
		# 同步更新网格坐标
		_update_grid_position_from_world()
		return true
	
	# 计算移动距离（速度 * 时间）
	var move_distance = speed * delta
	
	# 如果移动距离超过剩余距离，直接到达目标
	if move_distance >= distance:
		world_position = target_world_pos
		_update_grid_position_from_world()
		return true
	
	# 否则，沿着方向移动指定距离
	var move_vector = direction.normalized() * move_distance
	world_position += move_vector
	
	# 同步更新网格坐标（如果跨越了网格边界）
	_update_grid_position_from_world()
	
	return false

## 从世界坐标更新网格坐标
func _update_grid_position_from_world() -> void:
	var new_grid_pos = Vector2i(
		int(floor(world_position.x / float(_tile_size.x))),
		int(floor(world_position.y / float(_tile_size.y)))
	)
	
	# 只有当网格位置改变时才更新
	if new_grid_pos != position:
		position = new_grid_pos

## 获取当前世界坐标（重写父类方法，使用精确的世界坐标）
## _tile_size_param: 兼容性参数（未使用，保留以兼容父类接口）
@warning_ignore("unused_parameter")
func get_world_position(_tile_size_param: Vector2i = Vector2i(32, 32)) -> Vector2:
	return world_position

## 设置世界坐标位置
func set_world_position(new_world_pos: Vector2) -> void:
	world_position = new_world_pos
	_update_grid_position_from_world()

## 获取显示名称
func get_display_name() -> String:
	return "Unit"

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

## 检查是否死亡
func is_dead() -> bool:
	return health <= 0

## 获取生命值百分比
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)
