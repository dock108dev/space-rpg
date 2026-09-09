extends Node2D
const SaveStore=preload("res://scripts/tactical_save.gd")
const ORIGIN:=Vector2(256,254)
const STEP:=64.0
const DIRS:=[Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
const BLOCKS:=SaveStore.BLOCKS
const CONTROL:=Vector2i(10,1)
const POWER_NAMES:={"blast":"Force blast","shield":"Protective shield","dash":"Short dash"}
var player_cell:=Vector2i(2,5)
var enemy_cell:=Vector2i(9,3)
var aim:=Vector2i(8,3)
var hp:=6
var enemy_hp:=6
var ap:=4
var shield_points:=0
var prepared:=false
var used:=false
var turn:=1
var phase:="selection"
var power:=""
var preview:=""
var demonstrated:Array[String]=[]
var mode:="move"
var message:="Try each power, then choose one. Demonstrations do not select it."
var busy:=false
var clock:=0.0
var duration:=0.0
var motion:=""
var from:=Vector2.ZERO
var to:=Vector2.ZERO
var effect_from:=Vector2.ZERO
var effect_to:=Vector2.ZERO
var demo_origin:=Vector2.ZERO
var save_store:RefCounted
var human:CharacterBody2D
var pet:CharacterBody2D
var creature:Node2D
var pose:Node2D
var sorted:=Node2D.new()
var status:=Label.new()
var detail:=Label.new()
var feedback:=Label.new()
var selection_panel:=HBoxContainer.new()
var play_panel:=HBoxContainer.new()
var utility_panel:=HBoxContainer.new()
var buttons:Dictionary={}
var pause_label:=Label.new()
var extra_blocks:Array[Vector2i]=[] # runtime test seam for blocked-route recovery
var enemy_route:Array[Vector2i]=[]
var enemy_origin:=Vector2.ZERO
var auto_focus_pause:=true

func point(cell:Vector2i) -> Vector2:return ORIGIN+Vector2(cell)*STEP
func cell_at(p:Vector2) -> Vector2i:return Vector2i(((p-ORIGIN)/STEP).round())
func inside(cell:Vector2i) -> bool:return cell.x>=0 and cell.x<12 and cell.y>=0 and cell.y<7
func floor_free(cell:Vector2i) -> bool:return inside(cell) and cell not in BLOCKS and cell not in extra_blocks
func distance(a:Vector2i,b:Vector2i) -> int:return absi(a.x-b.x)+absi(a.y-b.y)
func idle_player() -> bool:return phase=="player" and not busy and not get_tree().paused
func reject(text:String) -> bool:message=text;return false
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	DisplayServer.window_set_title("S03 · Tactical encounter")
	var path:=OS.get_environment("S03_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/S03")
	save_store=SaveStore.new(path)
	var floor_sprite:=Sprite2D.new();floor_sprite.texture=load("res://art/floor/full.png");floor_sprite.z_index=-2;floor_sprite.centered=false;floor_sprite.position=Vector2(160,200);floor_sprite.scale=Vector2(960.0/floor_sprite.texture.get_width(),470.0/floor_sprite.texture.get_height());add_child(floor_sprite)
	sorted.y_sort_enabled=true;sorted.process_mode=Node.PROCESS_MODE_PAUSABLE;add_child(sorted)
	for cell in BLOCKS:
		var body:=StaticBody2D.new();body.position=point(cell);var shape:=CollisionShape2D.new();var box:=RectangleShape2D.new();box.size=Vector2(52,52);shape.shape=box;body.add_child(shape);add_child(body)
		if cell!=Vector2i(6,3):
			prop("cabinet_b" if cell==Vector2i(3,1) else "cabinet_a",point(cell)+Vector2(32 if cell==Vector2i(5,3) else 0,22),85,116 if cell==Vector2i(5,3) else 52)
	var terminal:Node2D=load("res://scripts/terminal.gd").new();terminal.position=point(CONTROL);sorted.add_child(terminal)
	human=load("res://scripts/human_controller.gd").new();human.position=point(player_cell);human.automated=true;sorted.add_child(human);human.set_physics_process(false)
	creature=Node2D.new();creature.position=point(enemy_cell);sorted.add_child(creature)
	pose=Node2D.new();creature.add_child(pose)
	var picture:=Sprite2D.new();picture.texture=load("res://art/creature/full.png");picture.centered=false;picture.scale=Vector2.ONE*85/picture.texture.get_height();picture.position=Vector2(-picture.texture.get_width()*picture.scale.x/2,-85);pose.add_child(picture)
	pet=load("res://scripts/pet_follow.gd").new();pet.position=human.position+Vector2(-25,20);pet.target=human;sorted.add_child(pet)
	build_navigation()
	var ui:=CanvasLayer.new();add_child(ui)
	status.position=Vector2(32,18);status.add_theme_font_size_override("font_size",24);ui.add_child(status)
	detail.position=Vector2(32,55);detail.add_theme_font_size_override("font_size",18);ui.add_child(detail)
	feedback.position=Vector2(32,679);feedback.add_theme_font_size_override("font_size",17);ui.add_child(feedback)
	selection_panel.position=Vector2(32,116);selection_panel.add_theme_constant_override("separation",8);ui.add_child(selection_panel)
	for id in ["blast","shield","dash"]:
		add_button(selection_panel,"Try "+POWER_NAMES[id],func():demonstrate(id))
		buttons["choose_"+id]=add_button(selection_panel,"Choose "+id,func():choose(id))
	play_panel.position=Vector2(32,116);play_panel.add_theme_constant_override("separation",8);ui.add_child(play_panel)
	for id in ["move","bolt","power","use"]:
		buttons[id]=add_button(play_panel,{"move":"Move · 1 AP","bolt":"Bolt · 2 AP","power":"Power","use":"Control · 1 AP"}[id],func():select_action(id))
	buttons.end=add_button(play_panel,"End turn ↵",end_turn)
	buttons.cancel=add_button(play_panel,"Cancel",cancel_action)
	utility_panel.position=Vector2(32,161);utility_panel.add_theme_constant_override("separation",8);ui.add_child(utility_panel)
	buttons.save=add_button(utility_panel,"Save · idle player turn",manual_save)
	buttons.load=add_button(utility_panel,"Load latest",load_latest)
	buttons.reset=add_button(utility_panel,"Return to demos",reset_demo)
	add_button(utility_panel,"Pause · Esc",toggle_pause)
	pause_label.position=Vector2(440,340);pause_label.add_theme_font_size_override("font_size",28);pause_label.text="PAUSED — Esc to resume";ui.add_child(pause_label)
	refresh_ui()
func add_button(parent:Node,text:String,callback:Callable) -> Button:
	var b:=Button.new();b.text=text;b.add_theme_font_size_override("font_size",17);b.pressed.connect(callback);b.focus_mode=Control.FOCUS_NONE;parent.add_child(b);return b
func prop(asset:String,at:Vector2,height:float,width:float) -> void:
	var node:=Node2D.new();node.position=at;sorted.add_child(node)
	var sprite:=Sprite2D.new();sprite.texture=load("res://art/"+asset+"/full.png");sprite.centered=false;sprite.scale=Vector2.ONE*minf(height/sprite.texture.get_height(),width/sprite.texture.get_width());sprite.position=Vector2(-sprite.texture.get_width()*sprite.scale.x/2,-sprite.texture.get_height()*sprite.scale.y);node.add_child(sprite)
func build_navigation() -> void:
	var region:=NavigationRegion2D.new();add_child(region)
	var mesh:=NavigationPolygon.new();var vertices:=PackedVector2Array();var ids:Dictionary={}
	for y in range(225,655,8):
		for x in range(225,1005,8):
			var rect:=Rect2(x,y,8,8);var usable:=true
			for cell in BLOCKS:
				if rect.intersects(Rect2(point(cell)-Vector2(38,38),Vector2(76,76))):usable=false;break
			if not usable:continue
			var poly:=PackedInt32Array()
			for v in [rect.position,rect.position+Vector2(8,0),rect.end,rect.position+Vector2(0,8)]:
				if not ids.has(v):ids[v]=vertices.size();vertices.append(v)
				poly.append(ids[v])
			mesh.add_polygon(poly)
	mesh.vertices=vertices;region.navigation_polygon=mesh
func refresh_ui() -> void:
	var paused:=get_tree().paused
	selection_panel.visible=phase=="selection";play_panel.visible=phase!="selection"
	pause_label.visible=paused
	if phase=="selection":
		status.text="S03 / Power demonstrations — no encounter selected"
		detail.text="Try all three, then choose one. Green floor ring: one-use control.\n"+power_description(preview)
	else:
		status.text="S03 / %s    Health %d/6    Creature %d/6    AP %d/4    Turn %d%s" % [POWER_NAMES.get(power,""),hp,enemy_hp,ap,turn,"    Shield %d" % shield_points if shield_points else ""]
		detail.text=("YOUR TURN" if phase=="player" else phase.to_upper())+"  •  "+action_description()+"\nClick floor / creature to act. Right-click cancels. Arrows / WASD: step. End turn: Enter."
	feedback.text=message
	for id in ["blast","shield","dash"]:buttons["choose_"+id].disabled=busy or paused or demonstrated.size()!=3
	for id in ["move","bolt","power","use","end","cancel"]:buttons[id].disabled=not idle_player()
	for id in ["move","bolt","power","use"]:buttons[id].modulate=Color("f4df9b") if mode==id else Color.WHITE
	buttons.power.text=POWER_NAMES.get(power,"Power")+" · %d AP" % (2 if power=="blast" else 1)
	buttons.save.disabled=not idle_player()
	buttons.load.disabled=busy or paused or phase=="enemy"
	buttons.reset.disabled=busy or paused or phase=="enemy"
func power_description(id:String) -> String:
	return {"blast":"Force blast: 2 AP • 3 damage • 3-cell range • clear line of sight.","shield":"Shield: 1 AP • absorbs 2 damage • expires after the next creature turn.","dash":"Dash: 1 AP • exactly 2 straight cells • both cells must be clear."}.get(id,"Demonstration area only. All choices also have Bolt: 2 AP, 2 damage, range 4.")
func action_description() -> String:
	return {"move":"Move: adjacent cardinal cell · 1 AP","bolt":"Bolt: click creature · 2 AP · 2 damage · range 4", "power":power_description(power),"use":"Control: click green ring from an adjacent cell · 1 AP · once, 2 damage","":"No action selected"}.get(mode,"")
func animate(kind:String,seconds:float,start:Vector2,end:Vector2) -> void:
	busy=true;clock=0;duration=seconds;motion=kind;from=start;to=end
func demonstrate(id:String) -> bool:
	if phase!="selection" or busy or get_tree().paused or id not in POWER_NAMES:return false
	preview=id;demo_origin=human.position
	if id not in demonstrated:demonstrated.append(id)
	message="DEMONSTRATION ONLY — "+power_description(id)
	effect_from=human.position-Vector2(0,50);effect_to=creature.position-Vector2(0,45)
	animate("demo_"+id,1.2,human.position,human.position+Vector2(128,0))
	return true
func choose(id:String) -> bool:
	if phase!="selection" or busy or get_tree().paused or id not in POWER_NAMES or demonstrated.size()!=3:return reject("Try all three demonstrations before choosing.")
	power=id;phase="player";mode="move";message="Get through this encounter."
	pet.position=human.position+Vector2(-25,20);pet.velocity=Vector2.ZERO;pet.refresh=0
	save_store.write(snapshot(),"auto");message+=" "+save_store.notice
	return true
func select_action(id:String) -> bool:
	if not idle_player() or id not in ["move","bolt","power","use"]:return false
	mode=id
	if mode=="power" and power=="shield":return act(player_cell)
	return true
func cancel_action() -> bool:
	if not idle_player():return false
	mode="";message="Targeting canceled. No AP spent.";return true
func line_clear(a:Vector2i,b:Vector2i) -> bool:
	# Segment against expanded cell boxes; tangent contact is blocked consistently.
	for block in BLOCKS+extra_blocks:
		var rect:=Rect2(point(block)-Vector2(31,31),Vector2(62,62))
		for i in range(129):
			if rect.has_point(point(a).lerp(point(b),float(i)/128)):return false
	return true
func act(target:Vector2i) -> bool:
	if not idle_player():return reject("Wait for your turn, or resume from pause.")
	if mode=="":return reject("Choose an action first.")
	var cost:=2 if mode=="bolt" or (mode=="power" and power=="blast") else 1
	if ap<cost:return reject("Not enough AP. Choose another action or End turn.")
	var kind:=power if mode=="power" else mode
	match kind:
		"move","dash":
			var delta:=target-player_cell;var length:=2 if kind=="dash" else 1
			if distance(target,player_cell)!=length or (delta.x!=0 and delta.y!=0):return reject("Choose %d clear straight cell(s)." % length)
			var direction:=Vector2i(signi(delta.x),signi(delta.y))
			for step in range(1,length+1):
				var cell:=player_cell+direction*step
				if not floor_free(cell) or cell==enemy_cell:return reject("Movement blocked. No AP spent.")
			var start:=point(player_cell);player_cell=target;ap-=cost;animate(kind,0.32 if kind=="dash" else 0.4,start,point(target))
		"bolt","blast":
			var radius:=3.0 if kind=="blast" else 4.0
			if target!=enemy_cell or Vector2(player_cell).distance_to(Vector2(target))>radius or not line_clear(player_cell,target):return reject("Target must be the creature, in range with clear sight.")
			ap-=cost;enemy_hp=maxi(0,enemy_hp-(3 if kind=="blast" else 2));effect_from=human.position-Vector2(0,50);effect_to=creature.position-Vector2(0,40);animate(kind,0.45,human.position,human.position)
		"shield":
			if target!=player_cell or shield_points>0:return reject("Shield already active or invalid target.")
			ap-=cost;shield_points=2;animate(kind,0.35,human.position,human.position)
		"use":
			if target!=CONTROL or distance(player_cell,CONTROL)!=1 or used:return reject("Stand beside the unused green control.")
			used=true;ap-=cost;enemy_hp=maxi(0,enemy_hp-2);effect_from=point(CONTROL);effect_to=creature.position;animate("use",0.5,human.position,human.position)
		_:return false
	message="%s used. %d AP left.%s" % [kind.capitalize(),ap," End turn when ready." if ap==0 else ""]
	return true
func route_to_player() -> Array[Vector2i]:
	var queue:Array[Vector2i]=[enemy_cell];var parents:Dictionary={enemy_cell:enemy_cell};var found:=enemy_cell
	while not queue.is_empty():
		var current:Vector2i=queue.pop_front()
		if distance(current,player_cell)==1:found=current;break
		for direction in DIRS:
			var next:Vector2i=current+direction
			if floor_free(next) and next!=player_cell and not parents.has(next):parents[next]=current;queue.append(next)
	var route:Array[Vector2i]=[]
	while found!=enemy_cell:route.push_front(found);found=parents[found]
	return route
func end_turn() -> bool:
	if not idle_player():return false
	phase="enemy";mode="move";enemy_origin=creature.position
	if prepared:
		animate("strike",0.85,creature.position,point(aim));return true
	enemy_route=route_to_player().slice(0,2)
	animate("approach",0.8,creature.position,creature.position if enemy_route.is_empty() else point(enemy_route[-1]));return true
func finish_enemy() -> void:
	if motion=="strike":
		if player_cell==aim:
			var damage:=maxi(0,3-shield_points);hp=maxi(0,hp-damage);message="Hit for %d damage." % damage
		else:message="The creature's lunge missed."
		prepared=false
	else:
		if not enemy_route.is_empty():enemy_cell=enemy_route[-1]
		if distance(enemy_cell,player_cell)==1:prepared=true;aim=player_cell
		message="Your turn."
	creature.position=point(enemy_cell);shield_points=0
	if hp==0:
		phase="defeat";message="Defeated. Loading latest supported save…";animate("retry",1.4,human.position,human.position)
	else:
		phase="player";ap=4;turn+=1;busy=false
func snapshot() -> Dictionary:
	return {"power":power,"player":[player_cell.x,player_cell.y],"enemy":[enemy_cell.x,enemy_cell.y],"hp":hp,"enemy_hp":enemy_hp,"ap":ap,"shield":shield_points,"prepared":prepared,"aim":[aim.x,aim.y],"used":used,"turn":turn,"phase":phase}
func manual_save() -> bool:
	if not idle_player():return reject("Save only at an idle player decision boundary.")
	var ok:bool=save_store.write(snapshot(),"manual");message=save_store.notice;return ok
func load_latest() -> bool:
	if get_tree().paused or busy or phase=="enemy":return false
	var data:Dictionary=save_store.latest();message=save_store.notice
	if data.is_empty():return false
	power=data.power;player_cell=Vector2i(data.player[0],data.player[1]);enemy_cell=Vector2i(data.enemy[0],data.enemy[1]);aim=Vector2i(data.aim[0],data.aim[1]);hp=int(data.hp);enemy_hp=int(data.enemy_hp);ap=int(data.ap);shield_points=int(data.shield);prepared=data.prepared;used=data.used;turn=int(data.turn);phase=data.phase
	mode="move";motion="";busy=false;clock=0;human.position=point(player_cell);creature.position=point(enemy_cell);pet.position=human.position+Vector2(-20,18);pet.refresh=0;pet.velocity=Vector2.ZERO
	return true
func reset_demo() -> bool:
	if busy or get_tree().paused or phase=="enemy":return false
	player_cell=Vector2i(2,5);enemy_cell=Vector2i(9,3);aim=Vector2i(8,3);hp=6;enemy_hp=6;ap=4;shield_points=0;prepared=false;used=false;turn=1;power="";phase="selection";mode="move";preview="";demonstrated.clear();motion=""
	human.position=point(player_cell);creature.position=point(enemy_cell);pet.position=human.position+Vector2(-25,20);pet.refresh=0;message="Demonstrations restored. Existing saves preserved."
	return true
func toggle_pause() -> void:get_tree().paused=not get_tree().paused
func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and auto_focus_pause and is_inside_tree():get_tree().paused=true
func _unhandled_key_input(event:InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():return
	if event.physical_keycode==KEY_ESCAPE:toggle_pause();return
	if get_tree().paused:return
	if event.physical_keycode==KEY_ENTER:end_turn();return
	if event.physical_keycode==KEY_BACKSPACE:cancel_action();return
	var keys:={KEY_A:Vector2i.LEFT,KEY_LEFT:Vector2i.LEFT,KEY_D:Vector2i.RIGHT,KEY_RIGHT:Vector2i.RIGHT,KEY_W:Vector2i.UP,KEY_UP:Vector2i.UP,KEY_S:Vector2i.DOWN,KEY_DOWN:Vector2i.DOWN}
	if keys.has(event.physical_keycode) and idle_player():mode="move";act(player_cell+keys[event.physical_keycode])
func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_RIGHT:cancel_action()
		elif event.button_index==MOUSE_BUTTON_LEFT:
			var target:=cell_at(get_global_mouse_position())
			if mode in ["bolt","power"] and get_global_mouse_position().distance_to(creature.position-Vector2(0,40))<48:target=enemy_cell
			act(target)
func _process(delta:float) -> void:
	if not get_tree().paused:
		if busy:
			clock+=delta;var ratio:=minf(clock/duration,1.0)
			if motion in ["move","dash","demo_dash"]:
				human.position=from.lerp(to,ratio);face(to-from)
				for animation in human.animations.values():
					if not animation.is_playing():animation.play("walk")
			if motion=="approach" and not enemy_route.is_empty():
				var segment:=minf(ratio*enemy_route.size(),enemy_route.size()-0.0001);var index:=int(segment)
				creature.position=(enemy_origin if index==0 else point(enemy_route[index-1])).lerp(point(enemy_route[index]),segment-index)
			if motion=="strike":creature.position=from.lerp(to,minf(ratio*2,1))*1.0 if ratio<0.5 else to.lerp(from,(ratio-0.5)*2)
			if clock>=duration:
				if phase=="enemy":finish_enemy()
				elif motion=="retry":busy=false;load_latest()
				else:
					busy=false
					if motion.begins_with("demo_"):human.position=demo_origin
					else:finish_player_action()
					for animation in human.animations.values():animation.play("walk");animation.seek(0.16,true);animation.pause()
		pose.scale=Vector2(1.13,0.73) if prepared else Vector2.ONE
		pose.rotation=float(signi(aim.x-enemy_cell.x))*0.14 if prepared else 0.0
		pose.position=Vector2(Vector2(aim-enemy_cell).normalized()*-16) if prepared else Vector2.ZERO
		pose.modulate=Color(0.55,0.6,0.55,0.5) if phase=="success" else Color.WHITE
	refresh_ui();queue_redraw()
func finish_player_action() -> void:
	if enemy_hp==0:
		phase="success";save_store.write(snapshot(),"auto");message="Encounter complete. "+save_store.notice
func face(direction:Vector2) -> void:
	human.facing=("left" if direction.x<0 else "right") if absf(direction.x)>absf(direction.y) else ("away" if direction.y<0 else "toward");human.show_facing()
func _draw() -> void:
	for y in range(7):
		for x in range(12):
			var cell:=Vector2i(x,y)
			if floor_free(cell):draw_rect(Rect2(point(cell)-Vector2(30,30),Vector2(60,60)),Color(0.85,0.85,0.65,0.12),false,1)
	draw_arc(point(CONTROL),23,0,TAU,40,Color("6a7365") if used else Color("c5e2a3"),3,true)
	if not is_instance_valid(human):return
	draw_arc(human.position,18,0,TAU,32,Color("f4df9b"),2,true)
	if shield_points>0 or (busy and motion in ["shield","demo_shield"]):draw_arc(human.position-Vector2(0,43),54,0,TAU,64,Color(0.4,0.85,1,0.8),4,true)
	if busy and motion in ["bolt","blast","use","demo_blast"]:
		var ratio:=minf(clock/duration,1);var color:=Color("b4e7fa") if motion=="bolt" else Color("ecd598")
		draw_line(effect_from,effect_from.lerp(effect_to,minf(ratio*2,1)),color,4 if motion=="bolt" else 9,true)
		draw_arc(effect_to,12+ratio*20,0,TAU,32,color,2,true)
