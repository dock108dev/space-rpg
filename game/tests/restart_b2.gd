extends SceneTree
# Real process restart; compares every gameplay field, including exact party positions.
var checks:Array[Dictionary]=[]
func _initialize() -> void:call_deferred("run")
func check(label:String,condition:bool) -> void:
	checks.append({"name":label,"passed":condition});print("PASS " if condition else "FAIL ",label)
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
	var base:=OS.get_environment("B2_SAVE_DIR")
	var expected:Variant=JSON.parse_string(FileAccess.get_file_as_string(base.path_join("restart.json")))
	if not expected is Array or expected.size()!=3:push_error("Missing three ordinary B2 journey states");quit(2);return
	var actual_quit:=OS.get_cmdline_user_args().has("--quit-check")
	for item in expected:
		var scene:Node2D=load("res://scenes/chapter_opening.tscn").instantiate()
		scene.auto_focus_pause=false;root.add_child(scene);await process_frame
		scene.save_store.directory=base.path_join(item.folder)
		var loaded:bool=scene.load_latest()
		check("new-process exact Continue "+item.label,loaded and equivalent(scene.snapshot(),item.state))
		check("new-process complete two-place result",scene.location=="shelter" and scene.journey=="complete" and scene.enemy_hp==0 and scene.learned and scene.cache_taken)
		var before:Dictionary=scene.snapshot()
		check("new-process no duplicate reward/cache",not scene.choose_reward("security") and not scene.fetch_cache() and equivalent(scene.snapshot(),before))
		print("RESTART_STATE ",item.label," ",JSON.stringify(scene.snapshot()))
		if actual_quit:
			scene.toggle_pause()
			check("stable pause accepts ordinary Save and quit",scene.save_and_quit())
			print("ACTUAL_SAVE_AND_QUIT_REQUESTED ",scene.quit_requested)
			return
		scene.queue_free();await process_frame
	var failed:=0
	for item in checks:
		if not item.passed:failed+=1
	print("B2 FULL PROCESS RESTART ",checks.size()," checks; ",failed," failed")
	quit(0 if failed==0 else 1)
