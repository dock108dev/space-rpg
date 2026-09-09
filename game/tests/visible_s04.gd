extends "res://tests/run_s04.gd"
var capture_dir:=""
func check(name:String,condition:bool) -> void:
	super.check(name,condition)
	if not condition:push_error(name);quit(1)
func shot(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func show_step(target:Vector2i) -> void:
	await step(target);await frames(15)
func run() -> void:
	capture_dir=OS.get_environment("S04_CAPTURE_DIR");base=OS.get_environment("S04_SAVE_DIR")
	if capture_dir.is_empty() or base.is_empty():quit(2);return
	await fresh("shield");await frames(45);await shot("01-before-learning")
	check("before cannot fetch",not scene.fetch_cache());await frames(50)
	scene.assign_walk();await frames(10);await shot("02-assigned-movement");await settle();await frames(25)
	scene.interact();await frames(70);await shot("03-package-learning");scene.interact()
	# Full legal shield encounter with held cue, damage and save/retry in S03 regression.
	await fight();await frames(60);await shot("04-encounter-complete")
	scene.assign_walk();await frames(60);await shot("05-shelter-travel");await settle();await frames(30)
	scene.interact();await frames(60);await shot("06-reward-choices")
	check("select opportunity",scene.choose_reward("opportunity"));await frames(60);await shot("07-opportunity-route")
	var human_at:Vector2=scene.human.position
	scene.fetch_cache();await frames(70);await shot("08-pet-fetching");await settle();await frames(80)
	check("visible useful fetch complete",scene.cache_taken and scene.kits==1 and scene.human.position==human_at)
	await shot("09-pet-delivered");scene.manual_save();await frames(40)
	scene.reset_demo();scene.load_latest();await frames(60);await shot("10-resumed-result")
	print("S04_VISIBLE ",JSON.stringify({"window":DisplayServer.window_get_size(),"screen":DisplayServer.screen_get_size(),"scale":DisplayServer.screen_get_scale(),"renderer":RenderingServer.get_current_rendering_method()}))
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	scene.queue_free();await frames(2);quit()
