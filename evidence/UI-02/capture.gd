extends SceneTree
# Matched layout fixtures from retained synthetic B2 evidence; not a playthrough.
var scene:Node2D
var output:String
var metrics:Array=[]
func _initialize() -> void:call_deferred("run")
func frames(n:int=3) -> void:
 for i in range(n):await process_frame
func shot(label:String) -> void:
 scene.refresh_ui();scene.queue_redraw();await frames()
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output.path_join(label+".png"))
 var items:Array=[]
 collect(scene,items)
 metrics.append({"state":label,"window":[root.size.x,root.size.y],"controls":items,"snapshot":scene.snapshot()})
func collect(node:Node,items:Array) -> void:
 if node is Control and node.is_visible_in_tree() and (node is Button or node is Label):
  var r:Rect2=node.get_global_rect()
  items.append({"type":node.get_class(),"text":node.text,"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"disabled":node.disabled if node is Button else false})
 for child in node.get_children():collect(child,items)
func fixture(n:int) -> void:
 paused=false
 var path:=OS.get_environment("UI02_FIXTURES").path_join("snapshot-%09d.json" % n)
 scene.apply_snapshot(JSON.parse_string(FileAccess.get_file_as_string(path)))
 scene.message=""
func run() -> void:
 output=OS.get_environment("UI02_OUT")
 scene=load("res://scenes/chapter_opening.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene)
 await frames()
 scene.set_process(false);scene.sorted.process_mode=Node.PROCESS_MODE_DISABLED
 var scale:=OS.get_environment("UI02_TEXT_SCALE").to_float()
 if scale>1:enlarge(scene,scale)
 await shot("01-power-choice")
 scene.load_latest();await shot("02-no-save")
 fixture(2);await shot("03-combat")
 scene.phase="defeat";scene.hp=0;scene.message="Defeated. Retry loads the latest valid snapshot, not a reconstructed fresh encounter.";await shot("04-defeat")
 fixture(5);scene.player_cell=Vector2i(4,1);scene.human.position=scene.point(scene.player_cell)
 scene.message="Temporary shelter. Shared beds, open doorway: this is neither owned nor private. Choose a reward at the desk.";await shot("05-rewards")
 fixture(6);scene.player_cell=Vector2i(6,2);scene.human.position=scene.point(scene.player_cell);await shot("06-recruit")
 fixture(8);await shot("07-fetch-ready")
 scene.routine=true;await shot("08-walking");scene.routine=false
 fixture(11);paused=true;await shot("09-pause")
 var file:=FileAccess.open(OS.get_environment("B2_SAVE_DIR")+"-blocked",FileAccess.WRITE);file.store_string("synthetic obstruction");file.close()
 scene.save_store.directory=OS.get_environment("B2_SAVE_DIR")+"-blocked/child";scene.manual_save();await shot("10-save-failed")
 if "details_button" in scene:
  scene.details_button.pressed.emit();await shot("11-pause-details")
 var f:=FileAccess.open(output.path_join("metrics.json"),FileAccess.WRITE);f.store_string(JSON.stringify(metrics,"  "));f.close()
 paused=false;quit()
func enlarge(node:Node,factor:float) -> void:
 if node is Button or node is Label:node.add_theme_font_size_override("font_size",roundi(node.get_theme_font_size("font_size")*factor))
 for child in node.get_children():enlarge(child,factor)
