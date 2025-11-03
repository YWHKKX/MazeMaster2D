extends RefCounted
class_name StateRegistry

## 状态注册辅助类
## 提供便捷方法注册所有基础状态机到StateMachine

## 注册所有基础状态机到状态机
## state_machine: 状态机实例
static func register_all_states(state_machine: StateMachine) -> void:
	if not state_machine:
		push_error("StateRegistry: Invalid state machine")
		return
	
	# 查找类（3种）
	state_machine.register_state("FindTargetState", FindTargetState.new())
	state_machine.register_state("FindStorageState", FindStorageState.new())
	state_machine.register_state("FindNearestEnemyState", FindNearestEnemyState.new())
	
	# 移动类（4种）
	state_machine.register_state("MoveToTargetState", MoveToTargetState.new())
	state_machine.register_state("MoveToPositionState", MoveToPositionState.new())
	state_machine.register_state("PatrolToPointState", PatrolToPointState.new())
	state_machine.register_state("MoveAwayFromTargetState", MoveAwayFromTargetState.new())
	
	# 交互类（5种）
	state_machine.register_state("InteractionState", InteractionState.new())
	state_machine.register_state("AttackState", AttackState.new())
	state_machine.register_state("TakeResourceState", TakeResourceState.new())
	state_machine.register_state("StoreResourceState", StoreResourceState.new())
	state_machine.register_state("TransferResourceState", TransferResourceState.new())
	
	# 等待检查类（6种）
	state_machine.register_state("WaitState", WaitState.new())
	state_machine.register_state("CheckConditionState", CheckConditionState.new())
	state_machine.register_state("CheckStorageCapacityState", CheckStorageCapacityState.new())
	state_machine.register_state("CheckTargetStatusState", CheckTargetStatusState.new())
	state_machine.register_state("PatrolState", PatrolState.new())
	state_machine.register_state("GuardState", GuardState.new())
	
	# 行为类（2种）
	state_machine.register_state("IdleState", IdleState.new())
	state_machine.register_state("FleeState", FleeState.new())

## 注册特定类型的状态机
## state_machine: 状态机实例
## state_types: 状态类型数组（如["find", "move"]）
static func register_states_by_type(state_machine: StateMachine, state_types: Array[String]) -> void:
	if not state_machine:
		return
	
	for type in state_types:
		match type:
			"find":
				state_machine.register_state("FindTargetState", FindTargetState.new())
				state_machine.register_state("FindStorageState", FindStorageState.new())
				state_machine.register_state("FindNearestEnemyState", FindNearestEnemyState.new())
			"move":
				state_machine.register_state("MoveToTargetState", MoveToTargetState.new())
				state_machine.register_state("MoveToPositionState", MoveToPositionState.new())
				state_machine.register_state("PatrolToPointState", PatrolToPointState.new())
				state_machine.register_state("MoveAwayFromTargetState", MoveAwayFromTargetState.new())
			"interaction":
				state_machine.register_state("InteractionState", InteractionState.new())
				state_machine.register_state("AttackState", AttackState.new())
				state_machine.register_state("TakeResourceState", TakeResourceState.new())
				state_machine.register_state("StoreResourceState", StoreResourceState.new())
				state_machine.register_state("TransferResourceState", TransferResourceState.new())
			"check":
				state_machine.register_state("WaitState", WaitState.new())
				state_machine.register_state("CheckConditionState", CheckConditionState.new())
				state_machine.register_state("CheckStorageCapacityState", CheckStorageCapacityState.new())
				state_machine.register_state("CheckTargetStatusState", CheckTargetStatusState.new())
				state_machine.register_state("PatrolState", PatrolState.new())
				state_machine.register_state("GuardState", GuardState.new())
			"behavior":
				state_machine.register_state("IdleState", IdleState.new())
				state_machine.register_state("FleeState", FleeState.new())

