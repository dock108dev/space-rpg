extends "res://scripts/tactical_encounter.gd"
# Chapter transitions wrap the assessment, which uses the shared tactical actions,
# actor rig and animation loop; historical scenes and validators remain unchanged.
const ChapterSave=preload("res://scripts/chapter_save.gd")
const Locations=preload("res://scripts/chapter_locations.gd")
const Follower=preload("res://scripts/chapter_follower.gd")
const ChapterArt=preload("res://scripts/chapter_art.gd")
const PACKAGE:=Vector2i(1,3)
const CONCOURSE_DOOR:=Vector2i(11,1)
const SHELTER_DOOR:=Vector2i(0,5)
const SHELTER_REWARD:=Vector2i(5,1)
const RECRUIT:=Vector2i(7,2)
const CACHE:=Vector2i(9,5)
const REWARDS:={"security":"Security · two recovery kits", "equipment":"Equipment · field lamp", "opportunity":"Opportunity · cache route"}
var location:="concourse"
var journey:="arrival"
var package_taken:=false
var learned:=false
var cache_taken:=false
var kits:=0
var reward:=""
var recruit_status:="available"
var routine:=false
var routine_goal:=Vector2i.ZERO
var fetch_state:=""
var fetch_elapsed:=0.0
var fetch_marker:=Node2D.new()
var recruit_home:=Node2D.new()
var recruit:CharacterBody2D
var art:Node2D
var chapter_panel:=HBoxContainer.new()
var reward_panel:=HBoxContainer.new()
var recruit_panel:=HBoxContainer.new()
var pause_panel:=PanelContainer.new()
var chapter_buttons:Dictionary={}
var audience:=Label.new()
var pause_notice:=Label.new()
var quit_requested:=false
var location_collisions:=Node2D.new()
# Presentation state only: never stored in chapter snapshots.
var context_line:=Label.new()
var save_details:=Label.new()
var pause_help:=Label.new()
var pause_resume:Button
var details_button:Button
var pause_retry:Button
var pause_continue:Button
var pause_recover:Button
var pause_reset:Button
var focus_before_pause:Control
var was_paused:=false

func create_save_store() -> RefCounted:
	var path:=OS.get_environment("B2_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B2-practice-v1")
	return ChapterSave.new(path)

func _ready() -> void:
	get_window().content_scale_size=Vector2i(1280,720)
	process_mode=Node.PROCESS_MODE_ALWAYS
	# The chapter supplies its own pause menu instead of the inherited bare label.
	pause_label.free()
	DisplayServer.window_set_title("Space Opera RPG · B2 · Opening & shelter")
	get_window().title="Space Opera RPG · B2 · Opening & shelter"
	get_tree().auto_accept_quit=false
	save_store=create_save_store()
	sorted.y_sort_enabled=true;sorted.process_mode=Node.PROCESS_MODE_PAUSABLE;add_child(sorted)
	art=ChapterArt.new();art.process_mode=Node.PROCESS_MODE_PAUSABLE;add_child(art);art.configure(self)
	human=load("res://scripts/human_controller.gd").new();human.position=point(player_cell);human.automated=true;sorted.add_child(human);human.set_physics_process(false)
	creature=Node2D.new();creature.position=point(enemy_cell);sorted.add_child(creature)
	pose=Node2D.new();creature.add_child(pose)
	var picture:=Sprite2D.new();picture.texture=load("res://art/creature/full.png");picture.centered=false;picture.scale=Vector2.ONE*85/picture.texture.get_height();picture.position=Vector2(-picture.texture.get_width()*picture.scale.x/2,-85);pose.add_child(picture)
	pet=Follower.new();pet.controller=self;pet.role="pet";pet.target=human;pet.position=point(Vector2i(1,5));sorted.add_child(pet)
	recruit_home.position=point(RECRUIT);add_child(recruit_home)
	recruit=Follower.new();recruit.controller=self;recruit.role="recruit";recruit.target=recruit_home;recruit.position=point(RECRUIT);sorted.add_child(recruit)
	add_child(fetch_marker)
	add_child(location_collisions)
	build_chapter_ui()
	set_location_art();refresh_ui()
	message="The shopping concourse is under takeover. A small creature follows you. Power demonstrations are damage-free."

