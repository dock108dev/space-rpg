extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var base:=OS.get_environment("S04_SAVE_DIR")
	var f:=FileAccess.open(base.path_join("restart.json"),FileAccess.READ);var expected:Dictionary=JSON.parse_string(f.get_as_text());f.close()
	var scene:Node2D=load("res://scenes/integrated_loop.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame;scene.save_store.directory=base.path_join(str(expected.folder).get_file())
	var loaded:bool=scene.load_latest()
	print("RESTART_COMPARISON ", loaded, " ACTUAL ",JSON.stringify(scene.snapshot())," EXPECTED ",JSON.stringify(expected.state))
	var ok:bool=loaded and equivalent(scene.snapshot(),expected.state) and scene.learned and scene.cache_taken and scene.reward=="opportunity"
	ok=ok and not scene.choose_reward("security") and not scene.fetch_cache()
	print("FULL_PROCESS_RESTART ","PASS" if ok else "FAIL"," ",JSON.stringify(scene.snapshot()))
	scene.queue_free();await process_frame;quit(0 if ok else 1)

func equivalent(a:Variant,b:Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size()!=b.size():return false
		for key in a:
			if not b.has(key) or not equivalent(a[key],b[key]):return false
		return true
	if a is Array and b is Array:
		if a.size()!=b.size():return false
		for i in range(a.size()):
			if not equivalent(a[i],b[i]):return false
		return true
	return a==b
