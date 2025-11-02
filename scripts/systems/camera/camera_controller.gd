extends Camera2D
class_name CameraController

## 相机控制器
## 实现WASD移动、滚轮缩放、边界限制和平滑跟随

# 相机移动速度
@export var move_speed: float = 400.0

# 缩放速度
@export var zoom_speed: float = 0.1

# 最小/最大缩放
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

# 地图边界
@export var map_bounds: Rect2 = Rect2(0, 0, 6400, 6400)  # 200*32

func _ready():
	# 启用平滑跟随
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _process(delta):
	# WASD 移动
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	
	# 移动速度需要根据缩放调整
	if direction.length() > 0:
		position += direction.normalized() * move_speed * delta / zoom.x
	
	# 边界限制
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.end.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.end.y)

func _input(event):
	# 鼠标滚轮缩放
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in():
	var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func zoom_out():
	var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