func build_chapter_ui() -> void:
	var ui:=CanvasLayer.new();ui.process_mode=Node.PROCESS_MODE_ALWAYS;add_child(ui)
	for rect in [Rect2(16,8,1248,106),Rect2(16,648,1248,66)]:
		var glass:=Panel.new();glass.position=rect.position;glass.size=rect.size;glass.mouse_filter=Control.MOUSE_FILTER_IGNORE;glass.add_theme_stylebox_override("panel",GlassUI.panel_style(true));ui.add_child(glass)
	status.position=Vector2(30,16);status.size=Vector2(745,32);status.add_theme_font_size_override("font_size",23);ui.add_child(status)
	context_line.position=Vector2(30,49);context_line.size=Vector2(1210,25);context_line.add_theme_font_size_override("font_size",17);ui.add_child(context_line)
	detail.position=Vector2(30,76);detail.size=Vector2(1210,32);detail.add_theme_font_size_override("font_size",17);ui.add_child(detail)
	feedback.position=Vector2(30,649);feedback.size=Vector2(1210,42);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.add_theme_font_size_override("font_size",17);ui.add_child(feedback)
	audience.position=Vector2(30,691);audience.add_theme_font_size_override("font_size",15);audience.modulate=Color("d9d0e6");ui.add_child(audience)
	utility_panel.position=Vector2(846,16);utility_panel.add_theme_constant_override("separation",8);ui.add_child(utility_panel)
	buttons.save=add_button(utility_panel,"Save",manual_save)
	buttons.load=add_button(utility_panel,"Continue",load_latest)
	buttons.pause=add_button(utility_panel,"Pause · Esc",toggle_pause)
	selection_panel.position=Vector2(30,122);selection_panel.add_theme_constant_override("separation",8);ui.add_child(selection_panel)
	for id in ["blast","shield","dash"]:
		chapter_buttons["try_"+id]=add_button(selection_panel,"Try "+POWER_NAMES[id],func():demonstrate(id))
		buttons["choose_"+id]=add_button(selection_panel,"Choose "+id,func():choose(id))
	play_panel.position=Vector2(30,122);play_panel.add_theme_constant_override("separation",8);ui.add_child(play_panel)
	for id in ["move","bolt","power","use"]:
		buttons[id]=add_button(play_panel,{"move":"Move · 1 AP","bolt":"Bolt · 2 AP","power":"Power","use":"Use control · 1 AP"}[id],func():select_action(id))
	buttons.end=add_button(play_panel,"End turn · Enter",end_turn)
	buttons.cancel=add_button(play_panel,"Cancel target",cancel_action)
	chapter_panel.position=Vector2(30,122);chapter_panel.add_theme_constant_override("separation",8);ui.add_child(chapter_panel)
	chapter_panel.add_child(reward_panel);reward_panel.add_theme_constant_override("separation",8)
	for id in REWARDS:
		chapter_buttons["reward_"+id]=add_button(reward_panel,{"security":"2 recovery kits","equipment":"Field lamp","opportunity":"Cache route"}[id],func():choose_reward(id))
	chapter_panel.add_child(recruit_panel);recruit_panel.add_theme_constant_override("separation",8)
	chapter_buttons.join=add_button(recruit_panel,"Join me",join_recruit)
	chapter_buttons.decline=add_button(recruit_panel,"Travel with pet",decline_recruit)
	chapter_buttons.wait=add_button(recruit_panel,"Wait here",wait_recruit)
	chapter_buttons.rejoin=add_button(recruit_panel,"Rejoin me",rejoin_recruit)
	chapter_buttons.interact=add_button(chapter_panel,"Interact · E",interact)
	chapter_buttons.walk=add_button(chapter_panel,"Walk to package",assign_walk)
	chapter_buttons.stop=add_button(chapter_panel,"Stop walking",stop_assignment)
	chapter_buttons.fetch=add_button(chapter_panel,"Pet: fetch cache",fetch_cache)
	chapter_buttons.kit=add_button(chapter_panel,"Use kit · +2 health",use_kit)
	pause_panel.position=Vector2(320,184);pause_panel.custom_minimum_size=Vector2(640,0);pause_panel.add_theme_stylebox_override("panel",GlassUI.panel_style(true));ui.add_child(pause_panel)
	var margin:=MarginContainer.new()
	for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,18)
	pause_panel.add_child(margin)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",10);margin.add_child(box)
	var heading:=Label.new();heading.text="Paused";heading.add_theme_font_size_override("font_size",26);box.add_child(heading)
	pause_notice.custom_minimum_size=Vector2(580,0);pause_notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;pause_notice.add_theme_font_size_override("font_size",18);box.add_child(pause_notice)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",8);box.add_child(row)
	pause_resume=add_button(row,"Resume · Esc",toggle_pause)
	chapter_buttons.save_quit=add_button(row,"Save and quit",save_and_quit)
	row=HBoxContainer.new();row.add_theme_constant_override("separation",8);box.add_child(row)
	pause_retry=add_button(row,"Save",manual_save)
	pause_continue=add_button(row,"Continue saved game",load_latest)
	pause_recover=add_button(box,"Restore save access",recover_save_access)
	var help_button:=add_button(box,"Controls and save details",func():
		pause_help.visible=not pause_help.visible;save_details.visible=pause_help.visible;pause_reset.visible=pause_help.visible)
	details_button=help_button;details_button.toggle_mode=true
	pause_help.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;pause_help.custom_minimum_size.x=580;pause_help.add_theme_font_size_override("font_size",17)
	pause_help.text="WASD / arrows: move. E: interact. Enter: end turn. Right-click / Backspace: cancel. Tab: select a button; Space: activate it.
New practice starts over. Continue uses earlier progress until you save the new game."
	box.add_child(pause_help);pause_help.hide()
	save_details.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;save_details.custom_minimum_size.x=580;save_details.add_theme_font_size_override("font_size",16);box.add_child(save_details);save_details.hide()
	pause_reset=add_button(box,"New practice",reset_demo);pause_reset.hide();buttons.reset=pause_reset

