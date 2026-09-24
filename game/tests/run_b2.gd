extends SceneTree
# Independent acceptance runner. Passing journeys contain no position/state injection.
# Explicit negative fixtures below mutate only disposable synthetic state.
var scene:Node2D
var checks:Array[Dictionary]=[]
var base:=""
var serial:=0
var restarts:Array[Dictionary]=[]
var combat_pause_checked:=false
var mouse_target_checks_done:=false
var party_violations:Array[String]=[]
const PACKAGE:=Vector2i(1,3)
const CONCOURSE_DOOR:=Vector2i(11,1)
const SHELTER_DOOR:=Vector2i(0,5)
const REWARD:=Vector2i(5,1)
const RECRUIT:=Vector2i(7,2)

func _initialize() -> void:call_deferred("run")
func frames(count:int) -> void:
	for i in range(count):await process_frame
func check(label:String,condition:bool) -> void:
	checks.append({"name":label,"passed":condition})
	print("PASS " if condition else "FAIL ",label)
func settle() -> void:
	for i in range(3600):
		if not scene.busy and not scene.routine and scene.fetch_state.is_empty():return
		sample_party_geometry()
		await process_frame
	check("bounded movement/action completion",false)
func settled_party() -> void:
	await settle()
	await frames(150)
func fresh(id:String="blast") -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	serial+=1;combat_pause_checked=false;mouse_target_checks_done=false
	scene=load("res://scenes/chapter_opening.tscn").instantiate()
	scene.auto_focus_pause=false
	root.add_child(scene);await frames(3)
	scene.save_store.directory=base.path_join("case-%d" % serial)
	check("new B2 starts concourse before danger",scene.location=="concourse" and scene.journey=="arrival" and not scene.learned)
	check("choice requires all previews",not scene.choose(id))
	for power_id in ["blast","shield","dash"]:
		check("real power preview "+power_id,scene.demonstrate(power_id));await settle()
	check("select "+id,scene.choose(id))
	check("chapter snapshot valid after choice",scene.save_store.valid(scene.save_store.latest()))
