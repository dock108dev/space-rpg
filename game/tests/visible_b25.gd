extends "res://tests/run_b25.gd"
var capture_dir:=""
func check(label:String,value:bool) -> void:
	super.check(label,value)
	if not value:push_error(label);quit(1)
func command(text:String) -> void:
	scene.command_input.text=text
	await frames(18)
	scene.command_input.text_submitted.emit(text)
	await frames(2);await settle();await frames(15)
func shot(label:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
	print("TOUR_PHASE ",label," ",JSON.stringify(scene.snapshot()))
func run() -> void:
	capture_dir=OS.get_environment("B25_CAPTURE_DIR")
	await fresh("blast");await shot("01-command-previews")
	await command("What would happen if I used shield?")
	scene.submit("go to doorway");await frames(25);scene.stop_button.pressed.emit();await settle();await frames(30);await shot("02-interrupted-walk")
	await command("go to package and interact with package")
	await shot("03-assessment")
	await fight();await command("go to package, then collect package")
	await command("go to doorway, then enter shelter");await shot("04-shelter")
	await command("go to desk")
	# Real contextual choice button, bound to the current scene epoch.
	for button in scene.choices.get_children():
		if button.text=="Field lamp":button.pressed.emit();break
	await frames(2);await settle();check("tour contextual reward",scene.reward=="equipment")
	await command("go to traveler, then join traveler")
	await command("go to doorway, then leave shelter")
	await command("inspect cache");await shot("05-two-approaches")
	await command("ask the pet to fetch it")
	check("tour physical cache delivery",scene.cache_taken and scene.retrieval=="pet")
	await shot("06-pet-delivery")
	await command("go to doorway, then enter shelter")
	await command("go to traveler, then talk to traveler");await frames(60);await shot("07-consequence")
	await frames(150)
	print("TOUR_FINAL ",JSON.stringify(scene.snapshot()))
	check("tour actual save and quit",scene.save_and_quit())
