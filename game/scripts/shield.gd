extends Node2D
var remaining := 0.0
func trigger() -> void:remaining=1.2;queue_redraw()
func _process(delta:float) -> void:remaining=maxf(remaining-delta,0);queue_redraw()
func _draw() -> void:
	if remaining<=0:return
	var a:=minf(remaining/0.35,1.0)
	draw_set_transform(Vector2(0,-49),0,Vector2(0.64,1))
	draw_circle(Vector2.ZERO,62,Color(0.45,0.84,0.77,0.07*a))
	draw_arc(Vector2.ZERO,62,0,TAU,64,Color(0.6,0.95,0.85,0.65*a),2,true)
	draw_set_transform(Vector2.ZERO)
