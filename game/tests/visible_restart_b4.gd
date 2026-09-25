extends SceneTree
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func run() -> void:
	var scene=load("res://scenes/preparation.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(30)
	scene.save_store.directory=OS.get_environment("B4_SAVE_DIR").path_join("case-1")
	if not scene.load_latest():push_error("Visible Continue failed");quit(1);return
	print("VISIBLE_CONTINUE ",JSON.stringify(scene.snapshot()))
	scene.say("Restarted in a new process. The saved equipment, 16 materials, improved blast and exchanged bundle are restored. No old command is active.")
	await frames(90)
	scene.submit("what equipment do I have?");await frames(150)
	scene.submit("test power");await frames(120)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("B4_CAPTURE_DIR").path_join("restart.png"))
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	if not scene.save_and_quit():push_error("Visible restart quit failed");quit(1)
