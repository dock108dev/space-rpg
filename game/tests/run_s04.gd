extends SceneTree
var scene:Node2D
var checks:Array[Dictionary]=[]
var base:=""
var serial:=0
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func check(name:String,condition:bool) -> void:
	checks.append({"name":name,"passed":condition});print("PASS " if condition else "FAIL ",name)
func settle() -> void:
	for i in range(2400):
		if not scene.busy and not scene.routine and scene.fetch_state.is_empty():return
		await process_frame
	check("bounded action completes",false)
func fresh(id:String="blast") -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	serial+=1;scene=load("res://scenes/integrated_loop.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	scene.save_store.directory=base.path_join("case-%d" % serial)
	for p in ["blast","shield","dash"]:scene.demonstrate(p);await settle()
	check("select "+id,scene.choose(id))
func step(target:Vector2i) -> void:
	scene.mode="move";check("legal direct movement",scene.act(target));await settle()
func package_start() -> void:
	check("before learning cannot fetch",not scene.fetch_cache() and not scene.learned)
	check("before reaching package cannot collect",not scene.interact() and not scene.package_taken)
	await step(Vector2i(1,5));await step(Vector2i(1,4))
	check("safe movement costs no AP",scene.ap==4)
	check("collect package teaches fetch",scene.interact() and scene.package_taken and scene.learned)
	check("learning autosave valid",scene.save_store.valid(scene.save_store.latest()))
	check("explicitly begin assessment",scene.interact() and scene.journey=="encounter")
func fight() -> void:
	var used_power:=false
	for i in range(80):
		if scene.journey=="shelter":break
		if scene.power=="shield" and not used_power and scene.ap>=1:
			used_power=scene.select_action("power");await settle();continue
		if scene.power=="dash" and not used_power and scene.player_cell==Vector2i(1,4) and scene.ap>=1:
			scene.mode="power";used_power=scene.act(Vector2i(1,6));await settle();continue
		var d:float=Vector2(scene.player_cell).distance_to(Vector2(scene.enemy_cell))
		if scene.ap>=2 and d<=4 and scene.line_clear(scene.player_cell,scene.enemy_cell):
			scene.mode="power" if scene.power=="blast" and d<=3 else "bolt"
			if scene.mode=="power":used_power=true
			check("integrated legal attack",scene.act(scene.enemy_cell));await settle()
		elif scene.ap>0 and d>3:
			var route:Array=scene.path_to(scene.enemy_cell)
			if route.size()>1:await step(route[0])
			else:scene.end_turn();await settle()
		else:scene.end_turn();await settle()
	check("selected power used in journey",used_power)
	check("actual fresh fight reaches shelter phase",scene.journey=="shelter" and scene.enemy_hp==0 and scene.hp>0 and scene.package_taken and scene.learned)
func shelter() -> void:
	check("assigned shelter walk starts",scene.assign_walk());await settle()
	check("assigned route finishes beside shelter",scene.distance(scene.player_cell,scene.SHELTER)==1 and not scene.routine)
	check("shelter reached before rewards",scene.interact() and scene.journey=="reward")
func run() -> void:
	base=OS.get_environment("S04_SAVE_DIR")
	if base.is_empty():quit(2);return
	for id in ["blast","shield","dash"]:
		await fresh(id);await package_start();await fight();await shelter()
		var pick:String={"blast":"security","shield":"equipment","dash":"opportunity"}[id]
		check("choose distinct reward "+pick,scene.choose_reward(pick) and scene.journey=="complete" and scene.reward==pick)
		var chosen:Dictionary=scene.snapshot()
		for other in ["security","equipment","opportunity"]:check("prevent repeated/cross reward "+other,not scene.choose_reward(other) and scene.snapshot()==chosen)
		var player:Vector2=scene.human.position
		check("learned pet fetch starts",scene.fetch_cache());await frames(45)
		check("fetch save/reset/load rejected in flight",not scene.manual_save() and not scene.load_latest() and not scene.reset_demo())
		scene.toggle_pause();var pet:Vector2=scene.pet.position;var fetch:String=scene.fetch_state;await frames(60)
		check("pause freezes fetching pet",scene.pet.position==pet and scene.fetch_state==fetch)
		scene.toggle_pause();await settle()
		check("pet delivers useful kit without moving player",scene.cache_taken and scene.kits==(3 if pick=="security" else 1) and scene.human.position==player)
		chosen=scene.snapshot();check("cache duplicate prevented",not scene.fetch_cache() and scene.snapshot()==chosen)
		check("completed journey manual save",scene.manual_save())
		check("resume restores reward learning inventory",scene.load_latest() and scene.snapshot()==chosen)
		check("full health kit does not spend",scene.hp<6 or (not scene.use_kit() and scene.snapshot()==chosen))
		# Explicit focused fixture for healing effect; complete journeys above use no teleports or damage fixtures.
		scene.hp=3;var old_kits:int=scene.kits
		check("recovery kit useful and persisted",scene.use_kit() and scene.hp==5 and scene.kits==old_kits-1 and scene.load_latest() and scene.hp==5)
		var saved:Dictionary=scene.snapshot();var folder:String=scene.save_store.directory
		check("fresh practice preserves saves",scene.reset_demo() and scene.load_latest() and scene.snapshot()==saved)
		var invalid:Dictionary=scene.save_store.latest();invalid.learned=false;check("inconsistent learning rejected",not scene.save_store.valid(invalid))
		invalid=scene.save_store.latest();invalid.reward="unknown";check("unknown reward rejected",not scene.save_store.valid(invalid))
		invalid=scene.save_store.latest();invalid.kits=99;check("excess inventory rejected",not scene.save_store.valid(invalid))
		# Leave the final complete journey for a separate process to resume.
		if id=="dash":
			var f:=FileAccess.open(base.path_join("restart.json"),FileAccess.WRITE);f.store_string(JSON.stringify({"folder":folder,"state":saved}));f.close()
	await fresh();check("assigned package walk starts",scene.assign_walk());await frames(8)
	scene.toggle_pause();var at:Vector2=scene.human.position;var clock:float=scene.clock;await frames(70)
	check("pause freezes assigned motion",at==scene.human.position and clock==scene.clock)
	check("paused mutations rejected",not scene.interact() and not scene.assign_walk() and not scene.fetch_cache() and not scene.choose_reward("security") and not scene.stop_assignment())
	scene.toggle_pause();scene.stop_assignment();await settle();check("manual control after cancel",not scene.routine and scene.safe_idle())
	scene.auto_focus_pause=true;scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT);check("focus loss pauses integrated scene",paused);scene.toggle_pause();scene.auto_focus_pause=false
	check("assignment can resume",scene.assign_walk());await settle();scene.interact();scene.interact()
	# Supported partly spent tactical boundary including integrated state, actual defeat retry.
	scene.mode="move";scene.act(Vector2i(2,4));await settle();check("integrated mid-turn manual",scene.manual_save())
	var supported:Dictionary=scene.snapshot()
	scene.hp=1;scene.enemy_cell=Vector2i(2,3);scene.creature.position=scene.point(scene.enemy_cell);scene.prepared=true;scene.aim=scene.player_cell
	scene.end_turn();await settle();check("defeat retries latest integrated state",scene.snapshot()==supported and scene.package_taken and scene.learned)
	# Semantic malformed fallback and atomic reward failure recovery.
	var f:=FileAccess.open(scene.save_store.directory.path_join("snapshot-000000800.json"),FileAccess.WRITE);f.store_string('{"loop_version":1}');f.close()
	check("truncated schema fallback",scene.load_latest() and scene.snapshot()==supported and "Skipped" in scene.message)
	await fight();await shelter();DirAccess.make_dir_absolute(scene.save_store.directory.path_join(".writing"))
	var before:Dictionary=scene.snapshot();check("failed reward write rolls back",not scene.choose_reward("security") and scene.snapshot()==before)
	DirAccess.remove_absolute(scene.save_store.directory.path_join(".writing"));check("reward can retry after writer cleared",scene.choose_reward("equipment"))
	check("pet has no blocking collision",scene.pet.collision_layer==0)
	before=scene.snapshot();scene.extra_blocks.assign([Vector2i(0,4),Vector2i(1,3),Vector2i(2,4),Vector2i(1,5)])
	check("audience is display only",not before.has("audience") and "characters cannot see" in scene.audience.text)
	var failures:=0
	for item in checks:
		if not item.passed:failures+=1
	f=FileAccess.open(OS.get_environment("S04_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	print("S04 RESULTS ",checks.size()," checks; ",failures," failed")
	scene.queue_free();await frames(2);quit(0 if failures==0 else 1)
