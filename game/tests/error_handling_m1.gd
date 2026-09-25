extends SceneTree
const Save=preload("res://scripts/tactical_save.gd")
const ChapterSave=preload("res://scripts/chapter_save.gd")
class ProbeFailure extends "res://scripts/chapter_save.gd":
	func probe_writer(_pid:int,_output:Array) -> int:return -1
class CleanupFailure extends "res://scripts/chapter_save.gd":
	func write_locked(_state:Dictionary,_kind:String) -> bool:
		var extra:=FileAccess.open(directory.path_join(".writing/retained"),FileAccess.WRITE)
		extra.store_string("synthetic");extra.close()
		notice="Snapshot committed (injected)."
		return true
var failures:=0
var count:=0
func check(label:String,ok:bool) -> void:
	count+=1
	if not ok:failures+=1
	print(("PASS " if ok else "FAIL ")+label)
func put(path:String,value:String) -> void:
	var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(value);file.close()
func _initialize() -> void:run.call_deferred()
func run() -> void:
	var root:=OS.get_environment("M1_SAVE_DIR")
	if root.is_empty():quit(2);return
	DirAccess.make_dir_recursive_absolute(root)
	var store:=Save.new(root.path_join("snapshots"))
	check("missing namespace is ordinary first use",store.latest().is_empty() and store.scan_ok)
	var state:={"power":"blast","player":[2,5],"enemy":[8,3],"aim":[8,3],"hp":6,"enemy_hp":6,"ap":4,"shield":0,"prepared":false,"used":false,"turn":1,"phase":"player"}
	check("immutable save commits",store.write(state,"manual"))
	put(store.directory.path_join("snapshot-000000002.tmp"),"interrupted")
	put(store.directory.path_join("snapshot-000000003.json"),"{")
	check("valid fallback with visible skipped count",store.latest().sequence==1 and "Skipped 2" in store.notice)
	check("retry reserves malformed and interrupted sequence",store.write(state,"manual") and store.latest().sequence==4)
	DirAccess.make_dir_absolute(store.directory.path_join("snapshot-000000005.tmp"))
	check("snapshot-shaped directories reserve sequence",store.write(state,"auto") and store.latest().sequence==6)
	put(root.path_join("blocked"),"synthetic path obstruction")
	var blocked:=Save.new(root.path_join("blocked"))
	check("unreadable namespace is explicit",blocked.latest().is_empty() and not blocked.scan_ok and "cannot inspect" in blocked.notice)
	check("path obstruction refuses write",not blocked.write(state,"auto"))
	var recovery:=ChapterSave.new(root.path_join("recovery"))
	DirAccess.make_dir_recursive_absolute(recovery.directory.path_join(".writing"))
	var marker:=recovery.directory.path_join(".writing/owner.json")
	put(marker,"{")
	check("partial fresh marker cannot be stolen",not recovery.recover_writer() and FileAccess.file_exists(marker))
	put(marker,JSON.stringify({"pid":OS.get_process_id()}))
	check("live writer cannot be stolen",not recovery.recover_writer())
	put(marker,JSON.stringify({"pid":2147483647}))
	var unknown:=ProbeFailure.new(recovery.directory)
	check("probe launch failure retains lock",not unknown.recover_writer() and FileAccess.file_exists(marker) and "could not establish" in unknown.notice)
	check("probe error is unknown",recovery.classify_writer_probe(2,[],42)==-1)
	check("probe error text is unknown",recovery.classify_writer_probe(0,["unexpected"],42)==-1)
	check("successful process inventory establishes absence",recovery.classify_writer_probe(0,["1\n2"],42)==1)
	check("known stale writer archived",recovery.recover_writer() and not DirAccess.dir_exists_absolute(recovery.directory.path_join(".writing")))
	var cleanup:=CleanupFailure.new(root.path_join("cleanup"))
	check("cleanup failure never reverses committed status",cleanup.write({},"auto") and "cleanup failed" in cleanup.notice)
	check("cleanup debris preserved",FileAccess.file_exists(cleanup.directory.path_join(".writing/retained")))
	var scene=load("res://scenes/player_experience.tscn").instantiate()
	get_root().add_child(scene)
	await process_frame
	DirAccess.make_dir_recursive_absolute(scene.session_root)
	put(scene.session_root.path_join("current-session.txt"),"../wrong-character")
	scene.read_session_slot()
	check("invalid Continue selector blocks implicit fallback",not scene.load_latest() and "selection" in scene.save_store.notice)
	put(scene.session_root.path_join("current-session.txt"),"session-synthetic")
	check("valid selector clears prior failure",scene.read_session_slot()=="session-synthetic" and scene.session_pointer_notice.is_empty())
	scene.session_root=root.path_join("blocked")
	scene.set_large_text(true)
	check("preference failure remains usable and visible",scene.text_large and "could not be saved" in scene.last_outcome)
	scene.queue_free();await process_frame
	print("M1 checks=%d failures=%d" % [count,failures]);quit(1 if failures else 0)
