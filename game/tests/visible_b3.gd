extends "res://tests/run_b3.gd"
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
	base=OS.get_environment("B3_SAVE_DIR");capture_dir=OS.get_environment("B3_CAPTURE_DIR")
	await opening("joined");await shot("01-hub")
	await command("inspect board");await frames(90)
	await command("inspect supplies");await shot("02-supply-choice")
	await command("ask pet to fetch supplies");await shot("03-delivery")
	await command("go to access then restore access panel");await shot("04-shortcut")
	await command("go to approach then inspect marker");await shot("05-approach")
	await command("go to marker then survey the approach");await frames(90);await shot("06-survey")
	await command("go to hub then go to shelter")
	await command("go to traveler then have traveler wait here")
	await command("go to hub then go to approach");await shot("07-waiting-party")
	await command("go to hub then go to shelter")
	await command("go to traveler then rejoin traveler")
	await command("what work is unfinished?");await shot("08-return")
	await frames(120)
	var expected:Dictionary=scene.snapshot()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":expected}]));f.close()
	print("TOUR_FINAL ",JSON.stringify(expected))
	check("tour actual save and quit",scene.save_and_quit())