func key(code:Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true
	Input.parse_input_event(event);await frames(1)
	event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=false
	Input.parse_input_event(event);await frames(1)
func click(at:Vector2) -> void:
	var viewport_at:Vector2=scene.get_viewport_transform()*scene.get_global_transform_with_canvas()*at
	if OS.get_environment("B2_POINTER_TRACE")=="1":print("POINTER_TEST ",at," projected ",viewport_at," viewport_transform ",scene.get_viewport_transform()," canvas_transform ",scene.get_global_transform_with_canvas()," window ",root.size)
	var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=viewport_at;event.global_position=viewport_at;event.pressed=true
	Input.parse_input_event(event);await frames(1)
	event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=viewport_at;event.global_position=viewport_at;event.pressed=false
	Input.parse_input_event(event);await frames(1)
func right_click() -> void:
	var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_RIGHT;event.position=Vector2(180,210);event.pressed=true
	Input.parse_input_event(event);await frames(1)
	event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_RIGHT;event.position=Vector2(180,210);event.pressed=false
	Input.parse_input_event(event);await frames(1)
func step(target:Vector2i) -> void:
	scene.mode="move"
	check("ordinary direct step "+str(target),scene.act(target))
	await settle()
func walk(goal:Vector2i) -> void:
	var route:Array=scene.path_to(goal)
	check("reachable ordinary route "+str(goal),scene.player_cell==goal or not route.is_empty())
	for next in route:await step(next)
func approach(marker:Vector2i) -> void:
	if scene.distance(scene.player_cell,marker)<=1:return
	var best:Array=[]
	for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
		var target:Vector2i=marker+offset
		if not scene.floor_free(target):continue
		var route:Array=scene.path_to(target)
		if not route.is_empty() and (best.is_empty() or route.size()<best.size()):best=route
	check("marker has reachable approach "+str(marker),not best.is_empty())
	for next in best:await step(next)
func enter_assessment() -> void:
	check("prelesson fetch rejected",not scene.fetch_cache() and not scene.learned)
	check("remote interaction rejected",not scene.interact() and not scene.package_taken)
	var before_ap:int=scene.ap
	await click(scene.point(Vector2i(2,4)));await settle()
	check("ordinary pointer-position adjacent floor movement",scene.player_cell==Vector2i(2,4) and scene.ap==before_ap)
	await click(scene.point(Vector2i(2,5)));await settle()
	check("ordinary pointer-position return step",scene.player_cell==Vector2i(2,5) and scene.ap==before_ap)
	await key(KEY_A);await settle()
	check("ordinary A key moves protagonist",scene.player_cell==Vector2i(1,5))
	await key(KEY_W);await settle()
	check("safe direct movement is free",scene.player_cell==Vector2i(1,4) and scene.ap==before_ap)
	await key(KEY_E)
	check("threatened collection starts assessment before package",scene.journey=="encounter" and not scene.package_taken and not scene.learned and scene.enemy_hp>0)
	check("danger rejects assigned walking",not scene.assign_walk())
	var original_ap:int=scene.ap
	check("ordinary combat target action selected",scene.select_action("bolt"))
	await right_click()
	check("right-click cancels target without spending AP",scene.mode=="" and scene.ap==original_ap)
	scene.select_action("move")
func fight() -> void:
	var used_power:=false
	for i in range(100):
		if scene.journey!="encounter":break
		if scene.power=="blast" and scene.hp==6:
			check("ordinary turn permits creature approach and strike",scene.end_turn());await settle();continue
		if scene.power=="shield" and not used_power and scene.ap>=1:
			used_power=scene.select_action("power");await pause_combat();await settle();continue
		if scene.power=="dash" and not used_power and scene.player_cell==Vector2i(1,4) and scene.ap>=1:
			scene.mode="power";used_power=scene.act(Vector2i(1,6));await pause_combat();await settle();continue
		var distance_to_enemy:float=Vector2(scene.player_cell).distance_to(Vector2(scene.enemy_cell))
		if scene.ap>=2 and distance_to_enemy<=4 and scene.line_clear(scene.player_cell,scene.enemy_cell):
			var action:String="power" if scene.power=="blast" and distance_to_enemy<=3 else "bolt"
			check("ordinary attack action selected",scene.select_action(action))
			if action=="power":used_power=true
			if not mouse_target_checks_done:
				mouse_target_checks_done=true
				var unchanged_ap:int=scene.ap;var unchanged_enemy:int=scene.enemy_hp
				await click(Vector2(1180,600))
				check("invalid pointer target spends no AP or damage",scene.ap==unchanged_ap and scene.enemy_hp==unchanged_enemy and not scene.busy)
			var prior_ap:int=scene.ap;var prior_enemy:int=scene.enemy_hp
			await click(scene.creature.position-Vector2(0,40))
			check("ordinary pointer-position attack hits visible creature",scene.ap==prior_ap-2 and scene.enemy_hp==maxi(0,prior_enemy-(3 if action=="power" else 2)))
			await pause_combat();await settle()
		elif scene.ap>0 and distance_to_enemy>3:
			var route:Array=scene.path_to(scene.enemy_cell)
			if route.size()>1:await step(route[0])
			else:check("ordinary end turn",scene.end_turn());await settle()
		else:check("ordinary end turn",scene.end_turn());await settle()
	check("chosen power used during real encounter",used_power)
	check("survived actual assessment before collection",scene.journey=="package" and scene.phase=="success" and scene.enemy_hp==0 and scene.hp>0 and not scene.package_taken)
func sample_party_geometry() -> void:
	if not scene.extra_blocks.is_empty():return # Dynamic obstruction is a labeled negative fixture.
	var locations=load("res://scripts/chapter_locations.gd")
	for actor in [scene.pet,scene.recruit]:
		if actor.visible and not locations.pixel_ok(scene.location,[actor.position.x,actor.position.y]):
			var description:String=scene.location+"/"+str(actor.role)+"/"+str(actor.position)
			if description not in party_violations:party_violations.append(description)
func pause_combat() -> void:
	if combat_pause_checked:return
	combat_pause_checked=true
	await key(KEY_ESCAPE)
	var actor_at:Vector2=scene.human.position;var pet_at:Vector2=scene.pet.position;var creature_at:Vector2=scene.creature.position;var action_time:float=scene.clock
	await frames(60)
	check("combat pause freezes actor/action state",paused and scene.human.position==actor_at and scene.pet.position==pet_at and scene.creature.position==creature_at and scene.clock==action_time)
	check("active combat pause cannot save or quit",not scene.save_and_quit() and not scene.quit_requested)
	await key(KEY_ESCAPE)
func collect_and_shelter() -> void:
	await approach(PACKAGE)
	check("collect after danger teaches fetch",scene.interact() and scene.package_taken and scene.learned and scene.journey=="shelter")
	check("collection coherent autosave",scene.save_store.valid(scene.save_store.latest()))
	check("safe assigned doorway walk",scene.assign_walk())
	await settle()
	check("assignment reaches physical door",scene.distance(scene.player_cell,CONCOURSE_DOOR)<=1)
	check("physical doorway enters separate shelter",scene.interact() and scene.location=="shelter")
	await settled_party()
	check("shelter has distinct blocked geometry",not scene.floor_free(Vector2i(2,2)) and scene.floor_free(Vector2i(5,3)))
func travel(expected:String) -> void:
	await approach(CONCOURSE_DOOR if scene.location=="concourse" else SHELTER_DOOR)
	check("door travel to "+expected,scene.interact() and scene.location==expected)
	await settled_party()
	check("door leaves protagonist on valid floor",scene.floor_free(scene.player_cell))
	check("pet remains in same location on valid floor",scene.floor_free(scene.cell_at(scene.pet.position)))
	if scene.recruit_status=="joined":
		check("joined recruit survives travel on valid floor",is_instance_valid(scene.recruit) and scene.recruit.visible and scene.floor_free(scene.cell_at(scene.recruit.position)))
		check("three actors remain distinct with readable spacing",scene.human!=scene.pet and scene.pet!=scene.recruit and scene.human!=scene.recruit and scene.pet.position.distance_to(scene.recruit.position)>20)
		var followers:=0
		for child in scene.sorted.get_children():
			if child==scene.pet or child==scene.recruit:followers+=1
		check("travel never duplicates party actors",followers==2)
func choice_layout() -> void:
	await frames(2)
	for panel in [scene.reward_panel,scene.recruit_panel]:
		if panel.visible:
			check("visible choice controls do not overlap save/pause controls",not panel.get_global_rect().intersects(scene.utility_panel.get_global_rect()))
			check("visible choice controls fit supported width",panel.get_global_rect().end.x<=1280)
func choose_reward(id:String) -> void:
	await approach(REWARD);await choice_layout()
	check("exclusive orientation reward "+id,scene.choose_reward(id) and scene.reward==id and scene.journey=="complete")
	check("reward payload is honest",scene.kits==(2 if id=="security" else 0))
	var before:Dictionary=scene.snapshot()
	for other in ["security","equipment","opportunity"]:
		check("repeat reward rejected "+other,not scene.choose_reward(other) and scene.snapshot()==before)
func blocked_fetch_fixtures() -> void:
	var inventory:int=scene.kits
	scene.extra_blocks.assign([Vector2i(9,5)])
	check("NEGATIVE ineligible blocked fetch rejected",not scene.fetch_cache() and not scene.cache_taken and scene.kits==inventory)
	scene.extra_blocks.clear()
	check("fetch starts after route restored",scene.fetch_cache());await frames(10)
	scene.extra_blocks.assign([Vector2i(9,5)])
	await frames(90)
	check("NEGATIVE interrupted pet route cancels without reward",scene.fetch_state.is_empty() and not scene.cache_taken and scene.kits==inventory)
	scene.extra_blocks.clear();await settled_party()
func fetch_and_pause() -> void:
	var actor_at:Vector2=scene.human.position
	var pet_at:Vector2=scene.pet.position
	var count:int=scene.kits
	check("physical fetch begins",scene.fetch_cache())
	await frames(25)
	check("fetch produces outbound movement",scene.pet.position.distance_to(pet_at)>1 and not scene.fetch_state.is_empty())
	check("inflight persistence and duplicate actions refused",not scene.manual_save() and not scene.load_latest() and not scene.reset_demo() and not scene.fetch_cache())
	await key(KEY_ESCAPE)
	var paused_pet:Vector2=scene.pet.position
	var paused_recruit:Vector2=scene.recruit.position
	var state:String=scene.fetch_state
	await frames(50)
	check("pause freezes fetch and both followers",paused and scene.pet.position==paused_pet and scene.recruit.position==paused_recruit and scene.fetch_state==state)
	check("paused fetch mutation rejected",not scene.interact() and not scene.assign_walk() and not scene.choose_reward("security"))
	await key(KEY_ESCAPE);await settle();await settled_party()
	check("physical pet return gives exactly one kit",scene.cache_taken and scene.kits==count+1 and scene.human.position==actor_at)
	var after:Dictionary=scene.snapshot()
	check("duplicate cache cannot pay again",not scene.fetch_cache() and scene.snapshot()==after)
func store_restart(label:String) -> void:
	await settled_party()
	check("manual stable save "+label,scene.manual_save())
	var expected:Dictionary=scene.snapshot()
	check("same-process exact continue "+label,scene.load_latest() and equivalent(scene.snapshot(),expected))
	var original:=preserved_files(scene.save_store.directory)
	check("new practice preserves latest completed journey",scene.reset_demo() and scene.load_latest() and equivalent(scene.snapshot(),expected) and originals_unchanged(scene.save_store.directory,original))
	restarts.append({"label":label,"folder":scene.save_store.directory.get_file(),"state":expected})
func equivalent(a:Variant,b:Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size()!=b.size():return false
		for field in a:
			if not b.has(field) or not equivalent(a[field],b[field]):return false
		return true
	if a is Array and b is Array:
		if a.size()!=b.size():return false
		for i in range(a.size()):
			if not equivalent(a[i],b[i]):return false
		return true
	return a==b
func preserved_files(directory:String) -> Dictionary:
	var hashes:Dictionary={}
	for name in DirAccess.get_files_at(directory):hashes[name]=FileAccess.get_sha256(directory.path_join(name))
	return hashes
func originals_unchanged(directory:String,before:Dictionary) -> bool:
	for name in before:
		if FileAccess.get_sha256(directory.path_join(name))!=before[name]:return false
	return true
func invalid_fixtures() -> void:
	var saved:Dictionary=scene.save_store.latest()
	for field in ["chapter_version","location","journey","recruit_status","pet_position","recruit_position"]:
		var data:Dictionary=saved.duplicate(true);data.erase(field)
		check("NEGATIVE missing chapter field "+field,not scene.save_store.valid(data))
	for pair in [["chapter_version",99],["location","owned-home"],["journey","expedition"],["recruit_status","dead"],["reward","audience-gift"],["learned",false],["kits",99],["player",[2,2]],["pet_position",[-500,200]],["recruit_position",[99999,0]]]:
		var data:Dictionary=saved.duplicate(true);data[pair[0]]=pair[1]
		check("NEGATIVE invalid chapter semantic "+str(pair[0]),not scene.save_store.valid(data))
	var directory:String=scene.save_store.directory
	var original:=preserved_files(directory)
	var file:=FileAccess.open(directory.path_join("snapshot-000000800.json"),FileAccess.WRITE);file.store_string('{"chapter_version":1}');file.close()
	file=FileAccess.open(directory.path_join("snapshot-000000801.tmp"),FileAccess.WRITE);file.store_string('{"interrupted":');file.close()
	var expected:Dictionary=scene.snapshot()
	check("NEGATIVE invalid/interrupted snapshot fallback",scene.load_latest() and equivalent(scene.snapshot(),expected) and "Skipped" in scene.message)
	check("NEGATIVE invalid entries preserved",FileAccess.file_exists(directory.path_join("snapshot-000000800.json")) and FileAccess.file_exists(directory.path_join("snapshot-000000801.tmp")))
	DirAccess.make_dir_absolute(directory.path_join(".writing"))
	check("NEGATIVE interrupted writer reports failure",not scene.manual_save() and ("blocked" in scene.message.to_lower() or "failed" in scene.message.to_lower()))
	await key(KEY_ESCAPE)
	check("NEGATIVE failed paused save and quit stays open",not scene.save_and_quit() and not scene.quit_requested and paused)
	await key(KEY_ESCAPE)
	check("NEGATIVE load recovery remains available during writer lock",scene.load_latest())
	file=FileAccess.open(directory.path_join(".writing/owner.json"),FileAccess.WRITE);file.store_string(JSON.stringify({"pid":OS.get_process_id()}));file.close()
	check("NEGATIVE live writer cannot be stolen",not scene.save_store.recover_writer() and DirAccess.dir_exists_absolute(directory.path_join(".writing")))
	DirAccess.make_dir_absolute(directory.path_join(".writing"))
	file=FileAccess.open(directory.path_join(".writing/owner.json"),FileAccess.WRITE);file.store_string(JSON.stringify({"pid":int(OS.get_environment("B2_EXTERNAL_LIVE_PID"))}));file.close()
	check("NEGATIVE external live process retains writer access",not scene.recover_save_access() and DirAccess.dir_exists_absolute(directory.path_join(".writing")))
	DirAccess.make_dir_absolute(directory.path_join(".writing"))
	file=FileAccess.open(directory.path_join(".writing/owner.json"),FileAccess.WRITE);file.store_string(JSON.stringify({"pid":2147483647}));file.close()
	check("stale writer recovery preserves interrupted material",scene.recover_save_access() and not DirAccess.dir_exists_absolute(directory.path_join(".writing")))
	var recovered_archive:=false
	for name in DirAccess.get_directories_at(directory):
		if name.begins_with("interrupted-writer-"):recovered_archive=true
	check("stale writer archive retained",recovered_archive)
	check("retry after interrupted writer succeeds",scene.manual_save())
	check("save numbering skips invalid and partial attempts",scene.save_store.latest().sequence>801)
	var blocker:String=base.path_join("not-a-directory")
	file=FileAccess.open(blocker,FileAccess.WRITE);file.store_string("synthetic write-failure fixture");file.close()
	scene.save_store.directory=blocker.path_join("saves")
	await key(KEY_ESCAPE)
	check("NEGATIVE unwritable destination does not quit",not scene.save_and_quit() and not scene.quit_requested and ("failed" in scene.message.to_lower() or "cannot" in scene.message.to_lower()))
	await key(KEY_ESCAPE)
	scene.save_store.directory=directory
	check("valid destination retry after write failure",scene.manual_save() and scene.load_latest())
	check("all prior snapshots survive failures/retry",originals_unchanged(directory,original))
func stale_fixture() -> void:
	DirAccess.make_dir_absolute(scene.save_store.directory.path_join(".writing"))
	var file:=FileAccess.open(scene.save_store.directory.path_join(".writing/owner.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"pid":2147483647}));file.close()
func transaction_failures() -> void:
	await approach(REWARD);await settled_party()
	var before:Dictionary=scene.snapshot();stale_fixture()
	check("NEGATIVE failed reward write rolls back coherent state",not scene.choose_reward("security") and equivalent(scene.snapshot(),before))
	check("reward recovery uses ordinary action",scene.recover_save_access() and scene.choose_reward("security"))
	await approach(RECRUIT);await settled_party();before=scene.snapshot();stale_fixture()
	check("NEGATIVE failed recruit choice rolls back membership",not scene.join_recruit() and equivalent(scene.snapshot(),before))
	check("recruit save access recovers",scene.recover_save_access())
	await approach(SHELTER_DOOR);await settled_party();before=scene.snapshot();stale_fixture()
	check("NEGATIVE failed travel write rolls back location and party",not scene.interact() and equivalent(scene.snapshot(),before))
	check("travel can recover and retry",scene.recover_save_access() and scene.interact() and scene.location=="concourse")
	await settled_party();await travel("shelter")
func movement_checks() -> void:
	await fresh()
	var player_start:Vector2i=scene.player_cell
	check("safe assignment starts",scene.assign_walk());await frames(8)
	await key(KEY_ESCAPE)
	var human_at:Vector2=scene.human.position;var pet_at:Vector2=scene.pet.position;var time_at:float=scene.clock
	await frames(70)
	check("pause freezes assigned movement and clocks",paused and human_at==scene.human.position and pet_at==scene.pet.position and scene.clock==time_at)
	check("paused active assignment cannot save and quit",not scene.save_and_quit() and not scene.quit_requested)
	await key(KEY_ESCAPE)
	await key(KEY_D);await settle()
	check("movement key reclaims assigned walk",not scene.routine and scene.safe_idle())
	check("assignment restarts after reclaim",scene.assign_walk(Vector2i(10,6)));await frames(3)
	await right_click();await settle()
	check("right-click cancels safe walking",not scene.routine and scene.safe_idle())
	check("assignment restarts after right-click",scene.assign_walk(Vector2i(10,6)));await frames(3)
	check("stop assignment cancels safely",scene.stop_assignment());await settle()
	check("manual control available after stop",not scene.routine and scene.safe_idle())
	scene.auto_focus_pause=true;scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check("synthetic focus loss pauses",paused)
	await key(KEY_ESCAPE);scene.auto_focus_pause=false
	check("explicit Escape resumes focus pause",not paused)
	# Dynamic obstruction fixture exists only in this synthetic case.
	check("assignment starts before dynamic obstruction",scene.assign_walk(Vector2i(10,6)));await frames(3)
	var at:Vector2i=scene.player_cell
	scene.extra_blocks.assign([at+Vector2i.LEFT,at+Vector2i.RIGHT,at+Vector2i.UP,at+Vector2i.DOWN])
	await frames(40)
	check("NEGATIVE blocked assigned path stops without resources",not scene.routine and scene.ap==4 and ("block" in scene.message.to_lower() or "route" in scene.message.to_lower()))
	var before:Dictionary=scene.snapshot()
	check("NEGATIVE blocked manual step rejected without resources",not scene.act(at+Vector2i.RIGHT) and scene.snapshot()==before)
	scene.extra_blocks.clear()
	check("clear obstruction allows new assignment",scene.assign_walk(Vector2i(10,6)));await settle()
	check("safe assignment never triggers danger",scene.journey=="arrival" and not scene.package_taken)
	check("pet never physically blocks protagonist",scene.pet.collision_layer==0)
func settle_step() -> void:
	for i in range(120):
		if not scene.busy:return
		await process_frame
func run() -> void:
	base=OS.get_environment("B2_SAVE_DIR")
	if base.is_empty() or OS.get_environment("B2_CHECKS_PATH").is_empty():quit(2);return
	for id in ["blast","shield","dash"]:
		await fresh(id);await enter_assessment();await fight();await collect_and_shelter()
		var reward_id:String={"blast":"security","shield":"equipment","dash":"opportunity"}[id]
		await choose_reward(reward_id)
		await approach(RECRUIT);await choice_layout()
		if id=="shield":check("decline companion remains completable",scene.decline_recruit() and scene.recruit_status=="declined")
		else:check("recruit joins autonomous party",scene.join_recruit() and scene.recruit_status=="joined")
		await travel("concourse")
		check("return preserves resolved events and party",scene.enemy_hp==0 and scene.package_taken and scene.learned and scene.reward==reward_id and scene.recruit_status==("declined" if id=="shield" else "joined"))
		if id=="blast":await blocked_fetch_fixtures()
		await fetch_and_pause()
		if id=="blast":
			var old_hp:int=scene.hp;var old_kits:int=scene.kits
			check("kit treats real encounter damage and persists",old_hp<6 and scene.use_kit() and scene.hp==mini(6,old_hp+2) and scene.kits==old_kits-1 and scene.load_latest())
		else:
			var healthy:Dictionary=scene.snapshot()
			check("full-health kit never spends resources",scene.hp==6 and not scene.use_kit() and scene.snapshot()==healthy)
		await travel("shelter")
		if id=="dash":
			await approach(RECRUIT)
			check("joined recruit can wait",scene.wait_recruit() and scene.recruit_status=="waiting")
			await travel("concourse");check("waiting recruit does not follow",scene.recruit_status=="waiting" and not scene.recruit.visible)
			await travel("shelter");await approach(RECRUIT)
			check("waiting recruit rejoins",scene.rejoin_recruit() and scene.recruit_status=="joined")
			check("waiting final branch persisted",scene.wait_recruit() and scene.recruit_status=="waiting")

		await store_restart(id+"/"+reward_id)
		check("audience presentation has no saved influence",not scene.snapshot().has("audience") and "characters cannot" in scene.audience.text)
		if id=="blast":
			await invalid_fixtures()
			# Refresh expected final snapshot after failure recovery.
			restarts.pop_back();await store_restart("blast/security/recovered")
	var file:=FileAccess.open(base.path_join("restart.json"),FileAccess.WRITE);file.store_string(JSON.stringify(restarts));file.close()
	await fresh("blast");await enter_assessment();await fight();await collect_and_shelter();await transaction_failures();await approach(RECRUIT)
	check("ordinary optional decline before reward",scene.decline_recruit() and scene.recruit_status=="declined")
	check("declined recruit can rejoin later",scene.rejoin_recruit() and scene.recruit_status=="joined")
	await movement_checks()
	check("both followers avoid blocking geometry throughout ordinary journeys",party_violations.is_empty())
	if not party_violations.is_empty():print("PARTY_GEOMETRY_FAILURES ",JSON.stringify(party_violations))
	var failed:=0
	for item in checks:
		if not item.passed:failed+=1
	file=FileAccess.open(OS.get_environment("B2_CHECKS_PATH"),FileAccess.WRITE);file.store_string(JSON.stringify(checks,"  "));file.close()
	print("B2 RESULTS ",checks.size()," checks; ",failed," failed")
	scene.queue_free();await frames(2);quit(0 if failed==0 else 1)
