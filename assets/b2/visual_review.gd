extends SceneTree
## Synthetic art/motion fixture only. It cannot supply gameplay or owner evidence.
class ArtWorld extends Node2D:
	var sorted := Node2D.new()
	var package_taken := true
	var cache_taken := false

var world: ArtWorld
var art: Node2D
var actor: Node2D
var human: Node2D
var pet: Sprite2D
var elapsed := 0.0
var ticks := 0

func _initialize() -> void:
	call_deferred("begin")

func begin() -> void:
	root.size = Vector2i(1280,720)
	world = ArtWorld.new()
	root.add_child(world)
	world.sorted.y_sort_enabled = true
	world.add_child(world.sorted)
	art = load("res://scripts/chapter_art.gd").new()
	world.add_child(art)
	art.configure(world)
	art.set_location("shelter")
	actor = load("res://scripts/recruit_visual.gd").new()
	actor.position = Vector2(650,440)
	world.sorted.add_child(actor)
	human = load("res://scripts/human_controller.gd").new()
	human.automated = true
	human.position = Vector2(540,440)
	world.sorted.add_child(human)
	human.set_physics_process(false)
	pet = Sprite2D.new()
	pet.texture = load("res://art/pet/full.png")
	pet.scale = Vector2.ONE * (45.0/pet.texture.get_height())
	pet.position = Vector2(590,490)
	world.sorted.add_child(pet)
	var label := Label.new()
	label.text = "B2 art review · synthetic motion fixture · not playable evidence"
	label.position = Vector2(32,28)
	label.add_theme_font_size_override("font_size",23)
	world.add_child(label)

func _process(delta: float) -> bool:
	if not is_instance_valid(actor): return false
	elapsed += delta
	var direction := Vector2.RIGHT if elapsed < 2.0 else (Vector2.UP if elapsed < 4.0 else Vector2.LEFT)
	actor.update_motion(direction, true, delta)
	actor.position += direction*delta*35
	if ticks == 30:
		root.get_texture().get_image().save_png("/tmp/b2-art-shelter.png")
	if elapsed > 6.0:
		root.get_texture().get_image().save_png("/tmp/b2-art-shelter-final.png")
		quit()
	ticks += 1
	return false
