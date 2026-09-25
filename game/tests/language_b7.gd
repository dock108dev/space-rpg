extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var s=load("res://scenes/expedition.tscn").instantiate();s.auto_focus_pause=false;root.add_child(s);await process_frame
	var failed:=0
	for text in ["what am I preparing for?","what do we know about the route?","check our equipment and condition","enter expedition","take the live lane","take the drainage route","take the maintenance route","turn isolation wheel","recover routing core","file relay report","what remains unfinished?","what did we accomplish?"]:
		var r:Dictionary=s.interpret_request(text)
		if r.has("error"):print("FAIL parser ",text);failed+=1
		else:print("PASS parser only ",text)
	for text in ["take the route","resolve objective"]:
		if not s.interpret_request(text).has("error"):failed+=1
		else:print("PASS consequential ambiguity ",text)
	s.queue_free();await process_frame;quit(0 if failed==0 else 1)
