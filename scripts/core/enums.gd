extends RefCounted
class_name Enums

## 地形类型枚举
enum TerrainType {
	UNDUG,  # 未挖掘
	DUG,    # 已挖掘
	WALL    # 墙壁
}

## 空洞类型枚举
enum CavityType {
	CRITICAL,    # 关键建筑空洞（地牢之心、传送门、英雄营地等）
	FUNCTIONAL,  # 功能区域空洞（支持后续房间、迷宫系统）
	ECOSYSTEM    # 生态区域空洞（支持后续生态系统）
}

## 实体类型枚举（为后续阶段预留）
enum EntityType {
	UNIT,      # 单位
	BUILDING,  # 建筑
	RESOURCE   # 资源
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

