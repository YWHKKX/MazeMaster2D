extends RefCounted
class_name Tile

## 瓦块数据结构
## 表示地图上的一个瓦块（离散网格单元）

var position: Vector2i  # 网格坐标位置
var terrain_type: Enums.TerrainType  # 地形类型
var tile_type: Enums.TileType = Enums.TileType.BASIC  # 瓦块类型（普通/建筑/资源）
var is_walkable: bool = true  # 是否可通行
var is_buildable: bool = false  # 是否可建造
var is_diggable: bool = false  # 是否可挖掘

# 建筑数据（如果 tile_type == BUILDING）
var building_data: BuildingTile = null

# 资源数据（如果 tile_type == RESOURCE）
var resource_data: ResourceTile = null

## 构造函数
func _init(p_position: Vector2i, p_terrain_type: Enums.TerrainType):
	position = p_position
	terrain_type = p_terrain_type
	_update_properties()

## 更新所有属性（根据地形类型自动计算）
func _update_properties() -> void:
	match terrain_type:
		Enums.TerrainType.DUG:
			# 已挖掘：可通行、可建造、不可挖掘
			is_walkable = true
			is_buildable = true
			is_diggable = false
		Enums.TerrainType.UNDUG:
			# 未挖掘：不可通行、不可建造、可挖掘
			is_walkable = false
			is_buildable = false
			is_diggable = true
		Enums.TerrainType.WALL:
			# 墙壁：不可通行、不可建造、不可挖掘
			is_walkable = false
			is_buildable = false
			is_diggable = false
		_:
			# 默认：不可通行、不可建造、不可挖掘
			is_walkable = false
			is_buildable = false
			is_diggable = false

## 设置地形类型
func set_terrain_type(type: Enums.TerrainType) -> void:
	terrain_type = type
	_update_properties()

## 获取通行性（保持向后兼容）
func get_walkable() -> bool:
	return is_walkable

## 设置通行性（兼容旧代码，但建议使用set_terrain_type）
func set_walkable(value: bool) -> void:
	is_walkable = value

