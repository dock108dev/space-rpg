extends CharacterBody2D

const SPEED := 100.0
var direction := Vector2.ZERO
var facing := "toward"
var groups: Dictionary = {}
var animations: Dictionary = {}
var visual := Node2D.new()
var automated := false
var actual_travel := Vector2.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	add_child(shape)
	visual.name = "Illustration"
	add_child(visual)
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://art/human/rig.json"))
	for view in data:
		build_view(view)
	show_facing()

func build_view(data: Dictionary) -> void:
	var group := Node2D.new()
	group.name = data.facing
	visual.add_child(group)
	groups[data.facing] = group
	var s := 100.0 / (float(data.foot[1]) - float(data.top))
	group.scale = Vector2(s,s)
	var order := ["far_arm", "far_leg", "near_leg", "torso", "head", "near_arm"]
	for part in order:
		var pivot := Vector2(data.pivots[part][0], data.pivots[part][1])
		var joint := Node2D.new()
		joint.name = part
		joint.position = pivot - Vector2(data.foot[0],data.foot[1])
		group.add_child(joint)
		var sprite := Sprite2D.new()
		sprite.texture = load("res://art/human/%s/%s.png" % [data.facing,part])
		sprite.centered = false
		sprite.position = -pivot
		joint.add_child(sprite)
	var player := AnimationPlayer.new()
	group.add_child(player)
	var library := AnimationLibrary.new()
	var walk := Animation.new()
	walk.length = 0.64
	walk.loop_mode = Animation.LOOP_LINEAR
	for part in ["far_leg","near_leg","far_arm","near_arm"]:
		var sign_value := 1.0 if part.begins_with("near") else -1.0
		if part.ends_with("arm"): sign_value *= -1.0
		var amplitude := 0.32 if data.facing == "side" else 0.045
		if part.ends_with("arm"): amplitude *= 0.65
		var track := walk.add_track(Animation.TYPE_VALUE)
		walk.track_set_path(track,NodePath(part+":rotation"))
		for k in range(5):
			walk.track_insert_key(track,k*0.16,cos(k*PI/2.0)*amplitude*sign_value)
		if data.facing != "side" and part.ends_with("leg"):
			var pos_track := walk.add_track(Animation.TYPE_VALUE)
			walk.track_set_path(pos_track,NodePath(part+":position"))
			var base: Vector2 = group.get_node(part).position
			for k in range(5):
				walk.track_insert_key(pos_track,k*0.16,base+Vector2(0,cos(k*PI/2.0)*65*sign_value))
	library.add_animation("walk",walk)
	player.add_animation_library("",library)
	animations[data.facing] = player

func show_facing() -> void:
	var selected := "side" if facing in ["left","right"] else facing
	for key in groups:
		groups[key].visible = key == selected
	visual.scale.x = -1.0 if facing == "left" else 1.0

func input_direction() -> Vector2:
	return Input.get_vector("left","right","up","down")

func _physics_process(_delta: float) -> void:
	if not automated: direction = input_direction()
	var movement := direction.limit_length(1.0)
	if movement.length_squared() > 0.001:
		if absf(movement.x) > absf(movement.y): facing = "right" if movement.x>0 else "left"
		else: facing = "toward" if movement.y>0 else "away"
	show_facing()
	var previous := position
	velocity = movement * SPEED
	move_and_slide()
	actual_travel = position-previous
	for key in animations:
		var player: AnimationPlayer = animations[key]
		if actual_travel.length_squared() > 0.001:
			if not player.is_playing(): player.play("walk")
		else:
			player.stop()
			for part in ["far_leg","near_leg","far_arm","near_arm"]:
				groups[key].get_node(part).rotation = 0.0
			# Rest position is the middle passing pose, without carrying a half-step into idle.
			player.play("walk");player.seek(0.16,true);player.pause()
