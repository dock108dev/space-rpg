extends "res://tests/run_b5.gd"
var capture_dir:=""
func check(label:String,value:bool) -> void:
	super.check(label,value)
	if not value:push_error(label);quit(1)
func command(text:String) -> void:
	scene.command_input.text=text;await frames(18)
	scene.command_input.text_submitted.emit(text);await frames(2);await settle();await frames(20)
func shot(label:String) -> void:
	await frames(75);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
	print("TOUR_PHASE ",label," ",JSON.stringify(scene.snapshot()))
func run() -> void:
	base=OS.get_environment("B5_SAVE_DIR");capture_dir=OS.get_environment("B5_CAPTURE_DIR")
	await opening("joined")
	await command("How do I get a home?");await shot("01-ownership-terms")
	await command("go to bench then claim preparation kit")
	await command("go to approach then go to range then test power then go to hub then go to bench then improve lens then improve weave then improve rig then improve my blast")
	await command("go to board then file settlement claim");await shot("02-deed-and-ten")
	await command("go home");await shot("03-private-interior")
	await command("buy reading chair then place reading chair by the window")
	await command("buy task lamp then place task lamp by the alcove")
	await command("buy keepsake shelf then place keepsake shelf by the far wall");await shot("04-furnished")
	await command("move reading chair by the reading nook");await shot("05-rearranged")
	await command("go to locker then improve storage then deposit 3 material then withdraw 1 material");await shot("06-functional-storage")
	await command("rest then return to the hub");await shot("07-public-again")
	await command("go home then go to locker");await frames(120);await command("save");await shot("08-returned")
	var expected:Dictionary=scene.save_store.latest()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":expected}]));f.close()
	print("TOUR_FINAL ",JSON.stringify(expected));check("tour actual save and quit",scene.save_and_quit())