# Chapter keyboard access is separate from the standalone tactical controls.
func add_button(parent:Node,text:String,callback:Callable) -> Button:
	var button:=super.add_button(parent,text,callback)
	button.custom_minimum_size.y=44;button.focus_mode=Control.FOCUS_ALL
	button.gui_input.connect(func(event:InputEvent):
		if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed:
			button.call_deferred("release_focus")
		if event is InputEventKey and event.is_pressed() and event.physical_keycode in [KEY_A,KEY_D,KEY_W,KEY_S,KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,KEY_E,KEY_BACKSPACE]:
			if not get_tree().paused:
				button.release_focus();_unhandled_key_input(event);button.accept_event())
	return button

func emphasize(button:Button,active:bool) -> void:
	if button.has_meta("emphasized") and button.get_meta("emphasized")==active:return
	button.set_meta("emphasized",active)
	for state in ["normal","hover","pressed"]:
		if active:
			var box:StyleBoxFlat=button.theme.get_stylebox(state,"Button").duplicate()
			box.bg_color=Color("0969df") if state=="normal" else Color("0758bd")
			button.add_theme_stylebox_override(state,box)
		else:button.remove_theme_stylebox_override(state)
	if active:
		var focus:StyleBoxFlat=button.theme.get_stylebox("focus","Button").duplicate()
		focus.border_color=Color.WHITE;focus.set_border_width_all(3)
		button.add_theme_stylebox_override("focus",focus)
	else:button.remove_theme_stylebox_override("focus")
	for color in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		if active:button.add_theme_color_override(color,Color.WHITE)
		else:button.remove_theme_color_override(color)

func readable_message(value:String) -> String:
	# Translate storage diagnostics only for display; records and save rules stay intact.
	if value.begins_with("Manual save ") or value.begins_with("Auto save "):return "Progress saved."
	if value.begins_with("Loaded "):
		return "Continued the latest usable save. Some save files could not be used; see save details in Pause." if "Skipped" in value else "Continued your latest saved game."
	if value.begins_with("No supported save found."):
		return "No usable save found. Incomplete or invalid files were kept. Start with the powers, or check save details in Pause." if "Skipped" in value else "No saved game found. Try the three powers to start a new game."
	if value.begins_with("Save failed: part of") or value.begins_with("Save failed: cannot create the B2"):
		return "Progress was not saved. Restore access to the save folder, then choose Retry save in Pause. Your session is still open."
	if value.begins_with("Save blocked"):
		return "Progress was not saved. Another session may be saving. In Pause, choose Restore save access, then Retry save."
	if value.begins_with("Another B2 process"):
		return "Another game session is still saving. Close that session, then retry. No save files were changed."
	if value.begins_with("Interrupted writer preserved") or value.begins_with("Save access ready"):
		return "Save access is ready. Choose Save to keep your current progress. Earlier saves are unchanged."
	if value.begins_with("Defeated."):return "You were defeated. Choose Continue to retry from your latest save."
	if value.begins_with("DEMONSTRATION ONLY"):return "Power preview only. Choose a power when you have tried all three."
	return value.replace("Continue latest","Continue").replace("B2 journey","journey").replace("B2 route complete","Opening complete").replace("autonomous companion","companion who follows on their own").replace("control only the protagonist","control only your character").replace("Travel alone above","Travel with pet").replace("snapshot","save")

func _input(event:InputEvent) -> void:
	# Escape must remain available while a button has keyboard focus.
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.physical_keycode==KEY_ESCAPE:
		toggle_pause();get_viewport().set_input_as_handled()

func inside(cell:Vector2i) -> bool:return Locations.inside(location,cell)
func floor_free(cell:Vector2i) -> bool:return Locations.cell_ok(location,cell) and cell not in extra_blocks
func safe_idle() -> bool:return phase!="selection" and journey!="encounter" and not busy and fetch_state.is_empty() and not get_tree().paused
func stable_boundary() -> bool:return phase in ["player","success"] and not busy and fetch_state.is_empty() and not routine
func idle_player() -> bool:return journey=="encounter" and phase=="player" and not busy and not get_tree().paused

func choose(id:String) -> bool:
	if phase!="selection" or busy or get_tree().paused or id not in POWER_NAMES or demonstrated.size()!=3:return reject("Try each of the three powers before choosing. Demonstrations are damage-free.")
	power=id;phase="player";mode="move";journey="arrival"
	if not persist():power="";phase="selection";return false
	message="Power chosen. Reach the amber package, then E enters its threatened collection area. No countdown."
	return true

func act(target:Vector2i) -> bool:
	if journey=="encounter":return super.act(target)
	if not safe_idle():return reject("Finish the current action or resume before moving.")
	if target==enemy_cell and enemy_hp>0:return reject("The creature occupies that floor. Reach the package marker to enter the assessment.")
	if not floor_free(target) or distance(target,player_cell)!=1:return reject("Step to adjacent clear floor. Blocked movement spends nothing.")
	var start:=point(player_cell);player_cell=target;animate("move",0.4,start,point(target));return true

func finish_player_action() -> void:
	if journey=="encounter" and enemy_hp==0:
		journey="package";phase="success";prepared=false;shield_points=0
		if persist():message="Assessment cleared. Return to the amber package and collect it with E."

func end_turn() -> bool:
	if journey!="encounter":return false
	return super.end_turn()
func select_action(id:String) -> bool:
	if journey!="encounter":return false
	return super.select_action(id)
func cancel_action() -> bool:
	if routine:return stop_assignment()
	if journey=="encounter":return super.cancel_action()
	return reject("No target selected. Use movement keys or E beside a marked object.")

