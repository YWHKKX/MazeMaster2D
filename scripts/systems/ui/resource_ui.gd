extends Control
class_name ResourceUI

## 资源UI
## 显示玩家资源（金币、魔力、食物）

var _resource_manager: ResourceManager = null

@onready var gold_label: Label = $VBoxContainer/GoldLabel
@onready var mana_label: Label = $VBoxContainer/ManaLabel
@onready var food_label: Label = $VBoxContainer/FoodLabel

## 初始化
func setup(resource_mgr: ResourceManager) -> void:
	_resource_manager = resource_mgr
	_update_display()

## 更新显示
func _update_display() -> void:
	if not _resource_manager:
		return
	
	# 获取资源值
	var gold = _resource_manager.get_gold()
	var mana = _resource_manager.get_mana()
	var food = _resource_manager.get_food()
	
	# 更新标签（如果存在）
	if gold_label:
		gold_label.text = "金币: %d" % gold
	if mana_label:
		mana_label.text = "魔力: %d" % mana
	if food_label:
		food_label.text = "食物: %d" % food

## 刷新显示（外部调用）
func refresh() -> void:
	_update_display()

