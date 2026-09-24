extends CharacterBody2D
# Shared B2 physical follower: same walkable cells as the protagonist, no wall teleport.
const Locations=preload("res://scripts/chapter_locations.gd")
const DIRS:=[Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
var controller:Node2D
var role:="pet"
var target:Node2D
var refresh:=0.0
var last_step:=Vector2.ZERO
var phase:=0.0
var picture:=Sprite2D.new()
var visual:Node2D
var route:Array[Vector2]=[]
var goal_cell:=Vector2i(-99,-99)
var last_target:Node2D
var blocked:=false
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_PAUSABLE
	collision_layer=0;collision_mask=1
	var collision:=CollisionShape2D.new();var shape:=CircleShape2D.new();shape.radius=8;collision.shape=shape;add_child(collision)
	if role=="recruit":
		picture.free()
		visual=load("res://scripts/recruit_visual.gd").new();add_child(visual)
	else:
		picture.texture=load("res://art/pet/full.png");picture.centered=false;picture.scale=Vector2.ONE*45/picture.texture.get_height()
		picture.position=Vector2(-picture.texture.get_width()*picture.scale.x/2,-45);add_child(picture)
func walkable(cell:Vector2i) -> bool:
	return controller.floor_free(cell)
func find_route(start:Vector2i,goal:Vector2i) -> Array[Vector2]:
	var result:Array[Vector2]=[]
	if not walkable(start) or not walkable(goal):return result
	var queue:Array[Vector2i]=[start];var parents:Dictionary={start:start}
	while not queue.is_empty():
		var cell:Vector2i=queue.pop_front()
		if cell==goal:break
		for direction in DIRS:
			var next:Vector2i=cell+direction
			if walkable(next) and not parents.has(next):parents[next]=cell;queue.append(next)
	if not parents.has(goal):return result
	var step:=goal
	while step!=start:
		result.push_front(controller.point(step));step=parents[step]
	# Align before crossing into the next cell: corner cutting never supplies a route.
	if global_position.distance_to(controller.point(start))>1:result.push_front(controller.point(start))
	return result
func desired_cell() -> Vector2i:
	var cell:Vector2i=controller.cell_at(target.global_position)
	if target==controller.human:
		var choices:=[Vector2i.LEFT,Vector2i.DOWN,Vector2i.UP,Vector2i.RIGHT] if role=="pet" else [Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT]
		for direction in choices:
			if walkable(cell+direction):return cell+direction
	return cell
func _physics_process(delta:float) -> void:
	last_step=Vector2.ZERO;velocity=Vector2.ZERO
	if not visible or not is_instance_valid(controller) or not is_instance_valid(target):
		if is_instance_valid(visual):visual.update_motion(Vector2.ZERO,false,delta)
		return
	var desired:=desired_cell()
	if desired!=goal_cell or last_target!=target or refresh<=0:
		goal_cell=desired;last_target=target
		# Preserve an in-flight segment when the target remains in the same cell.
		if route.is_empty() or not walkable(controller.cell_at(route[0])) or (not route.is_empty() and controller.cell_at(route[-1])!=desired):
			if not route.is_empty() and walkable(controller.cell_at(route[0])):
				var committed:=route[0]
				route=find_route(controller.cell_at(committed),desired)
				if route.is_empty() or route[0]!=committed:route.push_front(committed)
			else:route=find_route(controller.cell_at(global_position),desired)
		refresh=0.2
	refresh-=delta
	blocked=false
	if not route.is_empty():
		if not walkable(controller.cell_at(route[0])):route.clear();blocked=true
		else:
			var remaining:=global_position.distance_to(route[0])
			var speed:=160.0 if role=="pet" else 145.0
			velocity=global_position.direction_to(route[0])*minf(speed,remaining/maxf(delta,0.00001))
			var previous:=global_position;move_and_slide();last_step=global_position-previous
			if global_position.distance_to(route[0])<1:route.pop_front()
			if velocity.length()>1 and last_step.length()<0.01:blocked=true;route.clear()
	else:
		blocked=controller.cell_at(global_position)!=desired
	var moving:=last_step.length()>0.01
	if is_instance_valid(visual):visual.update_motion(last_step,moving,delta)
	elif moving:
		phase+=delta*12;picture.flip_h=last_step.x<0 if absf(last_step.x)>0.01 else picture.flip_h
		picture.position.y=-45-absf(sin(phase))*1.5
	else:picture.position.y=-45
func reset_path() -> void:
	route.clear();goal_cell=Vector2i(-99,-99);last_target=null;refresh=0;velocity=Vector2.ZERO;blocked=false