func snapshot() -> Dictionary:
	var data:=super.snapshot()
	data.merge({"chapter_version":1,"location":location,"journey":journey,"package":package_taken,"learned":learned,"cache":cache_taken,"kits":kits,"reward":reward,"recruit_status":recruit_status,"pet_position":[pet.position.x,pet.position.y],"recruit_position":[recruit.position.x,recruit.position.y]})
	return data

func persist(kind:String="auto") -> bool:
	var ok:bool=save_store.write(snapshot(),kind)
	if not ok:message=save_store.notice+" Pause for retry or recovery."
	return ok
func manual_save() -> bool:
	if not stable_boundary():return reject("Save after the action, fetch or walking assignment finishes. Resume to finish an action.")
	var ok:=persist("manual");message=save_store.notice;return ok
func save_and_quit() -> bool:
	quit_requested=false
	if not stable_boundary():return reject("Cannot quit with an unfinished action. Resume, finish or stop the assignment, then save and quit.")
	if not manual_save():return false
	quit_requested=true
	if OS.get_environment("B2_TEST_NO_QUIT")!="1":get_tree().quit()
	return true
func recover_save_access() -> bool:
	if not stable_boundary() and phase!="selection":return reject("Finish the current action before recovering save access.")
	var ok:bool=save_store.recover_interrupted_writer();message=save_store.notice;return ok

func load_latest() -> bool:
	if busy or phase=="enemy" or not fetch_state.is_empty():return reject("Finish the current action before continuing a save.")
	var data:Dictionary=save_store.latest();message=save_store.notice
	if data.is_empty():return false
	apply_snapshot(data);get_tree().paused=false;return true
func apply_snapshot(data:Dictionary) -> void:
	power=data.power;player_cell=Vector2i(data.player[0],data.player[1]);enemy_cell=Vector2i(data.enemy[0],data.enemy[1]);aim=Vector2i(data.aim[0],data.aim[1]);hp=int(data.hp);enemy_hp=int(data.enemy_hp);ap=int(data.ap);shield_points=int(data.shield);prepared=data.prepared;used=data.used;turn=int(data.turn);phase=data.phase
	location=data.location;journey=data.journey;package_taken=data.package;learned=data.learned;cache_taken=data.cache;kits=int(data.kits);reward=data.reward;recruit_status=data.recruit_status
	routine=false;fetch_state="";fetch_elapsed=0.0;mode="move";motion="";busy=false;clock=0
	human.position=point(player_cell);creature.position=point(enemy_cell)
	pet.position=Vector2(data.pet_position[0],data.pet_position[1]);pet.target=human;pet.refresh=0;pet.velocity=Vector2.ZERO
	recruit.position=Vector2(data.recruit_position[0],data.recruit_position[1]);recruit.target=human if recruit_status=="joined" else recruit_home;recruit.refresh=0;recruit.velocity=Vector2.ZERO
	pet.reset_path();recruit.reset_path()
	set_location_art()

func reset_demo() -> bool:
	if busy or phase=="enemy" or not fetch_state.is_empty():return reject("Finish the current action before starting another practice.")
	get_tree().paused=false;location="concourse";journey="arrival";package_taken=false;learned=false;cache_taken=false;kits=0;reward="";recruit_status="available";routine=false
	player_cell=Vector2i(2,5);enemy_cell=Vector2i(9,3);aim=Vector2i(8,3);hp=6;enemy_hp=6;ap=4;shield_points=0;prepared=false;used=false;turn=1;power="";phase="selection";mode="move";preview="";demonstrated.clear();motion=""
	human.position=point(player_cell);creature.position=point(enemy_cell);pet.position=point(Vector2i(1,5));pet.target=human;pet.refresh=0;pet.velocity=Vector2.ZERO;recruit.position=point(RECRUIT);recruit.target=recruit_home;recruit.refresh=0;recruit.velocity=Vector2.ZERO
	pet.reset_path();recruit.reset_path()
	set_location_art();message="New practice. Earlier snapshots remain available through Continue latest until this practice is saved.";return true

func interact() -> bool:
	if not safe_idle():return reject("Interact at a safe idle moment. Finish the action or resume first.")
	routine=false
	if location=="concourse":
		if journey=="arrival":
			if distance(player_cell,PACKAGE)>1:return reject("Reach the amber package. E enters the threatened collection area.")
			journey="encounter";phase="player";ap=4
			if not persist():journey="arrival";return false
			message="Assessment begins. Use your chosen power, Bolt, movement and the green control. Enter ends your turn.";return true
		if journey=="package":
			if distance(player_cell,PACKAGE)>1:return reject("The threat is cleared. Return beside the package and press E.")
			package_taken=true;learned=true;journey="shelter"
			if not persist():package_taken=false;learned=false;journey="package";return false
			message="Package collected. You show the pet the supply mark: fetch learned. Reach the blue shelter doorway.";return true
		if distance(player_cell,CONCOURSE_DOOR)<=1:return travel("shelter")
		return reject("Reach the blue shelter doorway and press E. The marked cache can be fetched after orientation.")
	if distance(player_cell,SHELTER_DOOR)<=1:return travel("concourse")
	if distance(player_cell,SHELTER_REWARD)<=1:
		message="Choose one orientation reward above." if reward.is_empty() else "Your orientation reward is already claimed: "+REWARDS[reward]+"."
		return true
	if distance(player_cell,RECRUIT)<=1:
		message="The traveler offers to walk with you. Choose Join me or Travel with pet; you may change your mind here."
		return true
	return reject("Walk beside the orientation desk, traveler or doorway and press E.")

