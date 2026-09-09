extends "res://scripts/tactical_encounter.gd"
const LoopSave=preload("res://scripts/integrated_save.gd")
const PACKAGE:=Vector2i(1,3)
const SHELTER:=Vector2i(11,1)
const CACHE:=Vector2i(9,5)
const REWARDS:={"security":"Security: two recovery kits", "equipment":"Equipment: field lamp equipped", "opportunity":"Opportunity: cache route revealed"}
var journey:="package"
var package_taken:=false
var learned:=false
var cache_taken:=false
var kits:=0
var reward:=""
var routine:=false
var routine_goal:=Vector2i.ZERO
var fetch_state:=""
var fetch_marker:=Node2D.new()
var loop_panel:=HBoxContainer.new()
var reward_panel:=HBoxContainer.new()
var audience:=Label.new()
var loop_buttons:Dictionary={}

func _ready() -> void:
	super._ready()
	DisplayServer.window_set_title("Space Opera RPG · EXP-001 · S04 owner-play candidate")
	var path:=OS.get_environment("S04_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/S04-practice")
	save_store=LoopSave.new(path)
	add_child(fetch_marker)
	var ui:=CanvasLayer.new();add_child(ui)
	loop_panel.position=Vector2(32,116);loop_panel.add_theme_constant_override("separation",8);ui.add_child(loop_panel)
	loop_buttons.interact=add_button(loop_panel,"Interact · E",interact)
	loop_buttons.routine=add_button(loop_panel,"Assign walk",assign_walk)
	loop_buttons.fetch=add_button(loop_panel,"Pet: fetch cache",fetch_cache)
	loop_buttons.kit=add_button(loop_panel,"Use recovery kit",use_kit)
	loop_buttons.stop=add_button(loop_panel,"Stop assignment",stop_assignment)
	reward_panel.position=Vector2(32,213);reward_panel.add_theme_constant_override("separation",10);ui.add_child(reward_panel)
	for id in REWARDS:
		loop_buttons["reward_"+id]=add_button(reward_panel,REWARDS[id],func():choose_reward(id))
	audience.position=Vector2(32,632);audience.size=Vector2(1216,42);audience.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;audience.add_theme_font_size_override("font_size",16);audience.modulate=Color("c8bbdd");ui.add_child(audience)
	feedback.size=Vector2(1216,40);feedback.position.y=677;feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.add_theme_font_size_override("font_size",16)
	buttons.reset.text="Fresh practice";buttons.save.text="Save · idle boundary"
	refresh_ui()

func safe_idle() -> bool:
	return phase!="selection" and journey!="encounter" and not busy and fetch_state.is_empty() and not get_tree().paused
func choose(id:String) -> bool:
	var ok:=super.choose(id)
	if ok:message="Find the orientation package at the amber marker. Walk yourself or assign the walk."
	return ok
func act(target:Vector2i) -> bool:
	if journey=="encounter":return super.act(target)
	if not safe_idle():return reject("Wait for the current action, or resume from pause.")
	if not floor_free(target) or distance(target,player_cell)!=1:return reject("Step to an adjacent clear floor cell. Safe movement uses no AP.")
	var start:=point(player_cell);player_cell=target;animate("move",0.4,start,point(target))
	return true
func finish_player_action() -> void:
	if journey=="encounter":
		if enemy_hp==0:journey="shelter";prepared=false
		super.finish_player_action()
		if journey=="shelter":message="Assessment complete. Reach the blue shelter doorway; no countdown."
func end_turn() -> bool:
	if journey!="encounter":return false
	return super.end_turn()
func select_action(id:String) -> bool:
	if journey!="encounter":return false
	return super.select_action(id)
func snapshot() -> Dictionary:
	var data:=super.snapshot()
	data.merge({"loop_version":1,"journey":journey,"package":package_taken,"learned":learned,"cache":cache_taken,"kits":kits,"reward":reward})
	return data
func persist(kind:String="auto") -> bool:
	var ok:bool=save_store.write(snapshot(),kind)
	if not ok:message=save_store.notice
	return ok
func manual_save() -> bool:
	if not (idle_player() or safe_idle()) or not fetch_state.is_empty() or routine:return reject("Save after the current action or assignment finishes, while unpaused.")
	var ok:=persist("manual");message=save_store.notice;return ok
func load_latest() -> bool:
	if busy or get_tree().paused or phase=="enemy" or not fetch_state.is_empty():return false
	var data:Dictionary=save_store.latest()
	if data.is_empty():message=save_store.notice;return false
	if not super.load_latest():return false
	journey=data.journey;package_taken=data.package;learned=data.learned;cache_taken=data.cache;kits=int(data.kits);reward=data.reward
	routine=false;fetch_state="";pet.target=human
	return true
