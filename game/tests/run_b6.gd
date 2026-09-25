extends "res://tests/run_b5.gd"
func fresh(chosen:String) -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	scene=load("res://scenes/companions_care.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	serial+=1;scene.save_store.directory=base.path_join("case-%d"%serial)
	await command("try blast then try shield then try dash then choose "+chosen)
func command(text:String) -> void:
	await super.command(text)
	print("OUTCOME ",text," => ",scene.message)
func record_restart() -> void:
	await frames(150);await command("save")
	var directory:String=base.path_join("restart-%d"%restarts.size())
	DirAccess.make_dir_recursive_absolute(directory)
	var expected:Dictionary=scene.save_store.latest()
	var f:=FileAccess.open(directory.path_join("snapshot-%09d.json"%int(expected.sequence)),FileAccess.WRITE);f.store_string(JSON.stringify(expected));f.close()
	restarts.append({"directory":directory,"expected":expected})
func prepare(branch:String) -> void:
	await opening(branch)
	await command("go to bench then claim preparation kit then equip guard weave")
	await command("ask pet to fetch supplies")
	check("training earned through physical pet supplies",scene.supply_method=="pet")
	await command("go to approach then go to range then test power then teach the pet cover fetch")
	check("persistent useful lesson",scene.care.trained and scene.progression.material==20)
	await command("go to hub then go to shelter then go to desk then rest then go to hub then go to approach")
func setback() -> void:
	await command("go to breach");await frames(180)
	await command("enter breach")
	check("real separate danger",scene.care.encounter=="active" and scene.enemy_hp==0 and scene.journey=="complete")
	var before:=state()
	for q in ["How is the pet?","What can my companion do?","What does treatment cost?","What is the breach?"]:
		await command(q);check("query no mutation "+q,state()==before)
	await command("guard then end turn")
	check("real pet injury",scene.care.pet=="injured")
	check("cover fetch actual benefit",scene.care.cover)
	if scene.recruit_status=="joined":check("autonomous one shot",scene.care.assists>=1 and scene.care.threat==11)
	await command("guard then end turn")
	if scene.recruit_status=="joined":check("real recoverable recruit downing",scene.care.recruit=="downed" and scene.care.threat==10)
	check("protagonist survives chosen guard",scene.hp>0)
	await command("retreat")
	check("coherent injured return",scene.location=="hub" and scene.care.pet=="injured" and scene.care.encounter=="retreated")
	before=state();await command("ask pet to fetch supplies");check("injured pet refusal",state()==before and "injured" in scene.message)
	await record_restart()
	await command("go to shelter then go to desk then rest")
	check("free rest never heals allies",scene.hp==6 and scene.care.pet=="injured")
func aid(actor:String) -> void:
	await command("begin assisted "+actor+" care")
	await command("continue assisted care")
	check("one attended round remains impaired",scene.care.aid_steps==1)
	await record_restart()
	await command("continue assisted care")
	check("two attended rounds restore",scene.care["pet" if actor=="pet" else "recruit"]=="healthy" and scene.care.aid_actor=="")
func run() -> void:
	base=OS.get_environment("B6_SAVE_DIR")
	await prepare("joined")
	await command("go to hub then go to bench then improve lens then improve weave then improve rig then improve my power")
	await command("go to board then file settlement claim then go home")
	await command("buy chair then place chair by the window then buy lamp then place lamp by the alcove then buy shelf then place shelf by the far wall")
	await command("go to locker then improve storage then deposit 4 material")
	check("maximum spending four total all stored",scene.progression.material==0 and scene.home.stored==4)
	await command("return to the hub then go to approach")
	await setback()
	var empty_before:=state();await command("treat the pet")
	check("zero carried refuses without silently spending storage",state()==empty_before and scene.home.stored==4)
	await command("go home then go to locker then withdraw 4 material")
	check("home did not heal and withdrawal actual",scene.care.pet=="injured" and scene.progression.material==4 and scene.home.stored==0 and not scene.audience.visible)
	var occupied_before:=state();await command("place chair by the alcove");check("B6 loaded numeric-safe furniture",state()==occupied_before)
	await command("return to the hub then go to shelter then go to desk")
	var wallet:int=scene.progression.material
	await command("treat the pet then help the companion recover")
	check("two paid treatments exactly four",scene.progression.material==wallet-4 and scene.care.paid==2 and scene.care.pet=="healthy" and scene.care.recruit=="healthy")
	var before:=state();await command("treat the pet");check("healthy no second charge",state()==before)
	await record_restart()
	# Restored capability in actual repeat danger, no injected injury.
	await command("go to hub then go to approach")
	await setback()
	await aid("pet");await aid("companion")
	check("repeat free treatment no funds created",scene.progression.material==wallet-4 and scene.care.assisted==2)
	await guards()
	for branch in ["declined","waiting"]:
		await prepare(branch);await setback();await aid("pet")
		check("optional recruit never lost",scene.recruit_status==branch and scene.care.recruit=="healthy")
		await command("go to traveler then "+("join traveler" if branch=="declined" else "rejoin traveler"))
		check("rejoin viable",scene.recruit_status=="joined")
	await variants()
	await solo_completion()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B6_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
func guards() -> void:
	var saved:Dictionary=scene.save_store.latest();var original:String=scene.save_store.directory
	for field in ["pet","recruit","trained","aid_steps","points","encounter","paid"]:
		var bad:Dictionary=saved.duplicate(true)
		match field:
			"pet":bad.care.pet="dead"
			"recruit":bad.care.recruit="missing"
			"trained":bad.care.trained=false;bad.care.cover=true
			"aid_steps":bad.care.aid_steps=2
			"points":bad.care.points=5
			"encounter":bad.care.encounter="active"
			"paid":bad.care.paid+=1
		check("invalid condition rejected "+field,not scene.save_store.valid(bad))
	check("unspecified actor clarifies",not scene.submit("treat them"))
	var before:=state();check("stale guard",not scene.submit("treat the pet","stale",scene.epoch-1) and state()==before)
	check("fresh query ID",scene.submit("How is the pet?","once",scene.epoch))
	check("duplicate query ID",not scene.submit("treat the pet","once",scene.epoch))
	# Named negative fixture only: failure-write mechanics, not playable injury proof.
	var injured:Dictionary=saved.duplicate(true);injured.care.pet="injured";injured.care.paid-=1;injured.progression.material+=2;scene.apply_snapshot(injured)
	var obstruction:=base.path_join("obstruction");var f:=FileAccess.open(obstruction,FileAccess.WRITE);f.store_string("negative fixture");f.close()
	scene.save_store.directory=obstruction.path_join("saves");before=state()
	await command("treat the pet");check("paid write rollback every field",state()==before)
	await command("begin assisted pet care");check("assistance write rollback every field",state()==before)
	scene.save_store.directory=original;scene.apply_snapshot(saved)
	await command("go to hub then go to approach then go to breach");await frames(180);await command("enter breach")
	before=state();scene.command_input.grab_focus();await key(KEY_W);await key(KEY_E);check("typing no danger action",state()==before);scene.command_input.clear();scene.command_input.release_focus()
	scene.submit("guard then end turn then shoot creature");await frames(5);paused=true
	before=state();var pet_at:Vector2=scene.pet.position;await frames(30);check("pause freezes turn state and actors",state()==before and pet_at==scene.pet.position)
	scene.submit("stop");paused=false;await settle();check("Stop retains completed guard and cancels future",scene.work.is_empty() and scene.current.is_empty())
	# Blocked route fixture, no injury injection.
	for y in range(7):scene.extra_blocks.append(Vector2i(1,y))
	before=state();await command("retreat");check("blocked return no teleport",state()==before and scene.location=="approach")
	await command("call evacuation");check("explicit rescue returns party despite blockage",scene.location=="hub" and scene.recruit_status=="joined")
	scene.extra_blocks.clear()
func variants() -> void:
	for chosen in ["blast","shield","dash"]:
		await fresh(chosen)
		await command("go to package then interact package");await fight()
		await command("go to package then collect package then go to shelter then go to desk then choose security then rest")
		await command("go to traveler then decline traveler then go to hub then go to bench then claim preparation kit")
		await command("go to approach then go to range then test power then go to hub then go to bench then improve my power")
		var gear:String={"blast":"lens","shield":"weave","dash":"rig"}[chosen]
		await command("improve "+gear+" then equip "+gear+" then go to approach then go to breach");await frames(180);await command("enter breach")
		if chosen=="blast":
			await command("use blast");check("danger improved lens blast seven",scene.care.threat==5)
			await command("shoot creature");check("danger improved bolt four",scene.care.threat==1)
		elif chosen=="shield":
			await command("raise shield");check("danger improved shield and weave six",scene.care.guard==6)
			var hp:int=scene.hp;await command("end turn");check("shield actual pressure prevented",scene.hp==hp)
		else:
			await command("move 2 up")
			var start:Vector2i=scene.player_cell
			await command("dash left");check("danger improved rig dash five",scene.player_cell==start+Vector2i.LEFT*5 and scene.care.points==1)
		await command("call evacuation")
		check("solo danger remains completable without recruit",scene.location=="hub" and scene.recruit_status=="declined")

func solo_completion() -> void:
	await prepare("declined")
	await command("go to breach");await frames(180);await command("enter breach")
	var occupied:Dictionary=scene.save_store.latest();occupied.player=[9,3]
	check("invalid active enemy overlap rejected",not scene.save_store.valid(occupied))
	var before:=state();scene.extra_blocks.append(Vector2i(8,3));await command("shoot creature")
	check("blocked projectile cannot hit",state()==before);scene.extra_blocks.clear()
	await command("shoot creature then shoot creature then end turn")
	await command("shoot creature then shoot creature then end turn")
	await command("shoot creature then shoot creature")
	check("actual victory without optional recruit",scene.care.encounter=="cleared" and scene.care.victories==1 and scene.hp>0 and scene.recruit_status=="declined")
	await command("go to hub then go to shelter then go to desk")
	await command("begin assisted pet care then continue assisted care")
	var original:String=scene.save_store.directory;var before_round:=state()
	scene.save_store.directory=base.path_join("obstruction/saves")
	await command("continue assisted care")
	check("final assisted round rollback retains injury and progress",state()==before_round and scene.care.pet=="injured" and scene.care.aid_steps==1)
	scene.save_store.directory=original
	await command("continue assisted care")
	check("retry final care once",scene.care.pet=="healthy" and scene.care.assisted==1)
	# Defeat comes from real enemy actions; Continue must use the living boundary.
	await command("rest then go to hub then go to approach then go to breach");await frames(180);await command("enter breach")
	for i in range(5):
		if scene.phase=="defeat":break
		await command("end turn")
	check("ordinary protagonist defeat",scene.phase=="defeat")
	var last:Dictionary=scene.save_store.latest()
	await command("continue")
	check("defeat restores actual saved resources and conditions",scene.hp==last.hp and scene.care==last.care and scene.progression==last.progression and scene.home==last.home)
	await record_restart()