func travel(destination:String) -> bool:
	if not safe_idle() or destination not in ["concourse","shelter"] or destination==location or not package_taken:return reject("The doorway is unavailable until the package is collected and all actions finish.")
	var doorway:=CONCOURSE_DOOR if location=="concourse" else SHELTER_DOOR
	if distance(player_cell,doorway)>1:return reject("Stand beside the doorway to travel.")
	var before:=snapshot()
	location=destination;player_cell=Vector2i(1,5) if location=="shelter" else Vector2i(10,1);human.position=point(player_cell)
	pet.position=point(Vector2i(1,6) if location=="shelter" else Vector2i(11,2));pet.velocity=Vector2.ZERO;pet.refresh=0;pet.target=human
	recruit.position=point(Vector2i(0,6) if location=="shelter" else Vector2i(11,0)) if recruit_status=="joined" else point(RECRUIT)
	recruit.velocity=Vector2.ZERO;recruit.refresh=0;recruit.target=human if recruit_status=="joined" else recruit_home
	pet.reset_path();recruit.reset_path()
	if not persist():apply_snapshot(before);return false
	set_location_art();message="Temporary shelter. Shared beds, open doorway: this is neither owned nor private. Choose a reward at the desk." if location=="shelter" and reward.is_empty() else ("Back in the cleared shopping concourse. The assessment stays resolved." if location=="concourse" else "Back in temporary shelter. Save and quit from Pause to resume here later.")
	return true

func choose_reward(id:String) -> bool:
	if not safe_idle() or location!="shelter" or distance(player_cell,SHELTER_REWARD)>1:return reject("Stand beside the shelter orientation desk to choose a reward.")
	if not reward.is_empty() or id not in REWARDS:return reject("Exactly one orientation reward may be claimed.")
	var old_kits:=kits;reward=id;journey="complete"
	if id=="security":kits+=2
	if not persist():reward="";journey="shelter";kits=old_kits;return false
	message=REWARDS[id]+" saved. Optional: invite the traveler, then return to the concourse to try fetch.";return true

func recruit_choice(next_status:String) -> bool:
	if not safe_idle() or location!="shelter" or distance(player_cell,RECRUIT)>1:return reject("Talk beside the traveler’s shelter place to change party membership.")
	var before:=snapshot();recruit_status=next_status;routine=false
	recruit.target=human if next_status=="joined" else recruit_home
	recruit.refresh=0;recruit.velocity=Vector2.ZERO
	recruit.reset_path()
	if not persist():apply_snapshot(before);return false
	message={"joined":"The traveler joins as an autonomous companion. You still control only the protagonist.","declined":"You will travel with the pet. The traveler remains available in shelter.","waiting":"The traveler waits here. Return to this place to rejoin."}[next_status]
	return true
func join_recruit() -> bool:
	if recruit_status not in ["available","declined"]:return reject("The traveler has already joined or is waiting. Use Rejoin at their shelter place.")
	return recruit_choice("joined")
func decline_recruit() -> bool:
	if recruit_status not in ["available","declined"]:return reject("Use Wait here to leave a joined companion at shelter.")
	return recruit_choice("declined")
func wait_recruit() -> bool:
	if recruit_status!="joined":return reject("Only a joined traveler can be asked to wait.")
	return recruit_choice("waiting")
func rejoin_recruit() -> bool:
	if recruit_status not in ["waiting","declined"]:return reject("Rejoin is available after waiting or declining.")
	return recruit_choice("joined")

func use_kit() -> bool:
	if not (safe_idle() or idle_player()) or not fetch_state.is_empty() or kits<=0 or hp>=6:return reject("A kit restores up to 2 health at an idle moment; none is spent at full health.")
	var old_hp:=hp;hp=mini(6,hp+2);kits-=1
	if not persist():hp=old_hp;kits+=1;return false
	message="Recovery kit used. Health %d → %d; result saved." % [old_hp,hp];return true

func path_to(goal:Vector2i) -> Array[Vector2i]:
	var queue:Array[Vector2i]=[player_cell];var parents:Dictionary={player_cell:player_cell};var found:=player_cell
	while not queue.is_empty():
		var current:Vector2i=queue.pop_front()
		if current==goal:found=current;break
		for direction in DIRS:
			var next:Vector2i=current+direction
			if floor_free(next) and not (location=="concourse" and enemy_hp>0 and next==enemy_cell) and not parents.has(next):parents[next]=current;queue.append(next)
	var route:Array[Vector2i]=[]
	while found!=player_cell:route.push_front(found);found=parents[found]
	return route
func assignment_goal() -> Vector2i:
	if location=="shelter":return Vector2i(5,2) if reward.is_empty() else Vector2i(1,5)
	return Vector2i(1,4) if journey in ["arrival","package"] else Vector2i(10,1)
