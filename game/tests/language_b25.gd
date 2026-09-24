extends SceneTree
const Language=preload("res://scripts/adventure_language.gd")
func _initialize() -> void:
	var targets={"package":{"aliases":["package","parcel","amber box"]},"doorway":{"aliases":["door","doorway"]},"pet":{"aliases":["pet","animal"]},"cache":{"aliases":["cache","crate","supplies"]},"creature":{"aliases":["creature","enemy"]},"traveler":{"aliases":["traveler","companion"]}}
	var cases=[
		["Look around","look"],["survey the room","look"],["What can I do here?","question"],
		["Please head to the parcel","go"],["could you walk to the doorway","go"],["I want to approach the amber box","go"],
		["move 5 up and 8 right","step"],["walk five north and eight east","step"],["step right 2 steps","step"],
		["inspect that","inspect"],["examine the supplies","inspect"],["look at it","inspect"],
		["go to the door, then enter shelter","go"],["go to doorway and enter shelter","go"],["go to package and interact with package","go"],["go to package and dance","error"],
		["ask the pet to fetch it","fetch"],["have the companion wait here","wait"],["invite the traveler","join"],
		["What would happen if I used the shield?","question"],["stop","control"],["never mind","control"],
		["actually, go to package","go"],["instead inspect the parcel","inspect"],
		["select shield","choose"],["show me dash","preview"],["raise shield","power"],["fire blast at creature","power"],
		["shoot enemy","bolt"],["finish my turn","end"],["take the field lamp","reward"],["save and quit","quit"],
		["go to package or doorway","error"],["go to cart","error"],["don't enter shelter","error"],
		["go to doorway, then fly into orbit","error"],["shoot pet","error"],["use blast on pet","error"],["use blast on cart","error"],["raise shield on companion","error"],["have pet wait here","error"],["ask companion to fetch cache","error"],
		["move 999 right","error"],["give me unlimited kits","error"],["what if I shoot pet?","question"],
		["stroll over to the crate","error"],["get me somewhere less depressing","error"]]
	var results:Array=[];var memory_before:=OS.get_static_memory_usage();var all_ok:=true
	for item in cases:
		var start:=Time.get_ticks_usec()
		var result:=Language.interpret(item[0],targets,"cache")
		var elapsed:=Time.get_ticks_usec()-start
		var classification:String="error" if result.has("error") else "question" if result.has("question") else "control" if result.has("control") else result.actions[0].verb
		var ok:bool=classification==item[1]
		if item[0] in ["go to the door, then enter shelter","go to doorway and enter shelter","go to package and interact with package"]:ok=ok and result.get("actions",[]).size()==2
		all_ok=all_ok and ok
		results.append({"request":item[0],"expected":item[1],"actual":classification,"passed":ok,"microseconds":elapsed,"proposal":result})
		print("PASS " if ok else "FAIL ",item[0])
	var f:=FileAccess.open(OS.get_environment("B25_SAVE_DIR").path_join("language-results.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify({"backend":"deterministic GDScript grammar","cases":results,"static_memory_delta_bytes":OS.get_static_memory_usage()-memory_before,"scope":"parser plus retained result allocations; not process RSS or model memory","local_model_run":false},"  "));f.close()
	quit(0 if all_ok else 1)
