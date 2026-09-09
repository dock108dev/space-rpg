extends Node2D
var state := "idle"
var elapsed := 0.0
var action_count := 0
var pose := Node2D.new()
func _ready() -> void:
	add_child(pose)
	var sprite:=Sprite2D.new();sprite.texture=load("res://art/creature/full.png");sprite.centered=false
	sprite.scale=Vector2.ONE*85/float(sprite.texture.get_height());sprite.position=Vector2(-sprite.texture.get_width()*sprite.scale.x/2,-85);pose.add_child(sprite)
func advance() -> void:
	if state=="idle":state="preparation";elapsed=0
	elif state=="preparation":state="action";elapsed=0;action_count+=1
func reset_demo() -> void:
	state="idle";elapsed=0;action_count=0;pose.position=Vector2.ZERO;pose.scale=Vector2.ONE;pose.rotation=0
func _process(delta:float) -> void:
	elapsed+=delta
	match state:
		"idle":pose.scale=Vector2(1,1+sin(elapsed*2)*0.015);pose.position=Vector2.ZERO;pose.rotation=0
		"preparation":pose.scale=Vector2(1.13,0.73);pose.position=Vector2(9,0);pose.rotation=-0.12
		"action":
			pose.scale=Vector2(1.08,0.87);pose.rotation=-0.18;pose.position.x=lerpf(9,-48,minf(elapsed/0.22,1))
			if elapsed>=0.28:state="recovery";elapsed=0
		"recovery":
			pose.position.x=lerpf(-48,0,minf(elapsed/0.7,1));pose.rotation=lerpf(-0.18,0,minf(elapsed/0.7,1));pose.scale=Vector2.ONE
			if elapsed>=0.7:state="idle";elapsed=0
