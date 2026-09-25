extends "res://tests/run_b7.gd"
func fresh(chosen:String) -> void:
	paused=false
	if is_instance_valid(scene):scene.queue_free();await frames(2)
	scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	serial+=1
	check("setup before chapter",scene.setup_open and scene.name_input.text=="Alex")
	check("start character",scene.start_character("Étoile 星 "+str(serial),["amber","teal","plum"][serial%3]))
	scene.command_input.release_focus();scene.save_store.directory=base.path_join("case-%d"%serial)
	await command("try blast then try shield then try dash then choose "+chosen)
	check("identity validated in actual save",scene.save_store.valid(scene.save_store.latest()))
	await record_restart()
func complete_dry(route:String) -> void:
	if route=="maintenance":await yard_walk("wheel");await command("turn isolation wheel")
	await command("take the "+route+" route")
	var points:int=scene.expedition.points;var round_before:int=scene.expedition.round
	await command("walk safely then go to drainage then go to core")
	check("safe dry journey keeps AP and round",scene.expedition.points==points and scene.expedition.round==round_before)
	check("safe dry journey no exposure",scene.expedition.crossed and scene.expedition.exposures==0)
	await failed_transaction("recover routing core")
	await command("recover routing core");await record_restart()
	await command("retreat then go to hub then go to board")
	await failed_transaction("file relay report");await command("file relay report")
	check("ordinary chapter result",scene.expedition.reported and scene.expedition.result.reward==8)
func b8_checks() -> void:
	var clean=scene.ExperienceSave
	check("blank name default",clean.clean_name("  \n ")=="Alex")
	check("Unicode bounded",clean.clean_name("星".repeat(70)).length()==32)
	check("control and direction sanitized",clean.clean_name("A\n\t\u202eB")=="AB")
	var original:=state()
	for q in ["who am i","what now","why does End turn stop my plan?","can I heal my pet?","where am i?","how do action points work?"]:
		await command(q);check("B8 question informational "+q,state()==original)
	for key in ["name","appearance"]:
		var bad:Dictionary=scene.save_store.latest().duplicate(true);bad.character[key]="";check("reject malformed identity "+key,not scene.save_store.valid(bad))
	var bad:Dictionary=scene.save_store.latest().duplicate(true);bad.erase("experience_version");check("no B7 migration",not scene.save_store.valid(bad))
	scene.command_input.grab_focus();await key(KEY_W);await key(KEY_E);check("B8 typing captures controls",state()==original);scene.command_input.clear()
	scene.show_help();check("help pauses",paused and scene.help_panel.visible);scene.toggle_pause();check("help restores input",not paused and scene.command_input.has_focus())
	scene.set_large_text(true);scene.refresh_choices();await frames(3)
	check("minimum native window",root.min_size==Vector2i(1152,882))
	check("choices scroll and Stop visible",scene.choice_scroll.position.y+scene.choice_scroll.size.y<=scene.command_input.position.y and scene.stop_button.position.y+scene.stop_button.size.y<=980)
	check("large input font",scene.command_input.get_theme_font_size("font_size")==roundi(18*1.25))
	scene.set_large_text(false)
	await command("save");var directory:String=scene.save_store.directory;var expected:Dictionary=scene.save_store.latest()
	check("new setup opens",scene.reset_demo() and scene.setup_open)
	check("fresh preserves former session",scene.start_character("<b>"+"星".repeat(60),"plum") and scene.save_store.directory!=directory)
	check("name is literal and bounded",scene.character.name.length()==32 and scene.character.name.begins_with("<b>"))
	scene.save_store.directory=directory;check("Continue closes setup restores identity",scene.load_latest() and scene.character==expected.character and not scene.setup_open)
	check("appearance on moving rig",scene.human.groups.toward.get_node("torso").get_child(0).material.get_shader_parameter("jacket")==scene.PALETTES[scene.character.appearance])
	check("facing restored immediately",scene.human.facing==expected.facing)
	await command("go to approach then enter expedition")
	check("B8 boundary fixture entered actual cleared yard",scene.location=="objective" and scene.expedition.cleared)
	await command("walk safely");scene.stop_work("test stop");check("Stop disables safe walking",not scene.safe_walking)
	# Synthetic post-completion fixture solely for live-floor safety boundary.
	var before:Dictionary=scene.snapshot();scene.expedition.objective=false;scene.expedition.reported=false;scene.expedition.result={};scene.expedition.crossed=false;scene.expedition.route="live";scene.player_cell=Vector2i(5,3);scene.human.position=scene.point(scene.player_cell)
	scene.safe_walking=true;var live_before:=state()
	check("safe walk refuses energized floor",not scene.yard_move(Vector2i(6,3),false) and state()==live_before and not scene.safe_walking)
	scene.apply_snapshot(before)
	await record_restart()
func run() -> void:
	base=OS.get_environment("B8_SAVE_DIR")
	await full_journey();await variants_b7();await recovery_and_failure();await b8_checks()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B8_CHECKS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
