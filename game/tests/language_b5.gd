extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/owned_home.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
	# Interpretation-only synthetic context, not a gameplay award.
	scene.location="home";scene.home.owned=true
	var failures:=0
	for request in ["How do I get a home?","Go home.","Enter my home.","What can I furnish?","How much does that cost?","Place the Reading chair by the window.","Move Task lamp by the far wall","Improve the storage.","What changed?","Return to the hub.","Stop.","buy keepsake shelf","store reading chair","deposit 3 material","withdraw 2 material","actually, place chair by the alcove","go to locker then improve storage","move 2 left","inspect shelf"]:
		var before:Dictionary=scene.home.duplicate(true)
		var result:Dictionary=scene.interpret_request(request)
		if result.has("error") or scene.home!=before:print("FAIL ",request," ",result);failures+=1
		else:print("PASS interpretation ",request)
	for request in ["move the furnishing over there","move chair over there","place chair by the doorway","buy chair or lamp","place lamp by window or alcove","deposit -2","withdraw everything","don't buy chair","buy a spaceship"]:
		if not scene.interpret_request(request).has("error"):print("FAIL refusal ",request);failures+=1
		else:print("PASS clarification ",request)
	quit(0 if failures==0 else 1)
