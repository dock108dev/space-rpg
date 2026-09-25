extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/preparation.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
	# Explicit interpretation-only context fixture, never counted as gameplay.
	scene.location="hub"
	scene.power="shield"
	var failures:=0
	for request in ["What equipment do I have?","Compare these.","What would upgrading this change?","How much material do I have?","Where can I get more?","Equip the Focus lens.","Wear Guard weave","Unequip that.","Improve my shield.","Upgrade Stride rig","Exchange the supply bundle.","What can I afford?","Stop.","please claim the preparation kit","go to bench then improve lens","actually, equip rig","test power","rest"]:
		var before:Dictionary=scene.progression.duplicate(true)
		var result:Dictionary=scene.interpret_request(request)
		if result.has("error") or scene.progression!=before:print("FAIL B4 interpretation ",request," ",result);failures+=1
		else:print("PASS B4 interpretation ",request," ",result)
	for request in ["improve equipment","improve lens or shield","improve blast or shield","upgrade power and rig","equip lens or weave","buy a spaceship","don't improve lens"]:
		if not scene.interpret_request(request).has("error"):print("FAIL B4 refusal ",request);failures+=1
		else:print("PASS B4 refusal ",request)
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
