extends SceneTree
const Save=preload("res://scripts/tactical_save.gd")
const Chapter=preload("res://scripts/chapter_save.gd")
const Language=preload("res://scripts/adventure_language.gd")
var failures:=0
var count:=0
func check(label:String,ok:bool) -> void:
	count+=1
	if not ok:failures+=1
	print(("PASS " if ok else "FAIL ")+label)
func put(path:String,value:String) -> void:
	var f:=FileAccess.open(path,FileAccess.WRITE);f.store_string(value);f.close()
func link(target:String,path:String) -> void:
	var output:Array=[]
	check("synthetic link created",OS.execute("/bin/ln",PackedStringArray(["-s",target,path]),output,true)==0)
func _initialize() -> void:run.call_deferred()
func run() -> void:
	var base:=OS.get_environment("M2_SAVE_DIR")
	if base.is_empty():quit(2);return
	DirAccess.make_dir_recursive_absolute(base)
	var regular:=Save.new(base.path_join("regular"))
	var state:={"power":"blast","player":[2,5],"enemy":[8,3],"aim":[8,3],"hp":6,"enemy_hp":6,"ap":4,"shield":0,"prepared":false,"used":false,"turn":1,"phase":"player"}
	check("ordinary snapshot still writes",regular.write(state,"manual"))
	var original:=FileAccess.get_file_as_bytes(regular.directory.path_join("snapshot-000000001.json"))
	link(regular.directory,base.path_join("session-linked"))
	var linked:=Save.new(base.path_join("session-linked"))
	check("linked session cannot load",linked.latest().is_empty() and not linked.scan_ok)
	check("linked session cannot write",not linked.write(state,"auto"))
	check("chapter writer rejects linked session",not Chapter.new(linked.directory).write(state,"auto"))
	check("recovery rejects linked session",not Chapter.new(linked.directory).recover_writer())
	var imported:=Save.new(base.path_join("imported"));DirAccess.make_dir_recursive_absolute(imported.directory)
	link(regular.directory.path_join("snapshot-000000001.json"),imported.directory.path_join("snapshot-000000001.json"))
	check("linked snapshot skipped with notice",imported.latest().is_empty() and "Skipped 1" in imported.notice)
	check("outside snapshot bytes unchanged",FileAccess.get_file_as_bytes(regular.directory.path_join("snapshot-000000001.json"))==original)
	var recovery:=Chapter.new(base.path_join("recovery"));DirAccess.make_dir_recursive_absolute(recovery.directory)
	link(regular.directory,recovery.directory.path_join(".writing"))
	check("linked lock not inspected or reclaimed",not recovery.recover_writer())
	var scene=load("res://scenes/player_experience.tscn").instantiate();get_root().add_child(scene);await process_frame
	check("oversized optional preferences fall back",not scene.text_large)
	var sentinel:=base.path_join("outside.txt");put(sentinel,"PRIVATE SYNTHETIC SENTINEL")
	var cfg:String=scene.session_root.path_join("presentation.cfg");DirAccess.remove_absolute(cfg);link(sentinel,cfg)
	scene.set_large_text(true)
	check("linked preference target remains unchanged",FileAccess.get_file_as_string(sentinel)=="PRIVATE SYNTHETIC SENTINEL")
	check("linked preference failure visible",scene.text_large and "could not be saved" in scene.last_outcome)
	link(sentinel,scene.session_root.path_join("current-session.txt"))
	scene.read_session_slot()
	check("linked selector refused",not scene.session_pointer_notice.is_empty() and not scene.load_latest())
	check("bounded input parser rejects oversized text",Language.interpret("a".repeat(1001),{}).has("error"))
	check("128-step boundary accepted",Language.interpret("move 64 up and 64 down",{}).actions.size()==128)
	check("129 steps rejected before queue allocation",Language.interpret("move 64 up and 64 down and 1 right",{}).has("error"))
	check("joined clauses share action cap",Language.interpret("move 64 up then move 64 down then move 1 right",{}).has("error"))
	scene.start_character("Synthetic","amber")
	var epoch:int=scene.epoch;var seen:int=scene.seen.size();var snapshot:Dictionary=scene.snapshot()
	check("oversized request rejected",not scene.submit("actually "+"a".repeat(1001)))
	check("rejected input has no gameplay or queue effect",scene.work.is_empty() and scene.epoch==epoch and scene.seen.size()==seen and scene.snapshot().player==snapshot.player)
	scene.queue_free();await process_frame
	print("M2 checks=%d failures=%d" % [count,failures]);quit(1 if failures else 0)
