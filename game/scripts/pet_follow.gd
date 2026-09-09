extends CharacterBody2D
var target: Node2D
var agent := NavigationAgent2D.new()
var picture := Sprite2D.new()
var refresh := 0.0
var phase := 0.0
var last_step := Vector2.ZERO
func _ready() -> void:
	collision_layer=0;collision_mask=1
	var c:=CollisionShape2D.new();var circle:=CircleShape2D.new();circle.radius=8;c.shape=circle;add_child(c)
	agent.path_desired_distance=3;agent.target_desired_distance=8;agent.path_max_distance=30;add_child(agent)
	picture.texture=load("res://art/pet/full.png");picture.centered=false
	var h:=float(picture.texture.get_height());picture.scale=Vector2.ONE*45/h
	picture.position=Vector2(-picture.texture.get_width()*picture.scale.x/2,-45);add_child(picture)
func _physics_process(delta:float) -> void:
	last_step=Vector2.ZERO
	if not is_instance_valid(target) or NavigationServer2D.map_get_iteration_id(agent.get_navigation_map())==0:return
	refresh-=delta
	if refresh<=0:
		agent.target_position=target.global_position;refresh=0.2
	var query:=PhysicsRayQueryParameters2D.create(global_position,target.global_position,1)
	var clear:=get_world_2d().direct_space_state.intersect_ray(query).is_empty()
	velocity=Vector2.ZERO
	if not (clear and global_position.distance_to(target.global_position)<44) and not agent.is_navigation_finished():
		var next:=agent.get_next_path_position()
		velocity=global_position.direction_to(next)*125
	var previous:=position;move_and_slide();last_step=position-previous
	if last_step.length()>0.01:
		phase+=delta*12
		picture.flip_h=last_step.x<0
		picture.position.y=-45-absf(sin(phase))*1.5
	else:picture.position.y=-45
