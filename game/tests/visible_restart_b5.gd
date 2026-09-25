extends SceneTree
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func run() -> void:
	var scene=load("res://scenes/owned_home.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(30)
	scene.save_store.directory=OS.get_environment("B5_SAVE_DIR").path_join("case-1")
	if not scene.load_latest():push_error("Visible Continue failed");quit(1);return
	print("VISIBLE_CONTINUE ",JSON.stringify(scene.snapshot()))
	scene.say("Restarted in a new process. Your deed, furniture layout, 2 carried and 2 stored material are restored. The interior remains private. No old command is active.")
	await frames(90)
	scene.submit("What changed?");await frames(150)
	scene.submit("withdraw 1 material");await frames(120)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("B5_CAPTURE_DIR").path_join("restart.png"))
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	var f:=FileAccess.open(OS.get_environment("B5_SAVE_DIR").path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":scene.snapshot()}]));f.close()
	if not scene.save_and_quit():push_error("Visible restart quit failed");quit(1)
