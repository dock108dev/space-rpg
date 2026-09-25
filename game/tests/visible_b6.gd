extends "res://tests/run_b6.gd"
var capture_dir:=""
func check(label:String,value:bool) -> void:
	super.check(label,value)
	if not value:push_error(label);quit(1)
func command(text:String) -> void:
	scene.command_input.text=text;await frames(18)
	scene.command_input.text_submitted.emit(text);await frames(2);await settle();await frames(25)
func shot(label:String) -> void:
	await frames(75);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
	print("TOUR_PHASE ",label," ",JSON.stringify(scene.snapshot()))
func run() -> void:
	base=OS.get_environment("B6_SAVE_DIR");capture_dir=OS.get_environment("B6_CAPTURE_DIR")
	await prepare("joined");await shot("01-earned-training")
	await command("go to breach");await frames(120);await command("enter breach");await shot("02-real-danger")
	await command("guard then end turn");check("movie pet injury and cover",scene.care.pet=="injured" and scene.care.cover);await shot("03-support-and-injury")
	await command("guard then end turn");check("movie traveler downed",scene.care.recruit=="downed");await shot("04-recoverable-downing")
	await command("retreat");await shot("05-party-return")
	await command("ask pet to fetch supplies");check("movie impaired refusal",scene.care.pet=="injured");await shot("06-impaired-fetch")
	await command("go to shelter then go to desk then what does treatment cost?");await shot("07-care-terms")
	await command("treat the pet then help the companion recover");check("movie paid accounting",scene.progression.material==16 and scene.care.paid==2);await shot("08-restored-party")
	await command("rest then go to hub then go to approach then go to breach");await frames(90);await command("enter breach then guard then end turn")
	# Entry stops future clauses for a new dangerous decision.
	await command("guard then end turn");check("movie restored cover used",scene.care.cover);await shot("09-restored-capability")
	await command("retreat then go to shelter then go to desk")
	# Retreat also stops future clauses; resolve travel separately.
	await command("go to shelter then go to desk")
	await command("begin assisted pet care then continue assisted care then continue assisted care");check("movie assisted recovery",scene.care.pet=="healthy");await shot("10-assisted-care")
	await frames(120);await command("save");await shot("11-saved")
	var expected:Dictionary=scene.save_store.latest()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":expected}]));f.close()
	print("TOUR_FINAL ",JSON.stringify(expected));check("tour actual save and quit",scene.save_and_quit())
