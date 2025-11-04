extends RefCounted
class_name Interactable

## 交互接口
## 定义可交互对象的通用接口

## 执行交互
## unit: 执行交互的单位
## 返回：交互是否成功
func interact(unit: Unit) -> bool:
	return false

## 获取交互类型标识
## 返回：交互类型字符串（如"GoldMine", "DungeonHeart"等）
func get_interaction_type() -> String:
	return ""

## 检查是否可以进行交互
## unit: 尝试交互的单位
## 返回：是否可以交互
func can_interact(unit: Unit) -> bool:
	return true

