extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/companions_care.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
	var cases:={"Teach the pet cover fetch.":"train","Enter breach":"enter","Retreat":"retreat","Call evacuation":"evacuate","Treat the pet":"pet","Help the companion recover":"recruit","Begin assisted pet care":"aid_pet","Begin assisted companion care":"aid_recruit","Continue assisted care":"aid_round","Cancel assistance":"aid_cancel","Guard":"guard"}
	var failures:=0
	for text in cases:
		var result:Dictionary=scene.interpret_request(text)
		var ok:bool=result.has("actions") and result.actions[0].get("operation","")==cases[text]
		print("PASS " if ok else "FAIL ",text);failures+=0 if ok else 1
	for text in ["How is the pet?","What can my companion do?","What does treatment cost?","What would treatment do?"]:
		var ok:bool=scene.interpret_request(text).has("question");print("PASS " if ok else "FAIL ",text);failures+=0 if ok else 1
	for text in ["treat them","teach the pet"]:
		var ok:bool=scene.interpret_request(text).has("error");print("PASS " if ok else "FAIL ",text);failures+=0 if ok else 1
	for text in ["Stop","Have the companion wait"]:
		var result:Dictionary=scene.interpret_request(text)
		var ok:bool=result.get("control","")=="stop" if text=="Stop" else result.has("actions") and result.actions[0].verb=="wait"
		print("PASS " if ok else "FAIL ",text);failures+=0 if ok else 1
	var plan:Dictionary=scene.interpret_request("go to shelter then go to desk then what does treatment cost?")
	var deferred:bool=plan.has("actions") and plan.actions.size()==3 and plan.actions[2].verb=="deferred"
	print("PASS " if deferred else "FAIL ","travel then question remains three clauses");failures+=0 if deferred else 1
	quit(0 if failures==0 else 1)
