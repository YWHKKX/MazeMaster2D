extends RefCounted
class_name GoblinWorkflows

## 哥布林工作流配置
## 示例：挖矿工作流配置

## 创建挖矿工作流配置
## 返回: WorkflowConfig实例
static func create_mining_workflow() -> WorkflowConfig:
	var config = WorkflowConfig.new("MiningWorkflow", 5, true)
	
	# 状态序列：找矿 -> 移动到金矿 -> 挖矿交互 -> 找金库 -> 移动到金库 -> 存储资源 -> 循环
	# 注意：这里使用简化的状态名称，实际实现时需要完整的状态类名
	
	# 1. 查找金矿目标
	config.add_state("FindTargetState", {
		"target_type": "GoldMine",
		"search_range": 50
	}, {
		"success": "MoveToTargetState",
		"failure": "IdleState"
	})
	
	# 2. 移动到金矿
	config.add_state("MoveToTargetState", {
		"target_key": "found_target",
		"interaction_range": 1.0
	}, {
		"success": "InteractionState",
		"failure": "FindTargetState"
	})
	
	# 3. 挖矿交互
	# InteractionState 会根据共享上下文中的 resource_type 动态设置 resource_output
	# 如果 resource_output 为空，会自动根据资源类型设置默认值（10个资源）
	config.add_state("InteractionState", {
		"interaction_type": "mine",
		"speed": 1.0,
		"resource_output": {}  # 空字典，由 InteractionState 根据 resource_type 动态设置
	}, {
		"success": "FindStorageState",
		"failure": "FindTargetState"
	})
	
	# 4. 查找存储点（根据资源类型自动选择）
	# FindStorageState 会自动从共享上下文获取 resource_type 并选择对应的存储建筑：
	# - GOLD/MANA -> DungeonHeart 或 Treasury
	# - IRON -> MinePit
	# - FOOD -> FoodStorage 或 DungeonHeart
	config.add_state("FindStorageState", {
		"storage_type": "",  # 空字符串，让FindStorageState根据resource_type自动选择
		"resource_type": ""  # 空字符串，从共享上下文获取
	}, {
		"success": "MoveToTargetState",
		"failure": "IdleState"
	})
	
	# 5. 移动到金库（复用MoveToTargetState）
	config.add_state("MoveToTargetState", {
		"target_key": "found_storage",
		"interaction_range": 1.0
	}, {
		"success": "StoreResourceState",
		"failure": "FindStorageState"
	})
	
	# 6. 存储资源
	# StoreResourceState 会从共享上下文获取 carried_resources 并存储所有资源类型
	config.add_state("StoreResourceState", {
		"resource_type": "",  # 空字符串，从共享上下文获取
		"storage_key": "found_storage"
	}, {
		"success": "FindTargetState",  # 循环回到找资源
		"failure": "FindStorageState"
	})
	
	# 设置上下文
	config.set_context(["target_type", "resource_type"], "mining_result")
	
	return config

## 创建逃跑工作流配置（遇敌时使用）
## 返回: WorkflowConfig实例
static func create_flee_workflow() -> WorkflowConfig:
	var config = WorkflowConfig.new("FleeWorkflow", 10, false)  # 高优先级，不可中断
	
	# 状态序列：查找敌人 -> 远离敌人 -> 循环
	config.add_state("FindNearestEnemyState", {
		"alert_range": 30.0,
		"enemy_faction": "ENEMY"
	}, {
		"success": "MoveAwayFromTargetState",
		"failure": "IdleState"
	})
	
	config.add_state("MoveAwayFromTargetState", {
		"target_key": "found_enemy",
		"flee_distance": 50.0
	}, {
		"success": "FindNearestEnemyState",
		"failure": "IdleState"
	})
	
	config.set_context(["enemy_faction"], "flee_result")
	
	return config

## 注册哥布林的所有工作流到注册表
## registry: WorkflowRegistry实例
static func register_all(registry: WorkflowRegistry) -> void:
	# 注册工作流配置
	registry.register_workflow(create_mining_workflow())
	registry.register_workflow(create_flee_workflow())
	
	# 注册单位类型的工作流列表（按启动顺序）
	# 注意：默认启动第一个工作流（MiningWorkflow）
	# FleeWorkflow优先级更高（10），但不会自动启动，作为高优先级中断工作流使用
	registry.register_unit_workflows(
		Enums.SpecificEntityType.UNIT_GOBLIN,
		["MiningWorkflow"]  # 默认启动挖矿工作流
		# FleeWorkflow保留注册但不自动启动，可在遇敌时手动触发
	)