func assign_walk(goal:Vector2i=Vector2i(-99,-99)) -> bool:
	if not safe_idle():return reject("Assigned walking is available only outside danger and active actions.")
	routine_goal=assignment_goal() if goal==Vector2i(-99,-99) else goal
	if player_cell==routine_goal:return reject("Already at the destination. Press E when ready.")
	if not floor_free(routine_goal) or path_to(routine_goal).is_empty():return reject("No clear route. Choose another floor cell or move manually.")
	routine=true;message="Walking to the marker. Movement keys, right-click or Stop walking reclaim control.";return true
func stop_assignment() -> bool:
	if get_tree().paused:return reject("Resume to stop the walking assignment.")
	routine=false;message="Walking assignment stopped. The committed step finishes; then move manually.";return true
func fetch_cache() -> bool:
	if not safe_idle():return reject("Wait for a safe idle moment before asking the pet to fetch.")
	if not learned:return reject("The pet follows but has not learned fetch. Collect the package after the assessment.")
	if location!="concourse" or reward.is_empty():return reject("Fetch is available at the concourse cache after choosing an orientation reward.")
	if cache_taken:return reject("This cache is already collected. No duplicate supplies.")
	var route:Array=pet.find_route(cell_at(pet.position),CACHE)
	if route.is_empty() and cell_at(pet.position)!=CACHE:return reject("The pet has no clear route to the cache. Clear the route and try again; no supplies were spent.")
	routine=false;fetch_marker.position=point(CACHE);pet.target=fetch_marker;pet.reset_path();fetch_state="outbound";fetch_elapsed=0.0
	message="The pet goes to the marked cache and brings it back. You stay here.";return true

func set_location_art() -> void:
	for child in location_collisions.get_children():child.free()
	for cell in Locations.blocks(location):
		var body:=StaticBody2D.new();body.position=point(cell);var shape:=CollisionShape2D.new();var box:=RectangleShape2D.new();box.size=Vector2(52,52);shape.shape=box;body.add_child(shape);location_collisions.add_child(body)
	if is_instance_valid(art):art.set_location(location)
	if is_instance_valid(recruit):recruit.visible=location=="shelter" or recruit_status=="joined"
	if is_instance_valid(creature):creature.visible=location=="concourse" and (journey=="encounter" or phase=="selection")

