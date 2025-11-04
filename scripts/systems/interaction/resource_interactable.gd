extends Node2D
class_name ResourceInteractable

## 资源交互节点
## 使用 Area2D 实现资源瓦块的交互检测

var _resource_tile: ResourceTile = null
var _area_2d: Area2D = null
var _collision_shape: CollisionShape2D = null

## 初始化
## resource_tile: 资源瓦块实例
## tile_size: 瓦块大小（像素）
func setup(resource_tile: ResourceTile, tile_size: Vector2i = Vector2i(32, 32)) -> void:
	_resource_tile = resource_tile
	
	# 创建 Area2D 节点
	_area_2d = Area2D.new()
	_area_2d.name = "InteractionArea"
	add_child(_area_2d)
	
	# 将节点添加到交互组
	add_to_group("Interactable")
	
	# 根据资源类型添加到特定组
	if resource_tile:
		var resource_type_str = _get_resource_type_string(resource_tile.resource_type)
		if not resource_type_str.is_empty():
			add_to_group("Resource_" + resource_type_str)
	
	# 创建碰撞形状（一个瓦块大小）
	_collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size.x, tile_size.y)
	_collision_shape.shape = shape
	_area_2d.add_child(_collision_shape)
	
	# 连接信号
	_area_2d.body_entered.connect(_on_body_entered)
	_area_2d.body_exited.connect(_on_body_exited)
	
	# 设置监控
	_area_2d.monitoring = true
	_area_2d.monitorable = true

## 获取资源类型字符串
func _get_resource_type_string(resource_type: Enums.ResourceType) -> String:
	match resource_type:
		Enums.ResourceType.GOLD:
			return "GOLD"
		Enums.ResourceType.MANA:
			return "MANA"
		Enums.ResourceType.FOOD:
			return "FOOD"
		Enums.ResourceType.IRON:
			return "IRON"
		_:
			return ""

## 当单位进入交互区域
func _on_body_entered(body: Node2D) -> void:
	# 检查 body 是否有 Unit 脚本（通过检查 Unit 特有的属性或方法）
	if body.has_method("get_display_name") and body.has("id"):
		var unit_id = body.get("id")
		# 通知单位可以交互（可选：可以通过信号或直接调用）
		print("ResourceInteractable: Unit %d entered resource area" % unit_id)

## 当单位离开交互区域
func _on_body_exited(body: Node2D) -> void:
	# 检查 body 是否有 Unit 脚本（通过检查 Unit 特有的属性或方法）
	if body.has_method("get_display_name") and body.has("id"):
		var unit_id = body.get("id")
		print("ResourceInteractable: Unit %d exited resource area" % unit_id)

## 获取资源瓦块
func get_resource_tile() -> ResourceTile:
	return _resource_tile

## 检查是否可以交互
func can_interact(unit: Unit) -> bool:
	if not _resource_tile:
		return false
	return not _resource_tile.is_depleted()

## 执行交互
func interact(unit: Unit) -> bool:
	if not can_interact(unit):
		return false
	# 交互逻辑由 InteractionState 处理
	# 这里主要用于检测和通知
	return true

## 清理
func cleanup() -> void:
	if _area_2d:
		_area_2d.queue_free()
		_area_2d = null
	_collision_shape = null
	_resource_tile = null
