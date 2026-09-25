extends SceneTree
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func run() -> void:
	var scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(30)
	# Ordinary Continue resolves the saved current-session pointer at startup.
	if not scene.load_latest():push_error("Visible Continue failed");quit(1);return
	print("VISIBLE_CONTINUE ",JSON.stringify(scene.snapshot()))
	scene.say("Restarted in a new process. Chapter result, core delivery, furniture, funds and actual party injuries are restored. No old command is active.")
	await frames(90)
	scene.submit("What did we accomplish?");await frames(150)
	scene.submit("What does treatment cost?");await frames(120)
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(OS.get_environment("B8_CAPTURE_DIR").path_join("restart.png"))
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	var f:=FileAccess.open(OS.get_environment("B8_SAVE_DIR").path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":scene.snapshot()}]));f.close()
	if not scene.save_and_quit():push_error("Visible restart quit failed");quit(1)
