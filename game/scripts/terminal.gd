extends Node2D
func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-16,0),Vector2(-14,-65),Vector2(12,-70),Vector2(17,-4)]),Color("414a42"))
	draw_rect(Rect2(-10,-59,18,27),Color("9abda8"))
	for y in [-53,-46,-39]:draw_line(Vector2(-7,y),Vector2(5,y),Color("415e53"),2)
	draw_rect(Rect2(-7,-25,13,5),Color("bcab76"))
