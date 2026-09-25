extends "res://tests/run_b4.gd"
func fresh(power:String) -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	scene=load("res://scenes/owned_home.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	serial+=1;scene.save_store.directory=base.path_join("case-%d"%serial)
	await command("try blast then try shield then try dash then choose "+power)
func home_route(branch:String,max_spend:bool) -> void:
	await opening(branch)
	var before:=state();await command("How do I get a home?");check("access question no award",state()==before)
	check("home access locked",not scene.submit("enter my home") and not scene.home.owned)
	await command("go to board then file settlement claim");check("kit prerequisite",not scene.home.owned)
	await command("go to bench then claim preparation kit")
	await command("go to approach then go to range then test power then go to hub then go to bench then improve my blast then improve lens")
	if max_spend:await command("improve weave then improve rig")
	var carried:int=4 if max_spend else 12
	check("B4 accounting before award",scene.progression.material==carried)
	await command("go to board then file settlement claim")
	check("earned ownership and exactly ten",scene.home.owned and scene.progression.material==carried+10)
	await command("file settlement claim");check("award once",scene.progression.material==carried+10)
	await command("go home")
	check("ordinary private home entry",scene.location=="home" and not scene.audience.visible and scene.audience.text=="")
	check("branch carried through home",scene.recruit_status==branch and scene.recruit.visible==(branch=="joined"))
	before=state()
	for q in ["What can I furnish?","How much does that cost?","What changed?","What about the audience?"]:
		await command(q);check("home question no mutation "+q,state()==before)
	await command("buy reading chair then place reading chair by the window")
	await command("buy task lamp then place task lamp by the alcove")
	await command("buy keepsake shelf then place keepsake shelf by the far wall")
	check("three unique visible placed furnishings",scene.home.furniture=={"chair":1,"lamp":2,"shelf":4} and scene.progression.material==carried+4)
	check("furniture occupies actual floor",not scene.floor_free(Vector2i(3,1)) and not scene.floor_free(Vector2i(7,1)) and not scene.floor_free(Vector2i(8,4)))
	before=state();await command("place chair by the alcove");check("occupied placement rejected",state()==before)
	check("unsupported doorway placement clarifies",not scene.submit("place chair by the doorway") and state()==before)
	check("over there clarifies",not scene.submit("move the chair over there") and state()==before)
	await command("move reading chair by the reading nook")
	check("rearrange frees old cell",scene.home.furniture.chair==3 and scene.floor_free(Vector2i(3,1)) and not scene.floor_free(Vector2i(3,4)))
	await command("store task lamp then place task lamp by the window")
	check("store retains item and no refund or copies",scene.home.furniture.lamp==1 and scene.progression.material==carried+4)
	await command("go to locker then improve the storage")
	check("storage cost and usable capability",scene.home.storage and scene.progression.material==carried)
	await command("deposit 3 material");check("real deposit conserved",scene.progression.material==carried-3 and scene.home.stored==3)
	await command("withdraw 1 material");check("real withdrawal conserved",scene.progression.material==carried-2 and scene.home.stored==2)
	before=state()
	for request in ["buy chair","improve storage","withdraw 20 material","deposit 0 material","deposit 20 material"]:await command(request);check("rejected coherent "+request,state()==before)
	await command("rest");check("useful free return point",scene.hp==6 and scene.progression.material==carried-2)
	await command("return to the hub")
	check("outside presentation restored",scene.location=="hub" and scene.audience.visible and not scene.audience.text.is_empty())
	await command("go to shelter then go to concourse then go home")
	check("multiroom go home uses connected route",scene.location=="home" and scene.steps_done>0)
	for c in [Vector2i(1,5),Vector2i(9,1),Vector2i(6,6),Vector2i(10,4)]:
		check("layout leaves destinations reachable",scene.player_cell==c or not scene.path_to(c).is_empty())
	await command("go to locker");await frames(180);await command("save")
	var saved:Dictionary=scene.save_store.latest();check("home schema valid",scene.save_store.valid(saved))
	check("party floor valid",scene.Home.pixel_ok(saved.pet_position,scene.home) and (branch!="joined" or scene.Home.pixel_ok(saved.recruit_position,scene.home)))
	await command("continue")
	check("load inside private synchronously",not scene.audience.visible and scene.audience.text=="" and scene.home==saved.home and scene.progression==saved.progression)
	var loaded_before:=state()
	await command("place chair by the window")
	check("loaded occupied socket rejects across numeric types",state()==loaded_before)
	var mixed:Dictionary=saved.duplicate(true);mixed.home.furniture.chair=int(mixed.home.furniture.lamp)
	check("mixed numeric duplicate save rejected",not scene.save_store.valid(mixed))
	check("load queues inactive",scene.work.is_empty() and scene.current.is_empty())
	check("optional work not required",scene.tasks.values().all(func(v):return v=="available"))
	restarts.append({"directory":scene.save_store.directory,"expected":scene.save_store.latest()})
func failure_checks() -> void:
	var saved:Dictionary=scene.save_store.latest();var original:String=scene.save_store.directory
	var before:=state()
	check("stale command rejected",not scene.submit("withdraw 1","stale",scene.epoch-1) and state()==before)
	check("fresh ID",scene.submit("withdraw 1","once",scene.epoch));await settle()
	check("duplicate ID",not scene.submit("deposit 1","once",scene.epoch))
	await command("deposit 1");before=state()
	var obstruction:=base.path_join("obstruction");var f:=FileAccess.open(obstruction,FileAccess.WRITE);f.store_string("synthetic");f.close()
	scene.save_store.directory=obstruction.path_join("saves")
	for request in ["withdraw 1","deposit 1","move chair by the alcove","store chair","rest"]:
		await command(request);check("atomic failed save "+request,state()==before and "unchanged" in scene.message)
	check("failed quit stays open",not scene.save_and_quit() and not scene.quit_requested)
	scene.save_store.directory=original
	# Explicit synthetic fixture for acquisition rollback: no owner data.
	var fixture:Dictionary=saved.duplicate(true);fixture.home.furniture.lamp=-1;fixture.progression.material+=2
	scene.apply_snapshot(fixture);scene.save_store.directory=obstruction.path_join("saves");before=state()
	await command("buy lamp");check("failed buy refunds and no item",state()==before)
	fixture.home.storage=false;fixture.progression.material+=4+int(fixture.home.stored);fixture.home.stored=0
	scene.apply_snapshot(fixture);before=state();await command("improve storage");check("failed improvement no benefit",state()==before)
	fixture.location="hub";fixture.player=[3,3];fixture.pet_position=[448,510];fixture.recruit_position=[576,574];fixture.home=scene.Home.initial();fixture.progression.material=4
	scene.apply_snapshot(fixture);before=state();await command("file settlement claim");check("failed award no deed or money",state()==before)
	scene.save_store.directory=original;scene.apply_snapshot(saved)
	# Guard injection only; never persisted as a legitimate balance.
	scene.progression.material=1;scene.home.furniture.lamp=-1;before=state();await command("buy lamp");check("insufficient carried funds no item",state()==before)
	scene.apply_snapshot(saved)
	for mutation in ["wallet","duplicate","unowned","storage","blocked","version","foreign"]:
		var bad:Dictionary=saved.duplicate(true)
		match mutation:
			"wallet":bad.progression.material+=1
			"duplicate":bad.home.furniture.chair=bad.home.furniture.lamp
			"unowned":bad.home.owned=false
			"storage":bad.home.storage=false
			"blocked":bad.player=[3,4]
			"version":bad.erase("home_version")
			"foreign":bad.home.furniture.alien=0
		check("invalid save rejected "+mutation,not scene.save_store.valid(bad))
	before=state();scene.command_input.grab_focus();await key(KEY_W);await key(KEY_A);await key(KEY_S);await key(KEY_D);await key(KEY_E)
	check("home text focus protects gameplay",state()==before);scene.command_input.clear();scene.command_input.release_focus()
	scene.submit("return to the hub then go to shelter");await frames(8);paused=true
	var pos:Vector2=scene.human.position;await frames(20);check("pause freezes home travel",scene.human.position==pos)
	scene.submit("stop");paused=false;await settle();check("stop cancels queued boundary",scene.location=="home" and not scene.audience.visible)
	scene.submit("return to the hub");await frames(8);await key(KEY_S);await settle();check("direct movement reclaims",scene.work.is_empty() and scene.current.is_empty())
	await command("go to locker then save")
	# Retain a malformed newest candidate and load the last valid immutable record.
	f=FileAccess.open(original.path_join("snapshot-99999999.json"),FileAccess.WRITE);f.store_string("{broken synthetic");f.close()
	check("recovery skips corrupt snapshot",scene.load_latest() and scene.home.owned and not scene.audience.visible)
	await command("save");restarts[-1].expected=scene.save_store.latest()
func layout_checks() -> void:
	var saved:Dictionary=scene.save_store.latest()
	# Enumerate all 24 three-item layouts using synthetic snapshots. Every
	# non-prop floor cell must connect to the entrance; validator and pathfinder
	# are checked independently of the named-socket UI.
	for a in range(1,5):
		for b in range(1,5):
			for c in range(1,5):
				if a==b or a==c or b==c:continue
				var fixture:Dictionary=saved.duplicate(true)
				fixture.home.furniture={"chair":a,"lamp":b,"shelf":c};fixture.player=[1,5];fixture.pet_position=[320,638]
				scene.apply_snapshot(fixture)
				var reachable:=true
				for x in range(12):
					for y in range(7):
						var cell:=Vector2i(x,y)
						if cell!=scene.player_cell and scene.floor_free(cell) and scene.path_to(cell).is_empty():reachable=false
				check("all floor connected layout %d/%d/%d" % [a,b,c],reachable and scene.save_store.valid(fixture))
	scene.apply_snapshot(saved)
	var fixture:Dictionary=saved.duplicate(true);fixture.home.furniture.chair=0;fixture.player=[3,4]
	scene.apply_snapshot(fixture);var before:=state();await command("place chair by the reading nook");check("player footprint protected",state()==before)
	fixture.player=[1,5];fixture.pet_position=[448,510];scene.apply_snapshot(fixture);before=state()
	check("pet footprint protected",not scene.home_transaction({"operation":"place","item":"chair","socket":"reading nook"}) and state()==before)
	scene.apply_snapshot(saved)
	# Cross-room references cannot purchase even if ownership is real.
	before=state();check("stale room action rejected",not scene.execute({"verb":"home_action","operation":"deposit","amount":1,"target":"locker","target_location":"hub"}) and state()==before)
	await command("return to the hub then inspect home then go home then inspect it")
	check("cross-room pronoun cleared",scene.location=="home" and scene.recent=="" and scene.history.any(func(v):return "After completed actions" in v))
	await command("go to locker then withdraw 2 material then deposit 4 material")
	check("all funds can be stored without creation",scene.progression.material==0 and scene.home.stored==4)
	await command("return to the hub then go to bench then improve lens")
	check("no charge repeat B4 improvement after home",scene.progression.material==0 and scene.progression.levels.lens==1)
	await command("go home then go to locker then withdraw 4 material")
	check("empty wallet recoverable by withdrawal",scene.progression.material==4 and scene.home.stored==0)
	await command("return to the hub then ask pet to fetch supplies then go to bench then exchange supply bundle")
	check("B3 redemption after home preserves equation and label",scene.progression.material==8 and scene.supply_method=="pet" and scene.held_bundles()==0)
	await command("exchange supply bundle")
	check("repeat redemption stops without charge",scene.progression.material==8)
	await command("go to access then restore access panel then go to approach then go to marker then survey the approach")
	check("B3 tasks after home no extra funds",scene.progression.material==8 and scene.tasks.access=="completed" and scene.tasks.survey=="completed")
	await command("go home then go to locker then save")
	restarts[-1].expected=scene.save_store.latest()
func run() -> void:
	base=OS.get_environment("B5_SAVE_DIR")
	for branch in ["joined","declined","waiting"]:await home_route(branch,branch!="declined")
	await failure_checks()
	await layout_checks()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B5_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
