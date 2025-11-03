extends Control
class_name DebugPanel

## 简单控制面板
## 用于召唤哥布林单位，参考召唤怪物面板设计

signal spawn_unit_requested(unit_type: Enums.SpecificEntityType)

var _selected_unit_type: Enums.SpecificEntityType = Enums.SpecificEntityType.UNIT_GOBLIN

@onready var unit_card: Panel = $UnitCard
@onready var unit_image: TextureRect = $UnitCard/VBoxContainer/UnitImage
@onready var unit_name_label: Label = $UnitCard/VBoxContainer/UnitNameLabel
@onready var summon_button: Button = $UnitCard/VBoxContainer/SummonButton
@onready var info_label: Label = $UnitCard/VBoxContainer/InfoLabel

func _ready():
	_setup_ui()
	
	if summon_button:
		summon_button.pressed.connect(_on_summon_button_pressed)

## 设置UI
func _setup_ui() -> void:
	# 加载哥布林图片
	var goblin_texture = load("res://img/Monster/哥布林.png")
	if goblin_texture and unit_image:
		unit_image.texture = goblin_texture
		unit_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 设置单位名称
	if unit_name_label:
		unit_name_label.text = "哥布林"
	
	# 设置按钮文本
	if summon_button:
		summon_button.text = "召唤"
	
	# 初始提示信息
	if info_label:
		info_label.text = "点击按钮后在地图上点击位置召唤哥布林"

## 召唤按钮回调
func _on_summon_button_pressed() -> void:
	spawn_unit_requested.emit(_selected_unit_type)
	_update_info("在地图上点击位置召唤哥布林")

## 更新信息标签
func _update_info(text: String) -> void:
	if info_label:
		info_label.text = text

## 获取选中的单位类型
func get_selected_unit_type() -> Enums.SpecificEntityType:
	return _selected_unit_type
