extends "res://tests/run_b8.gd"
func run() -> void:
	base=OS.get_environment("B8_SAVE_DIR")
	scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	check("blank setup starts default",scene.start_character("  ","amber") and scene.character.name=="Alex")
	await command("try blast then try shield then try dash then choose blast")
	check("early save loads in same process",scene.load_latest())
	var first:String=scene.save_store.directory
	var first_file:=first.path_join("snapshot-000000001.json");var first_bytes:=FileAccess.get_file_as_bytes(first_file)
	check("new character start",scene.start_character("Étoile 星 "+"L".repeat(60),"plum"))
	check("unsaved Continue restores previous character",scene.load_latest() and scene.character.name=="Alex" and scene.save_store.directory==first)
	check("second saved identity start",scene.start_character("Étoile 星 "+"L".repeat(60),"plum"))
	await command("try blast then try shield then try dash then choose shield")
	check("first character bytes preserved",FileAccess.get_file_as_bytes(first_file)==first_bytes)
	scene.list_saved_characters();check("two saved characters accessible",scene.saved_characters.item_count==2)
	check("single current item can be selected",scene.saved_characters.allow_reselect)
	check("Unicode name bounded persisted",scene.save_store.latest().character.name.length()==32)
	var second:String=scene.save_store.directory
	await record_restart()
	# Failed snapshot write keeps current session, resources and identity open.
	scene.save_store.directory=base.path_join("locked-session");DirAccess.make_dir_recursive_absolute(scene.save_store.directory.path_join(".writing"))
	var before:=state();check("failed save keeps game open",not scene.save_and_quit() and not scene.quit_requested and state()==before)
	scene.save_store.directory=second
	# Pointer failure happens AFTER an immutable successful save. Never roll back
	# that durable state; prevent quit and keep the earlier-character recovery UI.
	DirAccess.remove_absolute(base.path_join("current-session.txt"))
	DirAccess.make_dir_absolute(base.path_join("current-session.txt"))
	before=state();check("pointer failure prevents quit",not scene.save_and_quit() and not scene.quit_requested and not scene.pointer_ok and state()==before)
	check("pointer failure still retains valid snapshot",not scene.save_store.latest().is_empty())
	DirAccess.remove_absolute(base.path_join("current-session.txt"))
	check("pointer recovery successful save quit",scene.save_and_quit() and scene.quit_requested and scene.pointer_ok)
	# Explicit Earlier selection must override the last-session pointer even
	# while a newly created character has not been saved yet.
	scene.start_character("Unsaved selection check","teal")
	scene.list_saved_characters()
	for index in scene.saved_characters.item_count:
		if scene.saved_characters.get_item_metadata(index)==first:scene.saved_characters.item_selected.emit(index)
	check("explicit earlier character overrides unsaved Continue pointer",scene.save_store.directory==first and scene.character.name=="Alex")
	for index in scene.saved_characters.item_count:
		if scene.saved_characters.get_item_metadata(index)==second:scene.saved_characters.item_selected.emit(index)
	# Idle pause resume, Stop, and text focus are observed through real input events.
	scene.toggle_pause();scene.toggle_pause();check("pause returns command focus",scene.command_input.has_focus())
	before=state();await key(KEY_W);await key(KEY_E);check("typing never drives world",state()==before)
	scene.command_input.clear();scene.command_input.release_focus()
	scene.submit("move 2 right then move 2 left");await frames(8);scene.stop_work("Stop review");await settle();check("Stop cancels remaining steps",scene.work.is_empty() and scene.current.is_empty())
	await command("go to package");check("arrival replaces stale outcome",scene.outcome.text.begins_with("Arrived beside package"))
	await command("save");await record_restart()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify(restarts));f.close()
	f=FileAccess.open(OS.get_environment("B8_ERGONOMICS_PATH"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
