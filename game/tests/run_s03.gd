extends SceneTree
var scene:Node2D
var checks:Array[Dictionary]=[]
var serial:=0
var base:=""
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func check(name:String,condition:bool) -> void:
	checks.append({"name":name,"passed":condition});print("PASS " if condition else "FAIL ",name)
func settle() -> void:
	for i in range(400):
		if not scene.busy:break
		await process_frame
	check("action resolves within bounded frames",not scene.busy)
func fresh(id:String="blast") -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	serial+=1
	scene=load("res://scenes/tactical_encounter.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	scene.save_store.directory=base.path_join("case-%d" % serial)
	for power in ["blast","shield","dash"]:
		scene.demonstrate(power);await settle()
	check("all demonstrations leave encounter state untouched",scene.power=="" and scene.phase=="selection" and scene.ap==4 and scene.hp==6 and scene.enemy_hp==6 and scene.player_cell==Vector2i(2,5))
	check("choose "+id,scene.choose(id));await frames(2)
func action(mode:String,target:Vector2i) -> bool:
	scene.mode=mode;var accepted:bool=scene.act(target);await settle();return accepted
func fixture(p:Vector2i,e:Vector2i) -> void:
	scene.player_cell=p;scene.enemy_cell=e;scene.human.position=scene.point(p);scene.creature.position=scene.point(e)
func write_bad(name:String,value:String) -> void:
	var file:=FileAccess.open(scene.save_store.directory.path_join(name),FileAccess.WRITE);file.store_string(value);file.close()
func press(key:int,echo:bool=false) -> void:
	var e:=InputEventKey.new();e.physical_keycode=key;e.pressed=true;e.echo=echo;scene._unhandled_key_input(e)
func run() -> void:
	base=OS.get_environment("S03_SAVE_DIR")
	if base.is_empty():push_error("Tests require disposable S03_SAVE_DIR");quit(2);return
	# Real start-to-success play through each selected power, no fixture teleport.
	for id in ["blast","shield","dash"]:
		await fresh(id)
		if id=="dash":check("dash used during complete encounter",await action("power",Vector2i(4,5)))
		while scene.player_cell.x<6:check("walk through encounter",await action("move",scene.player_cell+Vector2i.RIGHT))
		scene.end_turn();await settle()
		if id=="shield":check("shield used during complete encounter",await action("power",scene.player_cell))
		var turns:=0
		while scene.phase!="success" and turns<8:
			if scene.ap>=2:check("legal attack in complete encounter",await action("power" if id=="blast" else "bolt",scene.enemy_cell))
			else:scene.end_turn();await settle();turns+=1
		check(id+" completes encounter from actual fresh selection",scene.phase=="success" and scene.hp>0 and scene.enemy_hp==0)
		var saved:Dictionary=scene.snapshot();check("success save loads",scene.load_latest() and scene.snapshot()==saved)
		check("success rejects repeated attacks and ending turn",not scene.act(scene.enemy_cell) and not scene.end_turn())
	await fresh()
	var initial:Dictionary=scene.snapshot()
	scene.mode="bolt";check("out-of-range bolt atomic",not scene.act(scene.enemy_cell) and scene.snapshot()==initial)
	scene.mode="move";check("nonadjacent move atomic",not scene.act(Vector2i(11,6)) and scene.snapshot()==initial)
	check("cancellation atomic",scene.cancel_action() and not scene.act(Vector2i(3,5)) and scene.snapshot()==initial)
	press(KEY_D,true);check("key echo ignored",scene.snapshot()==initial)
	press(KEY_D);var after:Dictionary=scene.snapshot();press(KEY_D);check("rapid repeat during committed action ignored",scene.snapshot()==after and scene.ap==3)
	check("save and reset rejected in motion",not scene.manual_save() and not scene.reset_demo())
	await settle()
	for i in range(3):await action("move",scene.player_cell+(Vector2i.LEFT if i%2==0 else Vector2i.RIGHT))
	var exhausted:Dictionary=scene.snapshot();check("zero AP does not automatically end turn",scene.ap==0 and scene.phase=="player")
	check("insufficient AP atomic",not scene.act(scene.player_cell+Vector2i.RIGHT) and scene.snapshot()==exhausted)
	scene.end_turn();var enemy_state:Dictionary=scene.snapshot();check("turn ownership and duplicate end",not scene.end_turn() and not scene.act(scene.player_cell+Vector2i.RIGHT) and scene.snapshot()==enemy_state)
	check("enemy save rejected",not scene.manual_save());await settle();check("enemy returns 4 AP",scene.phase=="player" and scene.ap==4)
	await fresh("dash")
	fixture(Vector2i(4,3),Vector2i(9,3));scene.mode="power";initial=scene.snapshot();check("dash cannot cross cabinet",not scene.act(Vector2i(6,3)) and scene.snapshot()==initial)
	scene.mode="move";check("walk cannot enter cabinet",not scene.act(Vector2i(5,3)) and scene.snapshot()==initial)
	fixture(Vector2i(0,0),Vector2i(9,3));scene.mode="move";initial=scene.snapshot();check("arena boundary",not scene.act(Vector2i(-1,0)) and scene.snapshot()==initial)
	fixture(Vector2i(7,3),Vector2i(9,3));scene.mode="power";initial=scene.snapshot();check("dash cannot land on enemy",not scene.act(Vector2i(9,3)) and scene.snapshot()==initial)
	fixture(Vector2i(8,3),Vector2i(9,3));initial=scene.snapshot();check("dash cannot cross enemy",not scene.act(Vector2i(10,3)) and scene.snapshot()==initial)
	fixture(Vector2i(4,3),Vector2i(7,3));scene.mode="bolt";initial=scene.snapshot();check("bolt blocked sight",not scene.act(scene.enemy_cell) and scene.snapshot()==initial)
	await fresh("blast")
	fixture(Vector2i(4,3),Vector2i(7,3));scene.mode="power";initial=scene.snapshot();check("blast blocked sight",not scene.act(scene.enemy_cell) and scene.snapshot()==initial)
	fixture(Vector2i(7,5),Vector2i(9,3));scene.ap=1;initial=scene.snapshot();check("blast insufficient resources",not scene.act(scene.enemy_cell) and scene.snapshot()==initial)
	await fresh("shield")
	fixture(Vector2i(8,3),Vector2i(9,3));scene.prepared=true;scene.aim=scene.player_cell
	check("shield costs 1 AP",await action("power",scene.player_cell) and scene.ap==3 and scene.shield_points==2)
	initial=scene.snapshot();scene.mode="power";check("duplicate shield does not spend",not scene.act(scene.player_cell) and scene.snapshot()==initial)
	check("mid-turn shield manual save",scene.manual_save());var supported:Dictionary=scene.snapshot()
	scene.end_turn();await settle();check("shield absorbs 2 and expires after enemy turn",scene.hp==5 and scene.shield_points==0 and not scene.prepared)
	check("latest manual restores AP shield preparation and health",scene.load_latest() and scene.snapshot()==supported)
	await action("move",Vector2i(8,4));scene.end_turn();await settle();check("fixed prepared strike misses after movement; shield expires",scene.hp==6 and scene.shield_points==0 and not scene.prepared)
	# Timers and all mutations freeze, including an in-flight enemy turn.
	scene.end_turn();await frames(8);scene.toggle_pause();var frozen:Dictionary=scene.snapshot();var timer:float=scene.clock;var actor:Vector2=scene.creature.position;var pet:Vector2=scene.pet.position
	await frames(70)
	check("pause halts enemy timer creature and pet",scene.clock==timer and scene.creature.position==actor and scene.pet.position==pet)
	check("paused actions/save/load/reset rejected",not scene.act(scene.player_cell+Vector2i.RIGHT) and not scene.end_turn() and not scene.manual_save() and not scene.load_latest() and not scene.reset_demo() and scene.snapshot()==frozen)
	scene.toggle_pause();await settle();check("enemy resumes after pause",scene.phase=="player")
	scene.auto_focus_pause=true;scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT);check("focus loss pauses",paused);scene.toggle_pause();scene.auto_focus_pause=false
	# No-path BFS must return player ownership in finite animation time.
	await fresh();fixture(Vector2i(1,5),Vector2i(9,3));scene.extra_blocks.assign([Vector2i(8,3),Vector2i(10,3),Vector2i(9,2),Vector2i(9,4)])
	scene.end_turn();await settle();check("blocked enemy path waits without softlock",scene.enemy_cell==Vector2i(9,3) and scene.phase=="player")
	scene.extra_blocks.clear();scene.end_turn();await settle();check("route recovery after blockage removal",scene.enemy_cell!=Vector2i(9,3) and scene.phase=="player")
	await fresh("dash");fixture(Vector2i(10,2),Vector2i(8,2));scene.mode="use";check("bounded spatial control interaction",await action("use",scene.CONTROL) and scene.used and scene.enemy_hp==4 and scene.ap==3)
	initial=scene.snapshot();check("control cannot apply twice",not scene.act(scene.CONTROL) and scene.snapshot()==initial)
	check("manual persists changed world",scene.manual_save());supported=scene.snapshot()
	# Arrange defeat AFTER saving; actual latest loader must restore changed state, not start.
	scene.hp=1;scene.prepared=true;scene.aim=scene.player_cell;scene.end_turn();await frames(55)
	check("defeat visible before retry",scene.phase=="defeat")
	scene.toggle_pause();timer=scene.clock;await frames(40);check("pause halts retry countdown",scene.clock==timer and scene.phase=="defeat");scene.toggle_pause();await settle()
	check("defeat loads actual latest manual, not encounter reset",scene.snapshot()==supported and scene.used and scene.ap==3 and scene.power=="dash")
	# Cold scene resume of latest manual using same dedicated path.
	var folder:String=scene.save_store.directory
	scene.queue_free();await frames(2);scene=load("res://scenes/tactical_encounter.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3);scene.save_store.directory=folder
	check("fresh runtime loads supported manual",scene.load_latest() and scene.snapshot()==supported)
	write_bad("snapshot-000000800.json","{broken")
	write_bad("snapshot-000000801.tmp","interrupted")
	var unsupported:Dictionary=supported.duplicate(true);unsupported.version=99;unsupported.sequence=802;unsupported.kind="manual";write_bad("snapshot-000000802.json",JSON.stringify(unsupported))
	check("malformed unsupported interrupted fallback visible",scene.load_latest() and scene.snapshot()==supported and "Skipped 3" in scene.message)
	check("bad files retained",FileAccess.file_exists(folder.path_join("snapshot-000000800.json")) and FileAccess.file_exists(folder.path_join("snapshot-000000801.tmp")))
	DirAccess.make_dir_absolute(folder.path_join(".writing"))
	check("concurrent or interrupted writer blocks save visibly",not scene.manual_save() and "writer" in scene.message and scene.load_latest() and scene.snapshot()==supported)
	DirAccess.remove_absolute(folder.path_join(".writing"))
	check("new save does not overwrite bad files",scene.manual_save() and FileAccess.file_exists(folder.path_join("snapshot-000000803.json")))
	var invalid:Dictionary=scene.save_store.latest();invalid.player=[5,3];check("blocked-cell save invalid",not scene.save_store.valid(invalid));invalid=scene.save_store.latest();invalid.hp=1.5;check("fractional health invalid",not scene.save_store.valid(invalid));invalid=scene.save_store.latest();invalid.prepared=true;invalid.aim=[0,0];check("inconsistent preparation invalid",not scene.save_store.valid(invalid))
	check("reset preserves saves and clears choice",scene.reset_demo() and scene.phase=="selection" and scene.power=="" and scene.save_store.files().size()==6)
	check("reset can resume latest state",scene.load_latest() and scene.snapshot()==supported)
	await fresh("blast");folder=scene.save_store.directory
	initial=scene.snapshot();await action("move",Vector2i(3,5));scene.hp=1;fixture(scene.player_cell,Vector2i(3,4));scene.prepared=true;scene.aim=scene.player_cell;scene.end_turn();await settle()
	check("defeat loads start autosave when no manual exists",scene.snapshot()==initial)
	scene.save_store.directory=base.path_join("empty");scene.reset_demo();check("empty save folder visible safe fresh state",not scene.load_latest() and scene.phase=="selection" and "No supported" in scene.message)
	DirAccess.make_dir_recursive_absolute(scene.save_store.directory);write_bad("snapshot-000000001.json","{}");check("all malformed saves do not partially apply",not scene.load_latest() and scene.phase=="selection" and "Skipped 1" in scene.message)
	# Follower uses actual NavigationAgent2D/physics and cannot occupy tactical resources.
	await fresh("dash");var pet_start:Vector2=scene.pet.position
	await action("power",Vector2i(4,5));await frames(140)
	print("PET_TRACE ",scene.pet.position," start ",pet_start," human ",scene.human.position," ap ",scene.ap," nav ",NavigationServer2D.map_get_iteration_id(scene.pet.agent.get_navigation_map()))
	check("pet follows without tactical occupancy",scene.pet.position.distance_to(pet_start)>30 and scene.pet.position.distance_to(scene.human.position)<70 and scene.pet.collision_layer==0 and scene.ap==3)
	var overlap:=false
	for block in scene.BLOCKS:
		if Rect2(scene.point(block)-Vector2(26,26),Vector2(52,52)).has_point(scene.pet.position):overlap=true
	check("pet avoids cabinet footprint",not overlap)
	var output:=OS.get_environment("S03_CHECKS_PATH");var file:=FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify(checks,"  "));file.close()
	var failures:=0
	for item in checks:
		if not item.passed:failures+=1
	print("S03 RESULTS ",checks.size()," checks; ",failures," failed")
	scene.queue_free();await frames(2);quit(0 if failures==0 else 1)
