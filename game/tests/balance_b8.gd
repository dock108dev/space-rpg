extends "res://tests/run_b7.gd"
var entered_commands:Array=[]
func command(text:String) -> void:
	entered_commands.append(text);await super.command(text)
func run() -> void:
	base=OS.get_environment("B8_SAVE_DIR")
	var fixture:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("B8_BALANCE_FIXTURE")))
	var rows:Array=[]
	for version in ["B7","B8"]:
		for route in ["drainage","maintenance","live"]:
			if is_instance_valid(scene):scene.queue_free();await frames(2)
			scene=load("res://scenes/expedition.tscn" if version=="B7" else "res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
			if version=="B8":scene.start_character("Balance fixture","amber")
			scene.apply_snapshot(fixture);scene.save_store.directory=base.path_join(version+"-"+route)
			entered_commands=[]
			if route=="maintenance":
				await yard_walk("wheel");await command("turn isolation wheel")
			await command("take the "+route+(" lane" if route=="live" else " route"))
			if version=="B8" and route!="live":await command("walk safely then go to drainage then go to core")
			else:
				if route!="live":await yard_walk("drainage")
				await yard_walk("core")
			check("actual crossing "+version+route,scene.expedition.crossed)
			await command("recover routing core")
			rows.append({"version":version,"route":route,"commands":entered_commands.duplicate(),"command_count":entered_commands.size(),"end_turn_count":entered_commands.count("end turn"),"health_before":fixture.hp,"health_after":scene.hp,"pet":scene.care.pet,"recruit":scene.care.recruit,"exposures":scene.expedition.exposures,"points":scene.expedition.points,"round":scene.expedition.round,"material":scene.progression.material,"objective":scene.expedition.objective})
	var f:=FileAccess.open(OS.get_environment("B8_BALANCE_OUTPUT"),FileAccess.WRITE);f.store_string(JSON.stringify({"rows":rows,"checks":checks},"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
