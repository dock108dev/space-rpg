extends "res://tests/run_b6.gd"
func fresh(chosen:String) -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	scene=load("res://scenes/expedition.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	serial+=1;scene.save_store.directory=base.path_join("case-%d"%serial)
	await command("try blast then try shield then try dash then choose "+chosen)
func yard_walk(target:String) -> void:
	for i in range(15):
		if scene.distance(scene.player_cell,scene.targets()[target].cell)<=1:return
		if scene.expedition.points==0:await command("end turn")
		var at:Vector2i=scene.player_cell
		await command("go to "+target)
		if scene.player_cell==at and scene.expedition.points>0:check("reachable yard target "+target,false);return
	check("bounded yard walk "+target,false)
func clear_warden() -> void:
	for i in range(20):
		if scene.expedition.cleared or scene.phase=="defeat":break
		if scene.expedition.points>=2:await command("shoot creature")
		else:await command("end turn")
	check("real warden cleared",scene.expedition.cleared and scene.hp>0)
func complete_dry(route:String) -> void:
	if route=="maintenance":await yard_walk("wheel");await command("turn isolation wheel")
	await command("take the "+route+" route")
	await yard_walk("drainage");await yard_walk("core")
	await failed_transaction("recover routing core")
	await command("recover routing core")
	check("physical dry crossing and objective",scene.expedition.crossed and scene.expedition.objective and scene.expedition.exposures==0)
	await record_restart()
	await command("retreat then go to hub then go to board")
	await failed_transaction("file relay report")
	await command("file relay report")
	check("ordinary chapter result",scene.location=="hub" and scene.expedition.reported and scene.expedition.result.reward==8)
func full_journey() -> void:
	await opening("joined")
	await command("go to bench then claim preparation kit then equip guard weave")
	await command("ask pet to fetch supplies then go to bench then exchange supply bundle")
	await command("go to access then restore access then go to board then file settlement claim then go home")
	await command("buy chair then place chair by the window then buy lamp then place lamp by the alcove then buy shelf then place shelf by the far wall")
	await command("go to locker then improve storage then deposit 4 material")
	check("home prepared without double bundle",scene.progression.material==20 and scene.home.stored==4)
	await command("go to hub then go to approach then go to marker then survey the approach")
	await command("go to range then test power then teach pet cover fetch")
	await command("go to hub then go to bench then improve lens then improve my power")
	await command("go to shelter then go to desk then rest then go to hub then go to approach")
	await command("enter expedition")
	check("sixth place real entry",scene.location=="objective" and scene.expedition.entered)
	await record_restart()
	var before:=state()
	for q in ["What am I preparing for?","What do we know about the route?","Check our equipment and condition.","What remains unfinished?","What did we accomplish?"]:
		await command(q);check("expedition query does not act "+q,state()==before)
	await command("end turn")
	check("cover plus base weave prevents otherwise one damage",scene.hp==6)
	check("real B6 pet cover and injury",scene.expedition.cover and scene.care.pet=="injured" and scene.expedition.assists==1)
	await command("guard then end turn")
	check("real traveler downing",scene.care.recruit=="downed" and scene.expedition.assists==2)
	await record_restart()
	await command("ask the pet to fetch cover");check("impaired learned capability refused",scene.care.pet=="injured" and "healthy pet" in scene.message)
	var damage_progress:int=scene.expedition.warden
	await command("retreat then go home")
	check("rescue carries all and private home",scene.location=="home" and not scene.audience.visible and scene.care.pet=="injured" and scene.care.recruit=="downed")
	await command("rest");check("rest no silent companion care",scene.hp==6 and scene.care.pet=="injured")
	await command("go to hub then go to shelter then go to desk then treat the pet then help the companion recover")
	check("paid explicit carried costs",scene.progression.material==8 and scene.home.stored==4 and scene.care.paid==2)
	await command("go to hub then go to bench then equip lens then go to approach")
	await command("go to barrier")
	await frames(120)
	await failed_transaction("enter expedition")
	await command("enter expedition")
	check("retry retains progress without farming",scene.expedition.warden==damage_progress)
	# Blast requires <=4; move once toward the warden from landing (distance 5).
	await command("move right then use blast")
	check("improved equipment and power actual seven impact",scene.expedition.warden==damage_progress-7)
	await clear_warden()
	await complete_dry("drainage")
	check("conserved chapter eight only on report",scene.progression.material==16 and scene.home.stored==4 and scene.expedition.result.supply_method=="pet")
	before=state();await command("file relay report");check("exactly once report",state()==before)
	await command("go home then go to locker then withdraw 2 material")
	check("post chapter home usable",scene.home.stored==2 and scene.progression.material==18 and not scene.audience.visible)
	await record_restart()
	await command("continue");check("post load home privacy and no queues",not scene.audience.visible and scene.work.is_empty() and scene.current.is_empty())
	before=state();await command("place chair by the alcove");check("post load occupied furniture intact",state()==before)
	await command("go to hub then go to approach then enter expedition")
	check("reentry never resets chapter",scene.expedition.objective and scene.expedition.reported and scene.expedition.warden==0)
	await yard_walk("core");before=state();await command("recover routing core");check("core cannot farm",state()==before)
	await command("retreat then go to hub then go to board")
	await invalid_and_rollback()
func baseline(chosen:String,branch:String) -> void:
	await fresh(chosen);await command("go to package then interact package");await fight()
	await command("go to package then collect package then go to shelter then go to desk then choose security then rest")
	await command("go to traveler then "+("decline traveler" if branch=="declined" else "join traveler"))
	if branch=="waiting":await command("have traveler wait here")
	await command("go to hub then go to bench then claim preparation kit then equip guard weave")
	await command("skip supplies then skip access then go to approach then skip survey")
func variants_b7() -> void:
	for chosen in ["shield","dash","blast"]:
		await baseline(chosen,"waiting" if chosen=="shield" else "declined")
		if chosen!="blast":
			await command("go to range then test power then go to hub then go to bench then improve my power then improve "+("weave" if chosen=="shield" else "rig"))
			await command("go to approach")
		await command("enter expedition")
		if chosen=="shield":
			await command("raise shield");check("actual improved shield six",scene.expedition.guard==6)
			var hp:int=scene.hp;await command("end turn");check("actual shield pressure prevented",scene.hp==hp and scene.expedition.assists==0)
		await clear_warden()
		if chosen=="blast":
			await complete_dry("maintenance")
			check("zero optional work and declined viable",scene.tasks.values().all(func(v):return v=="skipped") and scene.recruit_status=="declined" and scene.progression.material==28)
		else:
			if chosen=="dash":
				await command("retreat then go to hub then go to shelter then go to desk then rest then go to hub then go to bench then equip rig then go to approach then enter expedition")
			await command("take the live lane")
			await yard_walk("crossing")
			await command("end turn")
			var hp:int=scene.hp
			if chosen=="shield":
				await command("raise shield then move right then move right")
				check("live lane passive improved weave prevents damage",scene.hp==hp and scene.expedition.exposures==2)
			else:
				# Existing equipment can only be changed safely outside. Dash still benefits from upgraded power here.
				await command("move left then end turn")
				var at:Vector2i=scene.player_cell;await command("dash right")
				check("improved power plus rig crosses five real cells",scene.player_cell==at+Vector2i.RIGHT*5 and scene.expedition.exposures==1)
			await yard_walk("core");await command("recover routing core then retreat then go to hub then go to board then file relay report")
			check("live route complete "+chosen,scene.expedition.reported and scene.expedition.route=="live")
		await command("go to shelter then go to desk then rest")
		if scene.care.pet=="injured":await command("begin assisted pet care then continue assisted care then continue assisted care")
		if chosen=="shield":
			await command("go to traveler then rejoin traveler");check("waiting then rejoined after complete expedition",scene.recruit_status=="joined")
		await record_restart()
func failed_transaction(text:String) -> void:
	await frames(180)
	var old:String=scene.save_store.directory
	var block:=base.path_join("transaction-obstruction");var f:=FileAccess.open(block,FileAccess.WRITE);f.store_string("synthetic");f.close()
	scene.save_store.directory=block.path_join("saves");var before:=state();var pet_at:Vector2=scene.pet.position;var recruit_at:Vector2=scene.recruit.position
	await command(text)
	check("atomic failure "+text,state()==before and scene.pet.position==pet_at and scene.recruit.position==recruit_at)
	scene.save_store.directory=old
func invalid_and_rollback() -> void:
	var saved:Dictionary=scene.save_store.latest()
	for field in ["warden","route","objective","reported","points","reward","party","money","position"]:
		var bad:Dictionary=saved.duplicate(true)
		match field:
			"warden":bad.expedition.warden=12
			"route":bad.expedition.route="magic"
			"objective":bad.expedition.objective=false
			"reported":bad.expedition.reported=false
			"points":bad.expedition.points=5
			"reward":bad.expedition.result.reward=16
			"party":bad.care.pet="dead"
			"money":bad.progression.material+=8
			"position":bad.location="objective";bad.player=[6,2]
		check("invalid B7 combination "+field,not scene.save_store.valid(bad))
	check("ambiguous route refuses",not scene.submit("take the route"))
	var before:=state();check("stale command",not scene.submit("file relay report","stale",scene.epoch-1) and state()==before)
	check("unique question",scene.submit("what did we accomplish?","once",scene.epoch));check("duplicate no effects",not scene.submit("file relay report","once",scene.epoch))
	# Malformed immutable recovery evidence is preserved.
	var path:String=scene.save_store.directory.path_join("snapshot-999999999.json");var f:=FileAccess.open(path,FileAccess.WRITE);f.store_string("{broken B7 recovery fixture");f.close()
	await command("continue");check("latest valid recovery preserves malformed evidence",scene.expedition.reported and FileAccess.get_file_as_string(path).begins_with("{broken"))
func recovery_and_failure() -> void:
	await baseline("blast","joined")
	await command("go to hub then go to board then file settlement claim then go home")
	await command("buy chair then buy lamp then buy shelf then go to locker then improve storage")
	await command("go to hub then go to approach then go to range then test power then go to hub then go to bench then improve lens then improve weave then improve rig then improve my power")
	await command("go home then go to locker then deposit 4 material then go to hub then go to approach then enter expedition")
	await command("guard then end turn");await command("guard then end turn")
	check("recoverable actual setback",scene.care.pet=="injured" and scene.care.recruit=="downed")
	await command("retreat then go to shelter") # No direct shelter from approach: partial plan must stop truthfully.
	check("cross room partial no teleport",scene.location=="approach")
	await command("go to hub then go to shelter then go to desk then rest")
	var before:=state();await command("treat the pet");check("stored funds never spent",state()==before and scene.home.stored==4)
	await command("go home then go to locker then withdraw 4 material then go to hub then go to shelter then go to desk then treat the pet then help the companion recover")
	check("exhausted wallet actual",scene.progression.material==0 and scene.home.stored==0)
	await command("go to hub then go to approach then enter expedition")
	await command("guard then end turn");await command("guard then end turn")
	await command("retreat then go to hub then go to shelter then go to desk then rest")
	await aid("pet");await aid("companion")
	check("exhausted repeat assistance no source",scene.progression.material==0 and scene.home.stored==0 and scene.care.assisted==2)
	await command("go to hub then go to approach then enter expedition")
	# Failed-write fixture: ordinary attack and retreat must restore all state/positions.
	var original:String=scene.save_store.directory;var obstruction:=base.path_join("blocked-file");var f:=FileAccess.open(obstruction,FileAccess.WRITE);f.store_string("synthetic write failure");f.close()
	scene.save_store.directory=obstruction.path_join("saves");before=state()
	await command("shoot creature");check("failed combat write rollback",state()==before)
	await command("retreat");check("failed rescue write retains every member",state()==before and scene.location=="objective")
	scene.save_store.directory=original
	for y in range(7):scene.extra_blocks.append(Vector2i(0,y))
	before=state();await command("retreat");check("blocked floor rescue refuses",state()==before)
	await command("call evacuation");check("explicit overhead rescue includes downed members",scene.location=="approach" and scene.recruit_status=="joined")
	scene.extra_blocks.clear()
	await command("enter expedition")
	# Input/control guards while actual danger is active.
	scene.command_input.grab_focus();before=state();await key(KEY_W);await key(KEY_E);check("text focus does not execute world",state()==before);scene.command_input.clear();scene.command_input.release_focus()
	scene.submit("guard then end turn then shoot creature");await frames(5);paused=true;before=state();var pos:Vector2=scene.pet.position;await frames(30);check("pause freezes party and state",state()==before and scene.pet.position==pos);scene.submit("stop");paused=false;await settle();check("Stop cancels future work",scene.work.is_empty() and scene.current.is_empty())
	# Force no fixture damage: unequip via ordinary return, then actual warden pulses defeat.
	await command("retreat then go to hub then go to bench then unequip weave then go to approach then enter expedition")
	for i in range(8):
		if scene.phase=="defeat":break
		await command("end turn")
	check("ordinary defeat",scene.phase=="defeat")
	var last:Dictionary=scene.save_store.latest();await command("continue")
	check("latest living exact recovery",scene.hp==last.hp and scene.care==last.care and scene.expedition==last.expedition)
	await command("retreat then go to hub then go to shelter then go to desk then rest then go to hub then go to bench then equip weave then go to approach then enter expedition")
	await clear_warden();await complete_dry("maintenance")
	check("recovery retry reaches chapter end",scene.expedition.reported)
	await record_restart()
func run() -> void:
	base=OS.get_environment("B7_SAVE_DIR")
	await full_journey();await variants_b7();await recovery_and_failure()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B7_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
