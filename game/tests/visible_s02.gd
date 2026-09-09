extends SceneTree
var scene:Node2D
func _initialize() -> void:call_deferred("run")
func frames(count:int) -> void:
	for i in range(count):await physics_frame
func walk_to(point:Vector2) -> void:
	for i in range(900):
		if scene.human.position.distance_to(point)<4:break
		scene.human.direction=scene.human.position.direction_to(point);await physics_frame
	scene.human.direction=Vector2.ZERO;await frames(20)
func press(code:int) -> void:
	var e:=InputEventKey.new();e.physical_keycode=code;e.pressed=true;scene._unhandled_key_input(e)
func run() -> void:
	scene=load("res://scenes/visual_sample.tscn").instantiate();root.add_child(scene);await frames(10);scene.human.automated=true
	for point in [Vector2(450,355),Vector2(680,355),Vector2(680,480),Vector2(925,455),Vector2(925,260),Vector2(990,260),Vector2(925,455)]:await walk_to(point)
	await walk_to(scene.DEMO_CONTROL);press(KEY_E);await frames(180);press(KEY_E);await frames(80)
	press(KEY_SPACE);await frames(30);press(KEY_ESCAPE);await frames(60);press(KEY_ESCAPE);await frames(80)
	await walk_to(scene.TERMINAL+Vector2(0,52));press(KEY_E);press(KEY_SPACE);await frames(90)
	press(KEY_R);await frames(60);quit()
