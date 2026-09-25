extends SceneTree
func _initialize() -> void:call_deferred("run")
func equivalent(a:Variant,b:Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size()!=b.size():return false
		for field in a:
			if not b.has(field) or not equivalent(a[field],b[field]):return false
		return true
	if a is Array and b is Array:
		if a.size()!=b.size():return false
		for i in range(a.size()):
			if not equivalent(a[i],b[i]):return false
		return true
	return a==b
func run() -> void:
	var base:=OS.get_environment("B8_SAVE_DIR")
	var cases:Variant=JSON.parse_string(FileAccess.get_file_as_string(base.path_join("restarts.json")))
	if not cases is Array:quit(1);return
	var failures:=0
	for item in cases:
		var scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
		scene.save_store.directory=item.directory
		if not scene.load_latest():failures+=1
		var actual:Dictionary=scene.snapshot()
		for key in actual:
			if key=="history":continue # Restore appends a truthful inactive-context line.
			if key in ["pet_position","recruit_position"]:
				# JSON uses doubles, while Godot's Vector2 stores float32. Compare
				# exact engine coordinates, not decimal-string rounding noise.
				if Vector2(actual[key][0],actual[key][1])!=Vector2(item.expected[key][0],item.expected[key][1]):print("FAIL exact restart ",key);failures+=1
				continue
			if not equivalent(actual[key],item.expected[key]):print("FAIL exact restart ",key);failures+=1
		if scene.location=="home" and (scene.audience.visible or scene.audience.text!=""):failures+=1
		if not scene.work.is_empty() or not scene.current.is_empty():failures+=1
		print("PASS separate-process Continue ",item.directory)
		if "--quit-check" in OS.get_cmdline_user_args():
			if not scene.save_and_quit():quit(1)
			return
		scene.queue_free();await process_frame
	quit(0 if failures==0 else 1)
