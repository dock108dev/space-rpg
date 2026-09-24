extends SceneTree
var scene:Node2D
var checks:Array=[]
var base:=OS.get_environment("B25_SAVE_DIR")
var serial:=0
var restarts:Array=[]
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func check(label:String,value:bool) -> void:
	checks.append({"name":label,"passed":value});print("PASS " if value else "FAIL ",label)
func settle() -> void:
	for i in range(6000):
		if not scene.busy and scene.work.is_empty() and scene.current.is_empty() and scene.fetch_state.is_empty():return
		await process_frame
	check("bounded completion",false);scene.stop_work("Test timeout")
func command(text:String) -> void:
	check("accepted: "+text,scene.submit(text));await frames(2);await settle()
func state() -> Dictionary:
	var d:Dictionary=scene.snapshot();d.erase("history");d.erase("pet_position");d.erase("recruit_position");return d
func fresh(power:String) -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	scene=load("res://scenes/command_adventure.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	serial+=1;scene.save_store.directory=base.path_join("case-%d"%serial)
	await command("please try blast, then preview shield, then show me dash")
	await command("I'd like to choose "+power)
	check("actual power selected",scene.power==power and scene.phase=="player")
func fight() -> void:
	var used_power:=false
	for i in range(80):
		if scene.journey!="encounter":break
		if not used_power and scene.ap>0:
			if scene.power=="shield":await command("raise shield");used_power=scene.shield_points==2;continue
			if scene.power=="dash":
				for direction in ["down","up","left","right"]:
					var vector:Vector2i=scene.Language.DIRECTIONS[direction]
					if scene.floor_free(scene.player_cell+vector) and scene.floor_free(scene.player_cell+vector*2) and scene.player_cell+vector!=scene.enemy_cell and scene.player_cell+vector*2!=scene.enemy_cell:
						var start:Vector2i=scene.player_cell
						await command("dash "+direction);used_power=scene.player_cell==start+vector*2;break
				if used_power:continue
		var d:float=Vector2(scene.player_cell).distance_to(Vector2(scene.enemy_cell))
		if scene.ap>=2 and d<=4 and scene.line_clear(scene.player_cell,scene.enemy_cell):
			if scene.power=="blast" and d<=3:await command("use blast");used_power=true
			else:await command("shoot creature")
		else:await command("end turn")
	check("real assessment survived",scene.journey=="package" and scene.enemy_hp==0 and scene.hp>0)
	check("selected power executed",used_power)
func key(code:Key) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=true;Input.parse_input_event(e);await frames(1)
	e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=false;Input.parse_input_event(e);await frames(1)
func language_and_controls() -> void:
	scene.submit("move 2 right");await frames(2);scene.submit("stop");await settle()
	check("Stop distinguishes committed step from canceled work",scene.steps_done==1 and scene.history.any(func(s):return "1 remaining actions canceled" in s))
	await command("move left")
	var before:=state()
	await command("What would happen if I used the shield?")
	check("hypothetical has no gameplay mutation",state()==before)
	await command("move 5 up and 8 right")
	check("exact sequence completes five up then eight right",scene.steps_done==13 and scene.player_cell==Vector2i(10,0))
	await command("move up and right")
	check("bounds stop exact sequence without reroute",scene.steps_done==0 and scene.player_cell==Vector2i(10,0))
	check("partial count retained",scene.history.any(func(s):return "remain unexecuted" in s))
	await command("go to package")
	check("destination reaches interaction point",scene.distance(scene.player_cell,scene.PACKAGE)<=1)
	await command("inspect that")
	check("reference resolves actual package",scene.recent=="package")
	check("ambiguous target asks instead of moving",not scene.submit("go to package or doorway") and scene.clarification.size()==2)
	var selected:String=scene.clarification[0]
	await command("1")
	check("clarification uses intended movement",scene.distance(scene.player_cell,scene.targets()[selected].cell)<=1)
	await command("inspect package")
	await command("inspect doorway")
	await command("actually, the other one")
	check("other reference selects prior target",scene.recent=="package")
	check("negated compound rejected before execution",not scene.submit("go to doorway, then don't enter shelter"))
	before=state();scene.command_input.grab_focus();await key(KEY_W);await key(KEY_A);await key(KEY_S);await key(KEY_D);await key(KEY_E);await key(KEY_BACKSPACE)
	check("editing text does not leak gameplay keys",state()==before)
	scene.command_input.clear();scene.command_input.release_focus()
	check("queue starts",scene.submit("go to doorway"));await frames(8)
	scene.submit("actually, inspect package");await settle()
	check("correction drops future destination",scene.work.is_empty() and scene.current.is_empty() and scene.recent=="package")
	scene.submit("go to doorway");await frames(8);await key(KEY_S);await settle()
	check("direct keyboard reclaims",scene.work.is_empty() and scene.current.is_empty())
	scene.submit("go to doorway");await frames(8);paused=true
	var pos:Vector2=scene.human.position;var clock_before:float=scene.clock;await frames(30)
	check("pause freezes pending work",scene.human.position==pos and scene.clock==clock_before)
	scene.submit("stop");check("Stop works while paused",scene.work.is_empty() and scene.current.is_empty())
	scene.submit("resume");await settle()
	before=state();check("unique ID accepted",scene.submit("inspect package","test-duplicate",scene.epoch));await settle()
	check("duplicate refused",not scene.submit("move right","test-duplicate",scene.epoch) and state()==before)
	check("stale context refused",not scene.submit("move right","test-stale",scene.epoch-1) and state()==before)
	await command("go to package, then interact with package, then move right")
	check("new danger stops compound",scene.journey=="encounter" and scene.work.is_empty() and scene.distance(scene.player_cell,scene.PACKAGE)<=1)
func run() -> void:
	for power in ["blast","shield","dash"]:
		await fresh(power)
		if power=="blast":await language_and_controls()
		else:await command("go to package, then interact with package")
		if power=="shield":
			await command("move 2 left and 4 right")
			check("exact movement respects AP and stops",scene.ap==0 and scene.steps_done==4)
			await command("end turn")
		await fight()
		await command("go to package, then collect package")
		check("package and learning actual",scene.package_taken and scene.learned)
		await command("go to doorway, then enter shelter")
		check("actual shelter travel",scene.location=="shelter")
		await command("go to desk")
		var reward:String={"blast":"security","shield":"equipment","dash":"opportunity"}[power]
		await command("choose "+reward)
		check("exclusive reward chosen",scene.reward==reward)
		await command("go to traveler, then talk to traveler")
		await command("decline traveler" if power=="shield" else "join traveler")
		if power=="dash":await command("have companion wait here")
		var old_epoch:int=scene.epoch
		await command("go to doorway, then leave shelter")
		check("scene binding advances",scene.epoch>old_epoch)
		if power=="shield":
			await command("go to cache, then collect cache")
			check("personal approach consequence",scene.retrieval=="personal" and scene.cache_taken)
		else:
			var at:Vector2i=scene.player_cell
			if power=="blast":
				scene.submit("ask pet to fetch cache");await frames(20);scene.submit("stop");await frames(2)
				check("interrupted physical fetch pays nothing",not scene.cache_taken and scene.fetch_state.is_empty() and scene.retrieval.is_empty())
			await command("ask the pet to fetch cache")
			check("pet physically delivers without moving player",scene.retrieval=="pet" and scene.cache_taken and scene.player_cell==at)
		var kits:int=scene.kits
		await command("ask pet to fetch cache")
		check("duplicate payout refused",scene.kits==kits)
		await command("go to doorway, then enter shelter")
		await command("go to traveler, then talk to traveler")
		check("story consequence reflected",("paperwork" in scene.traveler_line()) if scene.retrieval=="pet" else ("label" in scene.traveler_line()))
		if power=="dash":await command("go to traveler, then rejoin traveler")
		await frames(180)
		await command("save")
		var saved:Dictionary=scene.save_store.latest()
		check("adventure save validates",scene.save_store.valid(saved))
		restarts.append({"directory":scene.save_store.directory,"expected":saved})
		await command("continue")
		check("restore does not replay history",scene.work.is_empty() and scene.current.is_empty() and scene.retrieval==saved.retrieval)
	await recovery_checks()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B25_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)

