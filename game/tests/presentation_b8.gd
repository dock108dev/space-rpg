extends SceneTree
var scene:Node2D
var out:=""
var variant:=""
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in range(n):await process_frame
func shot(label:String) -> void:
	print("SHOT_BEGIN ",label)
	await frames(8);RenderingServer.force_draw()
	root.get_texture().get_image().save_png(out.path_join(variant+"-"+label+".png"))
func run() -> void:
	out=OS.get_environment("B8_PRESENTATION_DIR");variant=OS.get_environment("B8_PRESENTATION_VARIANT")
	scene=load("res://scenes/player_experience.tscn" if variant=="after" else "res://scenes/expedition.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames(3)
	if variant=="after":
		scene.name_input.text="Étoile 星 "+"long name ".repeat(5);scene.appearance_choice.select(2);scene.appearance_choice.item_selected.emit(2);await shot("setup")
		scene.start_character(scene.name_input.text,"plum")
	var cases:Variant=JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("B8_PRESENTATION_CASES")))
	var selected:Array=[]
	for spec in [["early",0],["yard",1],["downed",2],["home",4]]:
		print("CASE_BEGIN ",spec[0])
		var chosen:Dictionary={}
		for item in cases:
			var d:Dictionary=item.expected
			if spec[0]=="early" and d.journey=="arrival":chosen=d;break
			if spec[0]=="yard" and d.location=="objective" and not d.expedition.cleared and d.care.recruit=="healthy":chosen=d;break
			if spec[0]=="downed" and d.location=="objective" and d.care.recruit=="downed":chosen=d;break
			if spec[0]=="home" and d.location=="home" and d.expedition.reported:chosen=d;break
		if chosen.is_empty():push_error("Missing presentation fixture "+str(spec[0]));quit(1);return
		scene.apply_snapshot(chosen);scene.save_store.directory=out.path_join("synthetic-"+variant+"-"+spec[0]);await frames(3)
		if variant=="after":scene.character.name=scene.ExperienceSave.clean_name("Étoile 星 "+"Long".repeat(6));scene.set_large_text(false)
		scene.say(scene.result_text() if spec[0]=="home" else scene.describe_place());await shot(spec[0])
		if spec[0]=="early":
			scene.submit("move 2 right then move 2 left");await frames(30);await shot("moving");await frames(8)
		if spec[0]=="downed":
			scene.submit("retreat");await frames(40);await shot("rescue");await frames(8)
		if spec[0]=="home" and variant=="after":
			scene.set_large_text(true);scene.refresh_choices();scene.say(scene.result_text());await shot("large-result")
			scene.submit("inventory");await frames(5);await shot("inventory")
			scene.show_help();await shot("help");scene.toggle_pause()
			scene.history_open=true;scene.update_reading();await shot("history")
			scene.history_open=false;scene.update_reading();scene.toggle_pause();await shot("pause");scene.toggle_pause()
			scene.save_store.directory=out.path_join("blocked-save");DirAccess.make_dir_recursive_absolute(scene.save_store.directory.path_join(".writing"));scene.save_and_quit();await shot("save-failure")
	var f:=FileAccess.open(out.path_join(variant+"-result.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify({"variant":variant,"synthetic_matched_states":true,"window":[root.size.x,root.size.y],"time_scale":Engine.time_scale,"current_scene":scene.scene_file_path}));f.close()
	quit()