func reset_demo() -> bool:
	if not fetch_state.is_empty():return false
	if not super.reset_demo():return false
	journey="package";package_taken=false;learned=false;cache_taken=false;kits=0;reward="";routine=false;pet.target=human
	return true
func interact() -> bool:
	if not safe_idle():return false
	routine=false
	if journey=="package":
		if distance(player_cell,PACKAGE)>1:return reject("Stand beside the amber package marker to interact.")
		if not package_taken:
			package_taken=true;learned=true
			if not persist():package_taken=false;learned=false;return false
			message="Package collected. You show the pet how to retrieve marked supplies. Fetch learned; test it after the assessment."
			return true
		journey="encounter";phase="player";ap=4
		if not persist():journey="package";return false
		message="Assessment begins. Reach the creature with your chosen power and the shared Bolt action."
		return true
	if journey=="shelter":
		if distance(player_cell,SHELTER)>1:return reject("Reach the blue shelter doorway first.")
		journey="reward"
		if not persist():journey="shelter";return false
		message="Temporary shelter reached. Choose one result below. This is not owned or private space."
		return true
	return reject("Shelter reached. You can fetch the cache, save, or inspect your chosen result.")
func choose_reward(id:String) -> bool:
	if not safe_idle() or journey!="reward" or not reward.is_empty() or id not in REWARDS:return false
	var old_kits:=kits
	reward=id;journey="complete"
	if id=="security":kits+=2
	if not persist():reward="";journey="reward";kits=old_kits;return false
	message=REWARDS[id]+". Exactly one result saved. The prototype journey is complete."
	return true
func use_kit() -> bool:
	if not (safe_idle() or (journey=="encounter" and idle_player())) or not fetch_state.is_empty() or kits<=0 or hp>=6:return reject("A recovery kit restores up to 2 health at an idle boundary; none is spent at full health.")
	var old_hp:=hp;hp=mini(6,hp+2);kits-=1
	if not persist():hp=old_hp;kits+=1;return false
	message="Recovery kit used: health %d → %d. Result saved." % [old_hp,hp];return true
func path_to(goal:Vector2i) -> Array[Vector2i]:
	var queue:Array[Vector2i]=[player_cell];var parents:Dictionary={player_cell:player_cell};var found:=player_cell
	while not queue.is_empty():
		var current:Vector2i=queue.pop_front()
		if current==goal:found=current;break
		for direction in DIRS:
			var next:Vector2i=current+direction
			if floor_free(next) and not parents.has(next):parents[next]=current;queue.append(next)
	var route:Array[Vector2i]=[]
	while found!=player_cell:route.push_front(found);found=parents[found]
	return route
func assign_walk() -> bool:
	if not safe_idle() or journey not in ["package","shelter"]:return false
	routine_goal=PACKAGE+Vector2i.DOWN if journey=="package" else SHELTER+Vector2i.DOWN
	if player_cell==routine_goal:return reject("Already at the destination. Interact when ready.")
	if path_to(routine_goal).is_empty():return reject("No clear route. Move manually or stop the assignment.")
	routine=true;message="Walking to the marker. Movement keys or Stop assignment return manual control."
	return true
func stop_assignment() -> bool:
	if get_tree().paused:return false
	routine=false;message="Walk assignment stopped. Any committed step finishes; then move manually.";return true
func fetch_cache() -> bool:
	if not safe_idle():return false
	if not learned:return reject("Before learning: the pet follows but cannot fetch. Show it at the package marker.")
	if journey not in ["shelter","reward","complete"]:return reject("Fetch the marked cache after the assessment.")
	if cache_taken:return reject("That cache is already collected. No duplicate supplies.")
	routine=false;fetch_marker.position=point(CACHE);pet.target=fetch_marker;pet.refresh=0;fetch_state="outbound"
	message="After learning: the pet retrieves the cache while you stay here. Wait for it to return."
	return true
