extends Node2D
const START := Vector2(450,540)
const PET_START := Vector2(410,555)
const TERMINAL := Vector2(295,515)
const DEMO_CONTROL := Vector2(920,575)
const DOOR_CENTER := Vector2(925,350)
var human: CharacterBody2D
var pet: CharacterBody2D
var creature: Node2D
var shield: Node2D
var sorted := Node2D.new()
var navigation := NavigationRegion2D.new()
var solids: Array[Rect2] = []
var label := Label.new()
var cue := Label.new()
var response := Label.new()
var elapsed := 0.0
var response_time := 0.0
var interaction_count := 0
var demo := false
var blocked := false
var blocker: StaticBody2D
var lintel: Node2D
var focused := true
var route: Array[Vector2] = [Vector2(450,440),Vector2(460,350),Vector2(685,350),Vector2(710,475),Vector2(925,445),Vector2(925,265),Vector2(990,265),Vector2(925,445),Vector2(450,540)]
var route_index := 0

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	setup_input()
	var floor_sprite:=Sprite2D.new();floor_sprite.texture=load("res://art/floor/full.png");floor_sprite.centered=false;floor_sprite.z_index=-1
	floor_sprite.position=Vector2(120,185);floor_sprite.scale=Vector2(1040.0/floor_sprite.texture.get_width(),475.0/floor_sprite.texture.get_height());add_child(floor_sprite)
	sorted.name="FootSorted";sorted.y_sort_enabled=true;sorted.process_mode=Node.PROCESS_MODE_PAUSABLE;add_child(sorted)
	# Single source of geometry for physical walls and navigation clearance.
	for rect in [Rect2(115,180,1040,10),Rect2(115,650,1040,10),Rect2(115,180,10,480),Rect2(1145,180,10,480),Rect2(495,413,130,42),Rect2(310,286,60,26),Rect2(280,500,30,18),Rect2(765,185,15,165),Rect2(1090,185,15,165),Rect2(780,328,70,22),Rect2(1020,328,70,22)]:
		solids.append(rect);add_solid(rect)
	prop("cabinet_a",Vector2(560,455),85)
	prop("cabinet_b",Vector2(340,312),130)
	# Posts/lintel are separate visual parts with a common complete-frame alignment.
	for part in ["left","right","lintel"]:
		var n:=Node2D.new();n.position=DOOR_CENTER;sorted.add_child(n)
		var sprite:=Sprite2D.new();sprite.texture=load("res://art/doorway/"+part+".png");sprite.centered=false;sprite.scale=Vector2(330.0/1272,215.0/881);sprite.position=Vector2(-165,-215);n.add_child(sprite)
		if part=="lintel":lintel=n
	# Matching stone side/rear pieces authored from the doorway's stone post surface.
	for rect in [Rect2(765,122,15,220),Rect2(1090,122,15,220),Rect2(765,120,340,65)]:
		var wall:=Sprite2D.new();var stone:=AtlasTexture.new();stone.atlas=load("res://art/doorway/full.png");stone.region=Rect2(28,370,112,160)
		wall.texture=stone;wall.centered=false;wall.position=rect.position;wall.scale=rect.size/Vector2(112,160);add_child(wall);move_child(wall,1)

	var terminal:=Node2D.new();terminal.position=TERMINAL;terminal.set_script(load("res://scripts/terminal.gd"));sorted.add_child(terminal)
	creature=load("res://scripts/creature_demo.gd").new();creature.position=Vector2(1040,575);sorted.add_child(creature)
	human=load("res://scripts/human_controller.gd").new();human.name="Human";human.position=START;sorted.add_child(human)
	shield=load("res://scripts/shield.gd").new();human.add_child(shield)
	pet=load("res://scripts/pet_follow.gd").new();pet.name="Pet";pet.position=PET_START;pet.target=human;sorted.add_child(pet)
	add_child(navigation);build_navigation()
	var canvas:=CanvasLayer.new();add_child(canvas)
	label.position=Vector2(40,28);label.add_theme_font_size_override("font_size",22);canvas.add_child(label)
	cue.add_theme_font_size_override("font_size",18);cue.add_theme_color_override("font_color",Color("f6e9af"));canvas.add_child(cue)
	response.position=Vector2(40,682);response.add_theme_font_size_override("font_size",18);canvas.add_child(response)
	demo="--motion-demo" in OS.get_cmdline_user_args();human.automated=demo
	print("VISIBLE_ENV ",JSON.stringify({"window":DisplayServer.window_get_size(),"screen":DisplayServer.screen_get_size(),"scale":DisplayServer.screen_get_scale(),"renderer":RenderingServer.get_current_rendering_method()}))

