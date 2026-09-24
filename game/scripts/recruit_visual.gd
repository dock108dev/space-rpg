extends Node2D
## Original directional illustrated cutout. Motion is driven by the shared
## collision-aware follower so animation never implies movement through a wall.
const PARTS := ["far_arm", "far_leg", "near_leg", "torso", "head", "near_arm"]
const PIVOTS := {
	"toward": {"far_arm":Vector2(39,64),"far_leg":Vector2(52,111),"near_leg":Vector2(74,111),"torso":Vector2(64,80),"head":Vector2(63,53),"near_arm":Vector2(86,65)},
	"away": {"far_arm":Vector2(39,64),"far_leg":Vector2(52,111),"near_leg":Vector2(74,111),"torso":Vector2(64,80),"head":Vector2(63,53),"near_arm":Vector2(86,65)},
	"side": {"far_arm":Vector2(55,63),"far_leg":Vector2(61,111),"near_leg":Vector2(72,111),"torso":Vector2(64,80),"head":Vector2(64,53),"near_arm":Vector2(79,67)}
}
var views: Dictionary = {}
var visual := Node2D.new()
var facing := "toward"
var phase := 0.0
var stride := 0.0

func _ready() -> void:
	add_child(visual)
	visual.scale = Vector2.ONE * (94.0 / 164.0)
	for view_id in ["toward", "away", "side"]:
		var view := Node2D.new()
		visual.add_child(view)
		views[view_id] = view
		for part in PARTS:
			var joint := Node2D.new()
			joint.name = part
			joint.position = PIVOTS[view_id][part] - Vector2(64,173)
			view.add_child(joint)
			var sprite := Sprite2D.new()
			sprite.texture = load("res://art/b2/recruit/%s/%s.svg" % [view_id,part])
			sprite.centered = false
			sprite.position = -PIVOTS[view_id][part]
			joint.add_child(sprite)
	update_motion(Vector2.DOWN, false, 0.0)

func update_motion(direction: Vector2, moving: bool, delta: float) -> void:
	if views.is_empty(): return
	if moving and direction.length_squared() > 0.001:
		if absf(direction.x) > absf(direction.y):
			facing = "left" if direction.x < 0 else "right"
		else:
			facing = "away" if direction.y < 0 else "toward"
	var view_id := "side" if facing in ["left", "right"] else facing
	for key in views: views[key].visible = key == view_id
	visual.scale.x = (-1.0 if facing == "left" else 1.0) * (94.0 / 164.0)
	# Restoring exact rest pivots prevents a stalled foot or duplicate-mask gait.
	stride = move_toward(stride, 1.0 if moving else 0.0, delta * 11.0)
	if moving: phase += delta * 10.5
	var step := sin(phase) * stride
	for part in PARTS:
		var joint: Node2D = views[view_id].get_node(part)
		joint.position = PIVOTS[view_id][part] - Vector2(64,173)
		joint.rotation = 0.0
		if part.ends_with("leg"):
			var sign_value := 1.0 if part.begins_with("near") else -1.0
			joint.rotation = step * sign_value * (0.24 if view_id == "side" else 0.055)
			if view_id != "side": joint.position.y += step * sign_value * 4.3
		elif part.ends_with("arm"):
			joint.rotation = step * (-1.0 if part.begins_with("near") else 1.0) * 0.13
		elif part == "torso": joint.position.y -= absf(step) * 1.2
		elif part == "head": joint.position.y -= absf(step) * 0.8
