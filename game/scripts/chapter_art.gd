extends Node2D
## B2 art only. Location collision and chapter state remain controller-owned.
var controller: Node2D
var location := ""
var scenery: Array[Node2D] = []
var background := Sprite2D.new()
var floor_picture := Sprite2D.new()
var marks := Node2D.new()
var package_prop: Node2D
var cache_prop: Node2D
var wall_title := Label.new()
var wall_detail := Label.new()

func configure(owner_controller: Node2D) -> void:
	controller = owner_controller
	z_index = -3
	floor_picture.centered = false
	add_child(floor_picture)
	background.centered = false
	add_child(background)
	add_child(marks)
	for label in [wall_title,wall_detail]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.modulate = Color("e3e0cc")
		add_child(label)
	wall_title.position = Vector2(388,198)
	wall_title.size = Vector2(427,19)
	wall_title.add_theme_font_size_override("font_size",15)
	wall_detail.position = Vector2(388,215)
	wall_detail.size = Vector2(427,16)
	wall_detail.add_theme_font_size_override("font_size",11)
	set_process(true)

func set_location(id: String) -> void:
	for node in scenery:
		if is_instance_valid(node):
			node.hide()
			node.queue_free()
	scenery.clear()
	package_prop = null
	cache_prop = null
	location = id
	wall_title.text = "Temporary shelter" if id == "shelter" else "Shopping concourse"
	wall_detail.text = "Shared refuge · Not owned · Not private" if id == "shelter" else "Collection area · Temporary shelter beyond the east door"
	wall_title.visible = true
	wall_detail.visible = true
	if id == "shelter":
		floor_picture.hide()
		background.texture = load("res://art/b2/shelter_room.svg")
		# Furnishings correspond to controller's blocked cells. Fronts are sorted
		# by the floor contact, allowing actors to pass behind and in front.
		prop("cot", point(Vector2i(2,1)) + Vector2(30,26), Vector2(135,115))
		prop("hamper", point(Vector2i(2,2)) + Vector2(0,25), Vector2(58,65))
		prop("supply_locker", point(Vector2i(8,2)) + Vector2(0,20), Vector2(66,111))
		prop("supply_locker", point(Vector2i(8,3)) + Vector2(0,23), Vector2(67,113))
		prop("bench", point(Vector2i(9,5)) + Vector2(0,24), Vector2(66,64))
		prop("orientation_desk", point(Vector2i(5,1)) + Vector2(0,27), Vector2(85,82))
		prop("doorway", point(Vector2i(0,5)) + Vector2(0,31), Vector2(92,110))
	else:
		floor_picture.show()
		floor_picture.texture = load("res://art/floor/full.png")
		floor_picture.position = Vector2(208,232)
		floor_picture.scale = Vector2(800.0/floor_picture.texture.get_width(),440.0/floor_picture.texture.get_height())
		background.texture = load("res://art/b2/concourse_frame.svg")
		# The framing SVG is transparent over the retained illustrated floor.
		move_child(background,0)
		for cell in [Vector2i(5,3),Vector2i(5,4),Vector2i(3,1)]:
			old_prop("cabinet_b" if cell == Vector2i(3,1) else "cabinet_a",point(cell)+Vector2(32 if cell == Vector2i(5,3) else 0,22),85,116 if cell == Vector2i(5,3) else 52)
		prop("doorway",point(Vector2i(11,1))+Vector2(0,30),Vector2(92,110))
		package_prop = prop("package",point(Vector2i(1,3))+Vector2(0,13),Vector2(42,42))
		cache_prop = prop("cache",point(Vector2i(9,5))+Vector2(0,14),Vector2(43,45))
	if id == "shelter": move_child(floor_picture,0)
	refresh_state()
	queue_redraw()

func point(cell: Vector2i) -> Vector2:
	return Vector2(256,254) + Vector2(cell)*64.0

func prop(asset: String, at: Vector2, size: Vector2) -> Node2D:
	var anchor := Node2D.new()
	anchor.position = at
	controller.sorted.add_child(anchor)
	var picture := Sprite2D.new()
	picture.texture = load("res://art/b2/%s.svg" % asset)
	picture.centered = false
	picture.scale = Vector2(size.x/picture.texture.get_width(),size.y/picture.texture.get_height())
	picture.position = Vector2(-size.x/2.0,-size.y)
	anchor.add_child(picture)
	scenery.append(anchor)
	return anchor

func old_prop(asset: String, at: Vector2, height: float, width: float) -> void:
	var anchor := Node2D.new()
	anchor.position = at
	controller.sorted.add_child(anchor)
	var picture := Sprite2D.new()
	picture.texture = load("res://art/%s/full.png" % asset)
	picture.centered = false
	picture.scale = Vector2.ONE * minf(height/picture.texture.get_height(),width/picture.texture.get_width())
	picture.position = Vector2(-picture.texture.get_width()*picture.scale.x/2.0,-picture.texture.get_height()*picture.scale.y)
	anchor.add_child(picture)
	scenery.append(anchor)

func refresh_state() -> void:
	if not is_instance_valid(controller): return
	if is_instance_valid(package_prop): package_prop.visible = not controller.package_taken
	if is_instance_valid(cache_prop): cache_prop.visible = not controller.cache_taken

func _process(_delta: float) -> void:
	refresh_state()

func _draw() -> void:
	if not is_instance_valid(controller): return
	# Floor markers belong to the art plane; readable text/actions live in UI.
	var door := point(Vector2i(0,5) if location == "shelter" else Vector2i(11,1))
	ink_ellipse(door+Vector2(0,9),Vector2(29,12),Color(0.43,0.70,0.79,0.48))
	draw_line(door+Vector2(-12,9),door+Vector2(12,9),Color("d2e0d0"),2,true)
	if location == "shelter":
		ink_ellipse(point(Vector2i(5,1))+Vector2(0,9),Vector2(25,10),Color(0.72,0.72,0.53,0.38))

func ink_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(32):
		var angle := TAU * float(index) / 32.0
		points.append(center+Vector2(cos(angle)*radius.x,sin(angle)*radius.y))
	draw_colored_polygon(points,color)