func refresh_ui() -> void:
	if not chapter_buttons.has("interact"):return
	var paused:=get_tree().paused;var selection:=phase=="selection";var combat:=journey=="encounter";var defeated:=phase=="defeat"
	var near_reward:=location=="shelter" and distance(player_cell,SHELTER_REWARD)<=1 and reward.is_empty()
	var near_recruit:=location=="shelter" and distance(player_cell,RECRUIT)<=1
	selection_panel.visible=selection;play_panel.visible=combat and not defeated;chapter_panel.visible=not selection and not combat
	reward_panel.visible=near_reward;recruit_panel.visible=near_recruit and not near_reward
	pause_panel.visible=paused
	var place:="Temporary shelter (shared, not private)" if location=="shelter" else "Shopping concourse"
	context_line.text=place+" · Health %d/6 · Kits %d · %s" % [hp,kits,"Pet and traveler" if recruit_status=="joined" else "Pet follows you"]
	if selection:
		status.text="Choose a power"
		context_line.text="Try all three powers before choosing (%d of 3 tried). No countdown." % demonstrated.size()
		detail.text=power_description(preview).replace("Demonstration area only. ","")
	elif defeated:
		status.text="You were defeated"
		detail.text="Continue loads your latest save so you can try again."
	elif combat:
		status.text="Your turn" if phase=="player" else "Creature’s turn"
		context_line.text="Health %d/6 · Creature %d/6 · Action points (AP) %d/4%s" % [hp,enemy_hp,ap," · Shield %d" % shield_points if shield_points else ""]
		detail.text=action_description().replace("adjacent cardinal cell","one square up, down, left or right").replace("cell","square") if phase=="player" else "Wait for the creature to finish. You can pause at any time."
		if phase=="player" and ap==0:detail.text="No action points left. End your turn to continue."
	else:
		status.text="Reach the package" if journey=="arrival" else "Collect the package" if journey=="package" else "Choose a reward" if location=="shelter" and reward.is_empty() else "Reach temporary shelter" if reward.is_empty() else ("Return to the concourse" if location=="shelter" else "Try the pet’s fetch") if not cache_taken else "Return to shelter" if location=="concourse" else "Opening complete"
		detail.text="WASD / arrows move. Walk to the marker, then press E."
		if journey=="arrival":detail.text="Reach the package, then press E to enter danger. WASD / arrows move."
		elif near_reward:detail.text="Choose one: kits heal up to 2 each; the lamp lights nearby floor; the route marks the cache."
		elif near_recruit:
			status.text="Talk to the traveler"
			detail.text="The traveler can join you or stay here. You can change your mind here later."
		elif not reward.is_empty() and not cache_taken:detail.text="Ask the pet to fetch in the concourse; it brings back one recovery kit."
		elif cache_taken and location=="shelter":detail.text="Save and quit from Pause. Continue brings you back here."
		if routine:detail.text="Walking to the marker. Stop walking or press a movement key to take over."
		elif not fetch_state.is_empty():detail.text="The pet is fetching the cache. Wait for its return; Pause is available."
	feedback.text=readable_message(message)
	audience.text="Outside audience (characters cannot see this): "+("“Temporary” is doing a lot of work here." if location=="shelter" else "One package. A surprisingly aggressive collection policy.")
	var next_preview:=""
	for id in ["blast","shield","dash"]:
		if id not in demonstrated:next_preview=id;break
	for id in ["blast","shield","dash"]:
		buttons["choose_"+id].disabled=busy or paused or demonstrated.size()!=3
		chapter_buttons["try_"+id].disabled=busy or paused
		chapter_buttons["try_"+id].text=("Replay " if id in demonstrated else "Try ")+POWER_NAMES[id]
		emphasize(chapter_buttons["try_"+id],not busy and not paused and id==next_preview)
	for id in ["move","bolt","power","use","end","cancel"]:buttons[id].disabled=not idle_player()
	for id in ["move","bolt","power","use"]:
		emphasize(buttons[id],mode==id)
		buttons[id].toggle_mode=true;buttons[id].set_pressed_no_signal(mode==id)
	buttons.power.text=POWER_NAMES.get(power,"Power")+" · %d AP" % (2 if power=="blast" else 1)
	buttons.cancel.visible=not mode.is_empty()
	emphasize(buttons.end,ap==0)
	buttons.save.disabled=paused or not stable_boundary();buttons.load.disabled=paused or busy or phase=="enemy" or not fetch_state.is_empty();buttons.pause.disabled=paused
	emphasize(buttons.load,defeated)
	for id in ["interact","walk","fetch","kit"]:chapter_buttons[id].disabled=not safe_idle()
	chapter_buttons.stop.visible=routine;chapter_buttons.stop.disabled=not routine or paused
	chapter_buttons.kit.visible=kits>0;chapter_buttons.kit.disabled=not safe_idle() or kits==0 or hp==6
	chapter_buttons.kit.text="Health full · %d kits" % kits if hp==6 else "Use kit · +2 health"
	chapter_buttons.interact.visible=not near_reward and not near_recruit
	chapter_buttons.interact.text=("Enter assessment · E" if journey=="arrival" else "Collect package · E" if journey=="package" else "Enter shelter · E") if location=="concourse" else "Leave shelter · E"
	chapter_buttons.walk.visible=not routine and not near_reward
	chapter_buttons.walk.text="Walk to package" if journey in ["arrival","package"] else "Walk to reward desk" if location=="shelter" and reward.is_empty() else "Walk to doorway"
	chapter_buttons.fetch.visible=location=="concourse" and not reward.is_empty() and not cache_taken
	chapter_buttons.fetch.disabled=not safe_idle() or location!="concourse" or reward.is_empty() or cache_taken
	var marker:Vector2i=PACKAGE if journey in ["arrival","package"] else CONCOURSE_DOOR if location=="concourse" else SHELTER_DOOR
	emphasize(chapter_buttons.interact,distance(player_cell,marker)<=1)
	emphasize(chapter_buttons.walk,distance(player_cell,marker)>1 and not near_reward and not near_recruit)
	emphasize(chapter_buttons.stop,routine)
	emphasize(chapter_buttons.fetch,not chapter_buttons.fetch.disabled)
	for id in REWARDS:chapter_buttons["reward_"+id].disabled=not safe_idle()
	chapter_buttons.join.visible=recruit_status in ["available","declined"];chapter_buttons.decline.visible=recruit_status in ["available","declined"];chapter_buttons.wait.visible=recruit_status=="joined";chapter_buttons.rejoin.visible=recruit_status=="waiting"
	for id in ["join","decline","wait","rejoin"]:chapter_buttons[id].disabled=not safe_idle()
	var save_issue:bool=save_store.notice.begins_with("Save failed") or save_store.notice.begins_with("Save blocked") or save_store.notice.begins_with("Save rejected") or save_store.notice.begins_with("Save interrupted") or save_store.notice.begins_with("Save could not") or save_store.notice.begins_with("Another B2") or save_store.notice.begins_with("Recovery could not") or save_store.notice.begins_with("Writer status")
	pause_notice.text="The game is paused. " + ("Save and quit keeps your current progress." if stable_boundary() else "Resume to finish the current action before saving." if not selection and not defeated else "Choose a power before saving." if selection else "Continue your saved game to try again.")
	if save_issue:pause_notice.text=readable_message(save_store.notice)
	save_details.text="Save details: "+(save_store.notice if not save_store.notice.is_empty() else "No save operation in this session.")
	chapter_buttons.save_quit.disabled=not stable_boundary();pause_retry.disabled=not stable_boundary()
	pause_retry.text="Retry save" if save_issue else "Save"
	pause_continue.disabled=busy or phase=="enemy" or not fetch_state.is_empty();pause_reset.disabled=pause_continue.disabled
	pause_recover.visible=save_issue or pause_help.visible;pause_recover.disabled=not stable_boundary() and phase!="selection"
	emphasize(chapter_buttons.save_quit,stable_boundary() and not save_issue)
	if paused!=was_paused:
		if paused:
			focus_before_pause=get_viewport().gui_get_focus_owner();pause_resume.grab_focus()
		else:
			if is_instance_valid(focus_before_pause) and focus_before_pause.is_visible_in_tree():focus_before_pause.grab_focus()
			else:pause_resume.release_focus()
		was_paused=paused
	# Keep the pause card centered as disclosures and text size change.
	var pause_width:float=760 if pause_notice.get_theme_font_size("font_size")>18 else 640
	pause_panel.custom_minimum_size.x=pause_width
	for label in [pause_notice,pause_help,save_details]:label.custom_minimum_size.x=pause_width-60
	pause_panel.size=Vector2(pause_width,0)
	pause_panel.position=Vector2((1280-pause_panel.size.x)/2,(720-pause_panel.size.y)/2)

