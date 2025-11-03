extends RefCounted
class_name Enums

## 地形类型枚举
enum TerrainType {
	UNDUG,  # 未挖掘
	DUG,    # 已挖掘
	WALL    # 墙壁
}

## 瓦块类型枚举（用于区分普通瓦块、建筑瓦块、资源瓦块）
enum TileType {
	BASIC,      # 普通瓦块（只有地形信息）
	BUILDING,   # 建筑瓦块（包含建筑数据）
	RESOURCE    # 资源瓦块（包含资源数据）
}

## 空洞类型枚举
enum CavityType {
	CRITICAL,    # 关键建筑空洞（地牢之心、传送门、英雄营地等）
	FUNCTIONAL,  # 功能区域空洞（支持后续房间、迷宫系统）
	ECOSYSTEM    # 生态区域空洞（支持后续生态系统）
}

## 空洞大小枚举
enum CavitySize {
	SMALL,   # 小空洞
	MEDIUM,  # 中空洞
	LARGE    # 大空洞
}

## 实体类型枚举（为后续阶段预留）
enum EntityType {
	UNIT,      # 单位
	BUILDING,  # 建筑
	RESOURCE   # 资源
}

## 具体实体类型枚举（扩展 EntityType）
enum SpecificEntityType {
	# 单位类型
	UNIT_GOBLIN,      # 哥布林
	
	# 建筑类型
	BUILDING_DUNGEON_HEART,  # 地牢之心
	
	# 资源节点类型
	RESOURCE_GOLD_MINE  # 金矿
}

## 资源类型枚举（为后续阶段预留）
enum ResourceType {
	GOLD,    # 金币
	MANA,    # 魔力
	FOOD,    # 食物
	IRON     # 铁矿
}

## 阵营枚举（为后续阶段预留）
enum Faction {
	PLAYER,   # 玩家
	ENEMY,    # 敌人
	NEUTRAL   # 中立
}