func refresh_ui() -> void:
	super.refresh_ui()
	if not is_instance_valid(audience) or not audience.is_inside_tree():return
	var safe:=journey!="encounter" and phase!="selection"
	loop_panel.visible=safe;play_panel.visible=journey=="encounter" and phase!="selection"
	reward_panel.visible=journey=="reward"
	if phase=="selection":
		status.text="EXP-001 / Prepare a power"
		detail.text="Try all three, then choose one. Package → assessment → temporary shelter. No countdown.\n"+power_description(preview)
	elif safe:
		status.text="EXP-001 / %s    Health %d/6    Recovery kits %d" % [{"package":"Orientation package","shelter":"Reach temporary shelter","reward":"Choose one reward","complete":"Journey complete"}[journey],hp,kits]
		detail.text=("Package collected · Fetch learned" if learned else "Pet before learning: follows only · Package not collected")+"    |    "+("Cache retrieved" if cache_taken else "Marked recovery cache available after assessment")+"\n"+(REWARDS[reward] if not reward.is_empty() else "Arrows / WASD: step · E: interact · Assign walk: watch movement · Temporary shelter is not owned/private")
	else:
		status.text=status.text.replace("S03 /","EXP-001 / Assessment /")
		detail.text+="  Package carried · Fetch learned"
	var reaction:="New arrival. Three powers, one decision."
	if package_taken:reaction="A welcome package. Customer retention has become literal."
	if journey in ["shelter","reward"]:reaction="Assessment survived. The shelter is temporary; the commentary isn't."
	if journey=="complete":reaction="One reward claimed. The audience debates the choice."
	audience.text="OUTSIDE AUDIENCE · Real-player view only; characters cannot see this:  "+reaction
	loop_buttons.interact.text="Begin assessment · E" if journey=="package" and package_taken else ("Collect package / teach fetch · E" if journey=="package" else "Enter shelter · E")
	loop_buttons.routine.text="Assign walk to package" if journey=="package" else "Assign walk to shelter"
	for id in ["interact","routine","fetch","kit"]:loop_buttons[id].disabled=not safe_idle()
	loop_buttons.routine.disabled=not safe_idle() or journey not in ["package","shelter"]
	loop_buttons.interact.disabled=not safe_idle() or journey not in ["package","shelter"]
	loop_buttons.stop.disabled=not routine or get_tree().paused
	loop_buttons.kit.disabled=not safe_idle() or kits==0 or hp==6
	for id in REWARDS:loop_buttons["reward_"+id].disabled=not safe_idle()
	buttons.save.disabled=not (safe_idle() or idle_player()) or routine or not fetch_state.is_empty()
	buttons.load.disabled=busy or get_tree().paused or phase=="enemy" or not fetch_state.is_empty()
	buttons.reset.disabled=buttons.load.disabled
func _process(delta:float) -> void:
	super._process(delta)
	if get_tree().paused:return
	if routine and safe_idle():
		if player_cell==routine_goal:routine=false;message="Assigned walk complete. Interact when ready."
		else:
			var route:=path_to(routine_goal)
			if route.is_empty():routine=false;message="Route blocked. Assignment stopped."
			else:act(route[0])
	if fetch_state=="outbound" and pet.position.distance_to(fetch_marker.position)<46:
		fetch_state="returning";pet.target=human;pet.refresh=0;message="Pet collected the cache and is bringing it back."
	elif fetch_state=="returning" and pet.position.distance_to(human.position)<46:
		cache_taken=true;kits+=1;fetch_state=""
		if persist():message="Pet delivered one recovery kit without moving you. Fetch result saved."
		else:cache_taken=false;kits-=1
	pose.visible=journey=="encounter" or phase=="selection"
func _unhandled_key_input(event:InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and not get_tree().paused:
		if event.physical_keycode==KEY_E:interact();return
		var keys:={KEY_A:Vector2i.LEFT,KEY_LEFT:Vector2i.LEFT,KEY_D:Vector2i.RIGHT,KEY_RIGHT:Vector2i.RIGHT,KEY_W:Vector2i.UP,KEY_UP:Vector2i.UP,KEY_S:Vector2i.DOWN,KEY_DOWN:Vector2i.DOWN}
		if keys.has(event.physical_keycode):
			routine=false
			if journey!="encounter":act(player_cell+keys[event.physical_keycode]);return
	super._unhandled_key_input(event)
func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not get_tree().paused:routine=false
	super._unhandled_input(event)
func _draw() -> void:
	super._draw()
	if phase=="selection":return
	var font:=ThemeDB.fallback_font
	if not package_taken:
		draw_rect(Rect2(point(PACKAGE)-Vector2(16,24),Vector2(32,24)),Color("e3b86d"));draw_string(font,point(PACKAGE)+Vector2(-35,24),"Package",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ffe0a0"))
	draw_rect(Rect2(point(SHELTER)-Vector2(25,55),Vector2(50,66)),Color("8fb6c6"),false,4)
	draw_string(font,point(SHELTER)+Vector2(-30,32),"Shelter",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("b9e4f1"))
	if not cache_taken:
		draw_circle(point(CACHE),13,Color("b2d397"));draw_string(font,point(CACHE)+Vector2(-24,27),"Cache",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d1ecc0"))
	if reward=="equipment":
		draw_circle(human.position,100,Color(1.0,0.88,0.55,0.14))
		draw_circle(human.position+Vector2(14,-45),5,Color("fff0b0"))
	if reward=="opportunity" and not cache_taken:
		for cell in path_to(CACHE):draw_circle(point(cell),4,Color("b2d397"))
	if not fetch_state.is_empty():draw_arc(pet.position,20,0,TAU,32,Color("b2d397"),2,true)