func setup_input() -> void:
	var keys:={"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN]}
	for action in keys:
		if not InputMap.has_action(action):InputMap.add_action(action)
		for key in keys[action]:
			var event:=InputEventKey.new();event.physical_keycode=key
			if not InputMap.action_has_event(action,event):InputMap.action_add_event(action,event)

func prop(asset:String,at:Vector2,height:float) -> Node2D:
	var n:=Node2D.new();n.position=at;sorted.add_child(n)
	var sprite:=Sprite2D.new();sprite.texture=load("res://art/"+asset+"/full.png");sprite.centered=false;sprite.scale=Vector2.ONE*height/sprite.texture.get_height();sprite.position=Vector2(-sprite.texture.get_width()*sprite.scale.x/2,-height);n.add_child(sprite);return n

func add_solid(rect:Rect2) -> StaticBody2D:
	var body:=StaticBody2D.new();body.position=rect.get_center()
	var c:=CollisionShape2D.new();var shape:=RectangleShape2D.new();shape.size=rect.size;c.shape=shape;body.add_child(c);add_child(body);return body

func build_navigation() -> void:
	var mesh:=NavigationPolygon.new();var vertices:=PackedVector2Array();var ids:={};var polys:Array[PackedInt32Array]=[]
	var obstacles:=solids.duplicate()
	if blocked:obstacles.append(Rect2(850,328,170,22))
	for y in range(200,640,10):
		for x in range(140,1130,10):
			var cell:=Rect2(x,y,10,10);var usable:=true
			for obstacle in obstacles:
				if cell.intersects(obstacle.grow(12)):usable=false;break
			if not usable:continue
			var poly:=PackedInt32Array()
			for point in [Vector2(x,y),Vector2(x+10,y),Vector2(x+10,y+10),Vector2(x,y+10)]:
				if not ids.has(point):ids[point]=vertices.size();vertices.append(point)
				poly.append(ids[point])
			polys.append(poly)
	mesh.vertices=vertices
	for poly in polys:mesh.add_polygon(poly)
	navigation.navigation_polygon=mesh

func set_route_blocked(value:bool) -> void:
	if value==blocked:return
	blocked=value
	if blocked:blocker=add_solid(Rect2(850,328,170,22))
	elif is_instance_valid(blocker):blocker.queue_free()
	build_navigation();pet.refresh=0

func available_interaction() -> String:
	if human.position.distance_to(TERMINAL)<65:return "terminal"
	if human.position.distance_to(DEMO_CONTROL)<62:return "creature"
	return ""

func interact() -> void:
	if get_tree().paused:return
	match available_interaction():
		"terminal":
			interaction_count+=1;response.text="Local terminal ready. Route display checked.";response_time=2.2
		"creature":creature.advance()

func reset_sample() -> void:
	human.position=START;human.direction=Vector2.ZERO;human.velocity=Vector2.ZERO;human.facing="toward"
	pet.position=PET_START;pet.velocity=Vector2.ZERO;pet.refresh=0;pet.phase=0
	creature.reset_demo();shield.remaining=0;elapsed=0;response_time=0;response.text="";interaction_count=0;route_index=0
	set_route_blocked(false)

func _process(delta:float) -> void:
	if not get_tree().paused:
		elapsed+=delta;response_time=maxf(0,response_time-delta)
		if response_time==0:response.text=""
		if demo:
			if human.position.distance_to(route[route_index])<7:route_index=(route_index+1)%route.size()
			human.direction=human.position.direction_to(route[route_index])
	var available:=available_interaction()
	cue.visible=not available.is_empty() and not get_tree().paused
	cue.text="E  •  Use terminal" if available=="terminal" else "E  •  Use control"
	cue.position=(TERMINAL if available=="terminal" else DEMO_CONTROL)+Vector2(-55,-95)
	label.text="VIS–001    /    Shopping corner\nWASD / arrows: move    E: interact    Space: shield    R: reset    Esc: pause"
	if get_tree().paused:label.text+="\nPAUSED"
	var under:=human.position.x>850 and human.position.x<1020 and human.position.y<350 and human.position.y>245
	var pet_under:=pet.position.x>850 and pet.position.x<1020 and pet.position.y<350 and pet.position.y>245
	lintel.modulate.a=0.38 if under or pet_under else 1.0
	queue_redraw()

func _unhandled_key_input(event:InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():return
	if event.physical_keycode==KEY_ESCAPE:get_tree().paused=not get_tree().paused;return
	if event.physical_keycode==KEY_R:reset_sample();return
	if get_tree().paused:return
	if event.physical_keycode==KEY_E:interact()
	if event.physical_keycode==KEY_SPACE:shield.trigger()
	if event.physical_keycode==KEY_M:demo=not demo;human.automated=demo

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:focused=false;print("FOCUS_OUT: explicit-pause-only; simulation continues")
	if what==NOTIFICATION_APPLICATION_FOCUS_IN:focused=true

func _draw() -> void:
	draw_rect(Rect2(DEMO_CONTROL-Vector2(17,12),Vector2(34,24)),Color("454b43"));draw_circle(DEMO_CONTROL,5,Color("adbd9a"))
	if is_instance_valid(human):
		for actor in [human,pet,creature]:
			draw_set_transform(actor.position,0,Vector2(1,0.3));draw_circle(Vector2.ZERO,13,Color(0,0,0,0.15))
			draw_set_transform(Vector2.ZERO)
		if not available_interaction().is_empty():
			var point:=TERMINAL if available_interaction()=="terminal" else DEMO_CONTROL
			draw_arc(point,27,0,TAU,48,Color("e8d69a"),2,true)
