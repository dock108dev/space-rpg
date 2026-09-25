extends "res://tests/run_b4.gd"
var capture_dir:=""
func check(label:String,value:bool) -> void:
	super.check(label,value)
	if not value:push_error(label);quit(1)
func command(text:String) -> void:
	scene.command_input.text=text;await frames(18)
	scene.command_input.text_submitted.emit(text)
	await frames(2);await settle();await frames(20)
func shot(label:String) -> void:
	await frames(75)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label+".png"))
	print("TOUR_PHASE ",label," ",JSON.stringify(scene.snapshot()))
func run() -> void:
	base=OS.get_environment("B4_SAVE_DIR");capture_dir=OS.get_environment("B4_CAPTURE_DIR")
	await opening("joined")
	await command("go to bench then inspect bench");await shot("01-bench")
	await command("claim preparation kit then compare equipment");await shot("02-kit")
	await command("inspect focus lens");await shot("03-cost-effect")
	await command("equip focus lens then go to approach then go to range then test power");await shot("04-base-effect")
	await command("go to hub then go to bench then improve lens then improve my blast");await shot("05-spent-eight")
	await command("go to approach then go to range then test power");await shot("06-improved-effect")
	await command("go to hub then ask pet to fetch supplies then go to bench then exchange supply bundle");await shot("07-exchange")
	await command("go to shelter then go to desk then rest")
	await command("go to hub then go to approach then go to range");await frames(120)
	await command("save")
	var expected:Dictionary=scene.save_store.latest()
	var f:=FileAccess.open(base.path_join("restarts.json"),FileAccess.WRITE);f.store_string(JSON.stringify([{"directory":scene.save_store.directory,"expected":expected}]));f.close()
	print("TOUR_FINAL ",JSON.stringify(expected))
	check("tour actual save and quit",scene.save_and_quit())
