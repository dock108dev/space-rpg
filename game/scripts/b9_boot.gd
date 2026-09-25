extends Node
# Release templates do not expose --script. Only an explicit diagnostic argument
# plus a disposable save override can select these retained engineering runners.
func _ready() -> void:
	var selected:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--b9-check="):selected=arg.trim_prefix("--b9-check=")
	if selected.is_empty():
		start_game.call_deferred()
		return
	var allowed:={"branches":"run_b8","restart":"restart_b8","sessions":"ergonomics_b8","tour":"visible_b9","tour-restart":"visible_restart_b9","platform":"platform_b9","presentation":"presentation_b8","interface":"capture_ui05","security":"security_m2","errors":"error_handling_m1"}
	var save_root:=OS.get_environment("B9_SAVE_DIR")
	if not allowed.has(selected) or not save_root.is_absolute_path() or save_root.is_empty():
		push_error("B9 diagnostic requires a named check and explicit disposable B9_SAVE_DIR.");get_tree().quit(2);return
	var script=load("res://diagnostics/"+allowed[selected]+".gd")
	if not script is Script or not script.can_instantiate():
		push_error("B9_STARTUP_FAILED diagnostic resource unavailable");get_tree().quit(2);return
	var harness=script.new()
	harness.process_mode=Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(harness)

func start_game() -> void:
	var error:=get_tree().change_scene_to_file("res://scenes/player_experience.tscn")
	if error!=OK:
		push_error("B9_STARTUP_FAILED scene code=%d" % error)
		get_tree().quit(2)
