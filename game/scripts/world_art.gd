extends "res://scripts/chapter_art.gd"
func set_location(id:String) -> void:
	if id not in ["hub","approach"]:
		super.set_location(id)
		if id=="shelter":prop("doorway",point(Vector2i(11,5))+Vector2(0,30),Vector2(92,110))
		return
	for node in scenery:
		if is_instance_valid(node):node.hide();node.queue_free()
	scenery.clear();package_prop=null;cache_prop=null;location=id;floor_picture.hide()
	background.texture=load("res://art/b3/"+id+".svg");background.show()
	wall_title.text="District hub" if id=="hub" else "Expedition approach"
	wall_detail.text="Optional work · Shared public arcade" if id=="hub" else "Exploration only · Expedition barrier closed"
	for destination in controller.world_doors():prop("doorway",point(controller.world_doors()[destination])+Vector2(0,30),Vector2(92,110))
	if id=="hub":
		for y in [1,2,4,5]:world_prop("partition",point(Vector2i(5,y))+Vector2(0,25),Vector2(62,92))
		if controller.tasks.access!="completed":world_prop("gate",point(Vector2i(5,3))+Vector2(0,25),Vector2(62,86))
		world_prop("board",point(Vector2i(3,2))+Vector2(0,25),Vector2(65,100))
		world_prop("panel",point(Vector2i(5,2))+Vector2(-4,26),Vector2(38,50))
		world_prop("pallet_empty" if controller.tasks.supplies=="completed" else "pallet",point(Vector2i(8,4))+Vector2(0,25),Vector2(65,62))
	else:
		for cell in [Vector2i(3,2),Vector2i(4,2),Vector2i(7,4),Vector2i(8,4)]:world_prop("rock",point(cell)+Vector2(0,25),Vector2(65,74))
		world_prop("survey",point(Vector2i(9,1))+Vector2(0,25),Vector2(52,90))
	queue_redraw()
func world_prop(asset:String,at:Vector2,size:Vector2) -> Node2D:
	var anchor:=Node2D.new();anchor.position=at;controller.sorted.add_child(anchor)
	var picture:=Sprite2D.new();picture.texture=load("res://art/b3/"+asset+".svg");picture.centered=false;picture.scale=Vector2(size.x/picture.texture.get_width(),size.y/picture.texture.get_height());picture.position=Vector2(-size.x/2,-size.y);anchor.add_child(picture);scenery.append(anchor);return anchor
func _draw() -> void:
	if location=="home":return
	if location not in ["hub","approach"]:super._draw();return
	for destination in controller.world_doors():ink_ellipse(point(controller.world_doors()[destination])+Vector2(0,9),Vector2(29,12),Color(0.43,0.70,0.79,0.48))
	if location=="hub" and controller.tasks.access=="completed":
		draw_line(point(Vector2i(4,3)),point(Vector2i(6,3)),Color("a8cbb9"),4,true)
