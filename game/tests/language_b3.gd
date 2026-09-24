extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/connected_world.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
	# Explicit interpretation-only context fixture, never counted as gameplay.
	scene.location="hub"
	var failures:=0
	for text in ["go to the approach","please head to shelter","inspect the access panel","go to access then restore access","recover supplies","ask pet to fetch supplies","skip supplies","decline access","resume access","what work is unfinished?","move 5 up and 8 right","go to approach then inspect marker","actually, inspect board"]:
		var result:Dictionary=scene.interpret_request(text)
		if result.has("error"):print("FAIL ",text," ",result);failures+=1
		else:print("PASS interpretation ",text)
	for text in ["go to concourse","go to home","go to doorway","build a spaceship","don't collect supplies"]:
		if not scene.interpret_request(text).has("error"):print("FAIL refusal ",text);failures+=1
		else:print("PASS refusal ",text)
	scene.location="approach"
	for text in ["survey the approach","go to marker then survey marker","return to hub","inspect objective"]:
		if scene.interpret_request(text).has("error"):print("FAIL ",text);failures+=1
		else:print("PASS interpretation ",text)
	quit(0 if failures==0 else 1)
