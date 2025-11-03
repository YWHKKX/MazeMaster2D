extends RefCounted
class_name StateResult

## 状态执行结果枚举
## 用于表示状态的执行结果，供WorkflowExecutor判断是否需要进行状态转换

enum Result {
	RUNNING,   # 正在执行，继续运行（保持当前状态）
	SUCCESS,   # 执行成功，可以转换到成功分支
	FAILURE    # 执行失败，需要转换到失败分支
}

