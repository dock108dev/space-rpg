extends "res://tests/run_b2.gd"
# All scripted decisions use the ordinary chapter API at unmodified simulation speed.
var capture_dir:=""
func check(label:String,condition:bool) -> void:
	super.check(label,condition)
	if not condition:push_error(label);quit(1)
func shot(label:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
	print("TOUR_PHASE ",label," ",JSON.stringify(scene.snapshot()))
func run() -> void:
	capture_dir=OS.get_environment("B2_CAPTURE_DIR");base=OS.get_environment("B2_SAVE_DIR")
	if capture_dir.is_empty() or base.is_empty():quit(2);return
	await fresh("shield");await frames(35);await shot("01-concourse-power-selected")
	await enter_assessment();await frames(35);await shot("02-threatened-collection")
	await fight();await frames(35);await shot("03-assessment-survived")
	await approach(PACKAGE);check("tour collect and learn",scene.interact());await frames(50);await shot("04-package-and-learning")
	check("tour assign doorway walk",scene.assign_walk());await frames(45);await shot("05-concourse-safe-walking");await settle()
	check("tour enter illustrated shelter",scene.interact() and scene.location=="shelter");await settled_party();await shot("06-shelter-arrival")
	await approach(REWARD);await frames(35);await shot("07-three-orientation-rewards")
	check("tour ordinary route reward",scene.choose_reward("opportunity"));await frames(45)
	await approach(RECRUIT);await frames(35);await shot("08-companion-choice")
	check("tour autonomous recruit joins",scene.join_recruit());await settled_party();await shot("09-three-actor-party")
	# Several directions around furnished geometry show walking, turning and stopping.
	await walk(Vector2i(10,2));await walk(Vector2i(10,4));await settled_party();await shot("10-shelter-party-around-furniture")
	await travel("concourse");await frames(30);await shot("11-party-through-doorway")
	var human_at:Vector2=scene.human.position
	check("tour physical pet fetch",scene.fetch_cache());await frames(65);await shot("12-pet-outbound")
	await settle();await settled_party();check("tour fetch returns with kit",scene.cache_taken and scene.kits==1 and scene.human.position==human_at)
	await shot("13-pet-return-and-cleared-concourse")
	await travel("shelter");await approach(RECRUIT)
	check("tour companion waits",scene.wait_recruit());await settled_party();await shot("14-waiting-companion")
	check("tour companion rejoins",scene.rejoin_recruit());await settled_party()
	await key(KEY_ESCAPE);await frames(45);await shot("15-stable-pause-save-and-quit")
	print("B2_VISIBLE_DISPLAY ",JSON.stringify({"window":DisplayServer.window_get_size(),"screen":DisplayServer.screen_get_size(),"scale":DisplayServer.screen_get_scale(),"renderer":RenderingServer.get_current_rendering_method(),"engine_time_scale":Engine.time_scale,"scripted_input":true,"synthetic_save_root":base}))
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	check("tour actual save and quit",scene.save_and_quit())
