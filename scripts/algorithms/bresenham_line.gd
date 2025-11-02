extends RefCounted
class_name BresenhamLine

## Bresenham 线算法
## 计算两点间的直线路径

## 计算两点间的路径点
## 返回从起点到终点的所有点（包含起点和终点）
static func GetLinePoints(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	var x0 = start.x
	var y0 = start.y
	var x1 = end.x
	var y1 = end.y
	
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx - dy
	
	var x = x0
	var y = y0
	
	while true:
		points.append(Vector2i(x, y))
		
		if x == x1 and y == y1:
			break
		
		var e2 = 2 * err
		
		if e2 > -dy:
			err -= dy
			x += sx
		
		if e2 < dx:
			err += dx
			y += sy
	
	return points

