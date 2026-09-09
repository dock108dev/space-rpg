extends SceneTree
var failures: Array[String] = []
var passed: Array[String] = []
var scene:Node2D
var pet_safety:=true
var pet_continuity:=true
func check(value:bool,description:String) -> void:
	if value:passed.append(description);print("PASS ",description)
	else:failures.append(description);push_error(description)
func frames(count:int) -> void:
	for i in range(count):await physics_frame
func _initialize() -> void:call_deferred("run")
func track_pet(previous:Vector2) -> void:
	if scene.pet.position.distance_to(previous)>2.2:pet_continuity=false
	for rect in scene.solids:
		if rect.grow(7.5).has_point(scene.pet.position):pet_safety=false
func walk_to(point:Vector2) -> bool:
	for i in range(900):
		if scene.human.position.distance_to(point)<5:
			scene.human.direction=Vector2.ZERO;return true
		scene.human.direction=scene.human.position.direction_to(point)
		var previous:Vector2=scene.pet.position;await physics_frame;track_pet(previous)
	scene.human.direction=Vector2.ZERO;return false
func settle_pet() -> void:
	for i in range(240):
		var previous:Vector2=scene.pet.position;await physics_frame;track_pet(previous)
func run() -> void:
	scene=load("res://scenes/visual_sample.tscn").instantiate();root.add_child(scene);await frames(5)
	var human=scene.human;human.automated=true
	human.position=Vector2(380,560);human.direction=Vector2.RIGHT;await frames(61)
	var straight:float=human.position.distance_to(Vector2(380,560))
	human.position=Vector2(380,480);human.direction=Vector2.ONE;await frames(61)
	var diagonal:float=human.position.distance_to(Vector2(380,480))
	check(absf(straight-diagonal)<0.1 and straight>90,"actual normalized diagonal displacement")
	human.direction=Vector2.ZERO;await frames(2);var stopped:Vector2=human.position;await frames(20)
	check(human.position.distance_to(stopped)<0.01,"released input stops player")
	check(human.facing=="toward","diagonal tie and idle facing retention")
	human.position=Vector2(1120,450);human.direction=Vector2.RIGHT;await frames(60)
	check(human.position.x<1136 and human.position.x>1120,"wall collision blocks displacement")
	human.position=Vector2(470,438);human.direction=Vector2.RIGHT;await frames(60)
	check(human.position.x<486,"cabinet footprint blocks displacement")
	for pair in [[Vector2.LEFT,"left"],[Vector2.RIGHT,"right"],[Vector2.UP,"away"],[Vector2.DOWN,"toward"]]:
		human.position=Vector2(450,540);human.direction=pair[0];await frames(2);check(human.facing==pair[1],"facing "+pair[1])
	scene.reset_sample();human.direction=Vector2.ZERO;await frames(5)
	var route_ok:=true
	for point in [Vector2(450,370),Vector2(690,370),Vector2(690,480),Vector2(925,480),Vector2(925,255)]:
		route_ok=await walk_to(point) and route_ok
	await settle_pet()
	check(route_ok and scene.pet.position.y<310,"pet corners around cabinet and follows through doorway")
	for point in [Vector2(925,465),Vector2(450,540)]:route_ok=await walk_to(point) and route_ok
	await settle_pet()
	check(route_ok and scene.pet.position.distance_to(human.position)<50,"pet reverses through doorway and follows back")
	check(pet_safety,"pet footprint stays outside every wall and cabinet")
	check(pet_continuity,"pet motion continuous without wall warps")
	# Set up an unreachable target across a temporarily blocked doorway; only fixture placement teleports.
	human.position=Vector2(925,260);human.direction=Vector2.ZERO;scene.pet.position=Vector2(925,430);scene.set_route_blocked(true);await frames(5)
	await settle_pet();check(scene.pet.position.y>357,"blocked doorway leaves pet safely outside")
	scene.set_route_blocked(false);await frames(5);await settle_pet()
	check(scene.pet.position.y<310,"pet recovers route after doorway reopens")
	human.position=scene.TERMINAL+Vector2(0,60);check(scene.available_interaction()=="terminal","nearby interaction available")
	human.position=scene.TERMINAL+Vector2(0,75);var count:int=scene.interaction_count;scene.interact();check(scene.available_interaction()=="" and scene.interaction_count==count,"out-of-range interaction absent and inert")
	human.position=scene.DEMO_CONTROL;scene.interact();await frames(600)
	check(scene.creature.state=="preparation" and scene.creature.action_count==0,"creature preparation held for ten seconds without input")
	scene.shield.trigger();human.direction=Vector2.RIGHT;paused=true;await frames(2)
	var freeze:Vector2=human.position;var pet_freeze:Vector2=scene.pet.position;var clock:float=scene.elapsed;var pose_clock:float=scene.creature.elapsed;var effect:float=scene.shield.remaining
	await frames(60);scene.interact()
	check(human.position==freeze and scene.pet.position==pet_freeze and scene.elapsed==clock and scene.creature.elapsed==pose_clock and scene.shield.remaining==effect and scene.creature.state=="preparation","explicit pause halts actors creature effects and interaction")
	paused=false;human.direction=Vector2.ZERO;scene.interact()
	for i in range(12):scene.interact()
	check(scene.creature.action_count==1,"repeated action input does not duplicate creature action")
	await frames(80);check(scene.creature.state=="idle","creature action and recovery return to idle")
	var baseline:int=root.get_tree().get_node_count()
	human.position=scene.TERMINAL+Vector2(0,50)
	for i in range(100):scene.shield.trigger();scene.interact()
	await frames(180)
	check(scene.shield.remaining==0 and scene.response_time==0 and root.get_tree().get_node_count()==baseline,"100 repeated effects and interactions retire without node growth")
	scene.reset_sample();await frames(1)
	check(human.position==scene.START and scene.pet.position==scene.PET_START and scene.creature.state=="idle" and scene.shield.remaining==0 and scene.interaction_count==0,"reset restores actors demo effects and interaction state")
	var result={"passed":passed,"failed":failures,"not_run":["owner acceptance of complete scene"],"scope":"S02 technical behavior; visual assessment separate"}
	var dest:=OS.get_environment("S02_CHECKS_PATH")
	if not dest.is_empty():var f:=FileAccess.open(dest,FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "))
	quit(0 if failures.is_empty() else 1)