func recovery_checks() -> void:
	var original:String=scene.save_store.directory
	var valid:Dictionary=scene.save_store.latest()
	var before:=state()
	var bad:Dictionary=valid.duplicate(true);bad.retrieval=""
	check("negative fixture inconsistent narrative rejected",not scene.save_store.valid(bad))
	bad=valid.duplicate(true);bad.erase("adventure_version")
	check("B2 schema never silently imported",not scene.save_store.valid(bad))
	var obstruction:=base.path_join("file-not-folder")
	var file:=FileAccess.open(obstruction,FileAccess.WRITE);file.store_string("synthetic obstruction");file.close()
	scene.save_store.directory=obstruction.path_join("saves")
	check("failed Save and quit keeps session open",not scene.save_and_quit() and not scene.quit_requested and state()==before)
	scene.save_store.directory=original
	check("save retry succeeds",scene.manual_save())
	file=FileAccess.open(original.path_join("snapshot-000900001.json"),FileAccess.WRITE);file.store_string("{invalid");file.close()
	file=FileAccess.open(original.path_join("snapshot-000900002.tmp"),FileAccess.WRITE);file.store_string("interrupted fixture");file.close()
	check("Continue skips invalid and partial files",scene.load_latest() and "Skipped 2" in scene.save_store.notice)
	check("invalid material retained",FileAccess.file_exists(original.path_join("snapshot-000900001.json")))
	DirAccess.make_dir_absolute(original.path_join(".writing"))
	file=FileAccess.open(original.path_join(".writing/owner.json"),FileAccess.WRITE);file.store_string(JSON.stringify({"pid":OS.get_process_id()}));file.close()
	check("live writer cannot be recovered",not scene.recover_save_access() and not scene.manual_save())
	file=FileAccess.open(original.path_join(".writing/owner.json"),FileAccess.WRITE);file.store_string(JSON.stringify({"pid":2147483646}));file.close()
	check("stale writer preserved and recovered",scene.recover_save_access() and scene.manual_save())
	check("absent package rejected",not scene.submit("collect package"))
	check("old package cannot invoke another interaction",state()==before)
	var start:Vector2i=scene.player_cell
	scene.extra_blocks.append(start+Vector2i.LEFT) # Explicit negative obstacle fixture.
	await command("move left and right")
	check("exact obstacle never reroutes",scene.player_cell==start and scene.steps_done==0)
	scene.extra_blocks.clear()