func _process(delta:float) -> void:
	super._process(delta)
	if get_tree().paused:return
	if routine and safe_idle():
		if player_cell==routine_goal:routine=false;message="Assigned walk complete. Press E to interact."
		else:
			var route:=path_to(routine_goal)
			if route.is_empty():routine=false;message="Route blocked. Walking assignment stopped without spending resources."
			else:act(route[0])
	if not fetch_state.is_empty():
		fetch_elapsed+=delta
		if fetch_elapsed>0.3 and pet.blocked:
			fetch_state="";fetch_elapsed=0.0;pet.target=human;pet.reset_path()
			message="Fetch stopped because the pet's route is blocked. No cache or kit was collected; clear the route and try again."
	if fetch_state=="outbound" and pet.position.distance_to(fetch_marker.position)<18:
		fetch_state="returning";fetch_elapsed=0.0;pet.target=human;pet.reset_path();message="The pet has the cache and is bringing it back."
	elif fetch_state=="returning" and pet.position.distance_to(human.position)<80:
		cache_taken=true;kits+=1;fetch_state=""
		if persist():message="Pet delivered one recovery kit. Cache collected once and saved. Return to shelter when ready."
		else:cache_taken=false;kits-=1
	creature.visible=location=="concourse" and (journey=="encounter" or phase=="selection")

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and auto_focus_pause and is_inside_tree():get_tree().paused=true
	if what==NOTIFICATION_WM_CLOSE_REQUEST and is_inside_tree():
		if phase=="selection" and not busy:get_tree().quit();return
		get_tree().paused=true;message="Use Save and quit to preserve this B2 journey."

func _unhandled_key_input(event:InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():return
	if event.physical_keycode==KEY_ESCAPE:toggle_pause();return
	if get_tree().paused:return
	if event.physical_keycode==KEY_E:interact();return
	if event.physical_keycode==KEY_ENTER:end_turn();return
	if event.physical_keycode==KEY_BACKSPACE:cancel_action();return
	var keys:={KEY_A:Vector2i.LEFT,KEY_LEFT:Vector2i.LEFT,KEY_D:Vector2i.RIGHT,KEY_RIGHT:Vector2i.RIGHT,KEY_W:Vector2i.UP,KEY_UP:Vector2i.UP,KEY_S:Vector2i.DOWN,KEY_DOWN:Vector2i.DOWN}
	if keys.has(event.physical_keycode):
		routine=false;mode="move";act(player_cell+keys[event.physical_keycode])
func _unhandled_input(event:InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed or get_tree().paused:return
	if event.button_index==MOUSE_BUTTON_RIGHT:cancel_action();return
	if event.button_index==MOUSE_BUTTON_LEFT:
		routine=false
		# Use the delivered event's position: the system cursor may have moved or
		# belong to another macOS surface by the time this event is dispatched.
		var pointer:Vector2=get_global_transform_with_canvas().affine_inverse()*event.position
		var target:=cell_at(pointer)
		if journey=="encounter" and mode in ["bolt","power"] and pointer.distance_to(creature.position-Vector2(0,40))<48:target=enemy_cell
		act(target)

func _draw() -> void:
	if not is_instance_valid(human):return
	for y in range(7):
		for x in range(12):
			var cell:=Vector2i(x,y)
			if floor_free(cell):draw_rect(Rect2(point(cell)-Vector2(30,30),Vector2(60,60)),Color(0.85,0.85,0.65,0.065),false,1)
	if journey=="encounter":draw_arc(point(CONTROL),23,0,TAU,40,Color("6a7365") if used else Color("c5e2a3"),3,true)
	draw_arc(human.position,18,0,TAU,32,Color("f4df9b"),2,true)
	if shield_points>0 or (busy and motion in ["shield","demo_shield"]):draw_arc(human.position-Vector2(0,43),54,0,TAU,64,Color(0.4,0.85,1,0.8),4,true)
	if busy and motion in ["bolt","blast","use","demo_blast"]:
		var ratio:=minf(clock/duration,1);var color:=Color("b4e7fa") if motion=="bolt" else Color("ecd598")
		draw_line(effect_from,effect_from.lerp(effect_to,minf(ratio*2,1)),color,4 if motion=="bolt" else 9,true);draw_arc(effect_to,12+ratio*20,0,TAU,32,color,2,true)
	if reward=="equipment":draw_circle(human.position,95,Color(1.0,0.88,0.55,0.12));draw_circle(human.position+Vector2(14,-45),5,Color("fff0b0"))
	if reward=="opportunity" and not cache_taken and location=="concourse":
		for cell in path_to(CACHE):draw_circle(point(cell),4,Color("b2d397"))
	if not fetch_state.is_empty():draw_arc(pet.position,20,0,TAU,32,Color("b2d397"),2,true)
