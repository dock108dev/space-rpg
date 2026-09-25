extends SceneTree
var scene:Node2D
var out:String
var results:Array=[]
var checks:Array=[]
var after:bool
func check(label:String,passed:bool) -> void:
	checks.append({"label":label,"passed":passed})
	if not passed:push_error(label)
func button_named(label:String) -> Button:
	for child in scene.transcript.get_parent().get_children():
		if child is Button and child.text==label:return child
	return null
func _initialize() -> void:run.call_deferred()
func frames(n:int=6) -> void:
	for i in n:await process_frame
func shot(label:String) -> void:
	await frames();RenderingServer.force_draw()
	root.get_texture().get_image().save_png(out.path_join(label+".png"))
	if after:
		check(label+" outcome fits",scene.outcome.get_line_count()*scene.outcome.get_line_height()<=scene.outcome.size.y)
		check(label+" Stop stays in viewport",scene.stop_button.get_global_rect().end.y<=980)
		if label in ["home","large-result"]:check(label+" all home actions fit",scene.choices.size.y<=scene.choice_scroll.size.y)
		if label=="help":check("help fits without scrolling",scene.help_copy.get_content_height()<=scene.help_copy.size.y)
	results.append({"screen":label,"window":[root.size.x,root.size.y],"state":scene.snapshot(),"objective":scene.objective_now.text,"outcome":scene.outcome.text,"choice_count":scene.choices.get_child_count(),"choice_height":scene.choices.size.y,"choice_viewport":scene.choice_scroll.size.y})
func run() -> void:
	out=OS.get_environment("UI04_OUT");after=OS.get_environment("UI04_VARIANT")=="after"
	if out.is_empty():quit(2);return
	scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await frames()
	await shot("setup")
	if after:
		check("name field starts focused",scene.name_input.has_focus())
		var tab:=InputEventKey.new();tab.keycode=KEY_TAB;tab.physical_keycode=KEY_TAB;tab.pressed=true;Input.parse_input_event(tab);await frames()
		check("Tab reaches jacket choice",scene.appearance_choice.has_focus());scene.name_input.grab_focus()
		check("choose power disabled until trials",scene.buttons.choose_blast.disabled)
	# Deliberately empty namespace: exercise actual Continue failure.
	for child in scene.setup_panel.get_children():
		if child is Button and child.text.begins_with("Continue "):child.pressed.emit();break
	await shot("empty")
	scene.start_character("Mira Étoile","teal")
	var cases:Variant=JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("UI04_CASES")))
	for label in ["early","yard","home"]:
		var chosen:Dictionary={}
		for item in cases:
			var d:Dictionary=item.expected
			if label=="early" and d.journey=="arrival":chosen=d;break
			if label=="yard" and d.location=="objective" and not d.expedition.cleared and d.care.recruit=="healthy":chosen=d;break
			if label=="home" and d.location=="home" and d.expedition.reported:chosen=d;break
		if chosen.is_empty():push_error("Missing synthetic fixture "+label);quit(1);return
		scene.apply_snapshot(chosen);scene.save_store.directory=OS.get_environment("B8_SAVE_DIR").path_join(label);scene.character.name="Mira Étoile";scene.set_large_text(false,false);await frames()
		scene.say(scene.result_text() if label=="home" else scene.describe_place());await shot(label)
		if label=="home":
			scene.set_large_text(true,false);scene.refresh_choices();scene.say(scene.result_text());await shot("large-result")
			button_named("Help").pressed.emit();await shot("help")
			scene.help_panel.get_child(1).pressed.emit();await frames()
			if after:check("Help returns command focus",scene.command_input.has_focus() and not paused)
			button_named("History").pressed.emit();await shot("history");button_named("History").pressed.emit()
			if after:check("History toggles current outcome",scene.outcome.visible and not scene.transcript.visible)
			if after:
				var saved_care:Dictionary=scene.care.duplicate(true);scene.care.aid_actor="pet";scene.care.aid_steps=2;scene.refresh_ui()
				check("assisted care keeps immediate task heading", "Stay at the desk" in scene.status.text)
				scene.care=saved_care;scene.refresh_ui()
			if after:check("partial save warning retained", "Continue selection" in scene.readable_message("Manual save 3 stored. Chapter saved, but Continue selection could not update."))
			scene.save_store.directory=OS.get_environment("B8_SAVE_DIR").path_join("blocked");DirAccess.make_dir_recursive_absolute(scene.save_store.directory.path_join(".writing"));scene.save_and_quit();scene.toggle_pause();await shot("save-failure")
			if after:check("save failure has visible recovery",scene.pause_recover.is_visible_in_tree() and not scene.pause_recover.disabled and "not saved" in scene.pause_notice.text)
	var f:=FileAccess.open(out.path_join("screens.json"),FileAccess.WRITE);f.store_string(JSON.stringify(results,"  "));f.close()
	f=FileAccess.open(out.path_join("checks.json"),FileAccess.WRITE);f.store_string(JSON.stringify(checks,"  "));f.close()
	quit(0 if checks.all(func(c):return c.passed) else 1)
