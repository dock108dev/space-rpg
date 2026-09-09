extends SceneTree
var scene:Node2D
var capture_dir:=""
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func settle() -> void:
	for i in range(400):
		if not scene.busy:break
		await process_frame
func shot(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func act(mode:String,target:Vector2i) -> void:
	scene.mode=mode
	if not scene.act(target):push_error("Tour action rejected: "+scene.message);quit(1)
	await settle();await frames(30)
func enemy() -> void:
	scene.end_turn();await settle();await frames(65)
func run() -> void:
	capture_dir=OS.get_environment("S03_CAPTURE_DIR")
	if capture_dir.is_empty() or OS.get_environment("S03_SAVE_DIR").is_empty():push_error("Disposable capture paths required");quit(2);return
	scene=load("res://scenes/tactical_encounter.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(30)
	print("S03_VISIBLE ",JSON.stringify({"window":DisplayServer.window_get_size(),"screen":DisplayServer.screen_get_size(),"scale":DisplayServer.screen_get_scale(),"renderer":RenderingServer.get_current_rendering_method()}))
	await shot("selection")
	for id in ["blast","shield","dash"]:
		scene.demonstrate(id);await frames(18);await shot("demo-"+id);await settle();await frames(30)
	scene.choose("shield");await frames(40)
	for i in range(4):await act("move",scene.player_cell+Vector2i.RIGHT)
	await enemy();await enemy();await shot("preparation");await frames(100)
	await act("power",scene.player_cell);await shot("shield");await enemy()
	await act("bolt",scene.enemy_cell);scene.manual_save();await shot("manual-save");await frames(50)
	await enemy();await enemy();await enemy()
	scene.end_turn();await frames(29);await shot("defeat");await settle();await frames(60);await shot("retry-loaded")
	await act("bolt",scene.enemy_cell);await enemy();await act("bolt",scene.enemy_cell);await frames(70);await shot("success")
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	if scene.phase!="success":push_error("Tour did not complete");quit(1);return
	scene.queue_free();await frames(2);quit()
