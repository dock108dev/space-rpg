extends SceneTree
const Experience=preload("res://scripts/experience_save.gd")
const ExpeditionSave=preload("res://scripts/expedition_save.gd")
class PlayerProbe extends "res://scripts/player_experience.gd":
	var factory_calls:=0
	func create_save_store() -> RefCounted:
		factory_calls+=1
		return super.create_save_store()
var failures:=0
var checks:Array=[]
func check(label:String,ok:bool) -> void:
	checks.append({"label":label,"passed":ok})
	if not ok:failures+=1
	print(("PASS " if ok else "FAIL ")+label)
func _initialize() -> void:run.call_deferred()
func run() -> void:
	check("source project starts current player scene",ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/player_experience.tscn")
	var player:=PlayerProbe.new();player.auto_focus_pause=false;root.add_child(player);await process_frame
	check("one most-derived save factory invocation",player.factory_calls==1)
	check("current player uses experience schema",player.save_store.get_script()==Experience)
	check("current namespace excludes inherited roots",player.session_root==OS.get_environment("B8_SAVE_DIR") and player.save_store.directory==player.session_root.path_join("session-default"))
	check("current logical layout remains 1280 by 980",root.content_scale_size==Vector2i(1280,980))
	check("setup remains ready",player.setup_open and player.experience_ready and player.name_input.has_focus())
	var state:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("M3_FIXTURE")))
	var original:String=JSON.stringify(state)
	check("expedition validator accepts decoded unopened state",ExpeditionSave.new().valid(state))
	check("character validator delegates same decoded state",Experience.new().valid(state))
	check("validation does not mutate caller state",JSON.stringify(state)==original)
	for value in [0.5,true,-1,13]:
		var bad:Dictionary=state.duplicate(true);bad.expedition.warden=value
		check("both schemas reject invalid warden "+str(value),not ExpeditionSave.new().valid(bad) and not Experience.new().valid(bad))
	var bad:Dictionary=state.duplicate(true);bad.expedition.round=1
	check("unopened expedition must match initial policy",not ExpeditionSave.new().valid(bad) and not Experience.new().valid(bad))
	player.apply_snapshot(state)
	check("current manual save uses authoritative schema",player.manual_save())
	check("current save round trip",not player.save_store.latest().is_empty())
	player.queue_free();await process_frame
	# These explicit historical scenes remain callable review/regression surfaces.
	for spec in [["chapter_opening","chapter_save","B2"],["command_adventure","adventure_save","B25"],["connected_world","world_save","B3"],["preparation","preparation_save","B4"],["owned_home","home_save","B5"],["companions_care","care_save","B6"],["expedition","expedition_save","B7"]]:
		var scene=load("res://scripts/"+spec[0]+".gd").new();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
		check(spec[0]+" selects only its declared store",scene.save_store.get_script()==load("res://scripts/"+spec[1]+".gd") and scene.save_store.directory==OS.get_environment(spec[2]+"_SAVE_DIR"))
		check(spec[0]+" retains its logical canvas",root.content_scale_size==Vector2i(1280,720 if spec[2]=="B2" else 980))
		scene.queue_free();await process_frame
	for name in ["sample_controller","tactical_encounter","integrated_loop"]:
		var scene=load("res://scripts/"+name+".gd").new();root.add_child(scene);await process_frame
		check(name+" explicit historical canvas",root.content_scale_size==Vector2i(1280,720))
		scene.queue_free();await process_frame
	var file:=FileAccess.open(OS.get_environment("M3_CHECKS"),FileAccess.WRITE);file.store_string(JSON.stringify(checks,"  "));file.close()
	quit(1 if failures else 0)
