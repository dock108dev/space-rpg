extends "res://tests/run_b2.gd"
# Focus/input regression for the B2 presentation pass, using disposable synthetic saves.
func run() -> void:
 base=OS.get_environment("B2_SAVE_DIR").path_join("ui")
 await fresh()
 await frames(3)
 var before:Dictionary=gameplay()
 scene.buttons.save.grab_focus()
 await key(KEY_SPACE)
 check("focused Save responds to Space and preserves gameplay",gameplay()==before and "stored" in scene.save_store.notice)
 scene.buttons.save.grab_focus()
 await key(KEY_ESCAPE)
 check("Escape opens Pause from focused control",paused and root.gui_get_focus_owner()==scene.pause_resume)
 for i in range(12):
  await key(KEY_TAB)
  check("pause Tab stays in pause controls %d" % i,scene.pause_panel.is_ancestor_of(root.gui_get_focus_owner()))
 scene.details_button.grab_focus();await key(KEY_SPACE)
 check("keyboard disclosure opens without changing game",scene.pause_help.visible and scene.save_details.visible and gameplay()==before)
 await key(KEY_SPACE)
 check("keyboard disclosure closes",not scene.pause_help.visible and not scene.save_details.visible)
 await key(KEY_ESCAPE)
 check("Escape restores focus and resumes",not paused and root.gui_get_focus_owner()==scene.buttons.save)
 var at:Vector2i=scene.player_cell
 await key(KEY_LEFT);await settle()
 check("arrow from button focus makes exactly one world step",scene.player_cell==at+Vector2i.LEFT and root.gui_get_focus_owner()==null)
 await key(KEY_RIGHT);await settle()
 # Clicking a UI control must not leave Enter captured by that control.
 await click(scene.buttons.save.get_global_rect().get_center())
 check("mouse Save releases keyboard focus",root.gui_get_focus_owner()==null)
 await enter_assessment()
 await frames(3)
 await click(scene.buttons.bolt.get_global_rect().get_center());await frames(3)
 check("mouse action selection keeps direct turn key available",scene.mode=="bolt" and root.gui_get_focus_owner()==null)
 var previous_turn:int=scene.turn
 await key(KEY_ENTER);await settle()
 check("Enter after mouse action ends exactly one turn",scene.turn==previous_turn+1)
 # Recovery presentation: no false success or swallowed fallback warning.
 var shown:String=scene.readable_message("Loaded manual save 4. Skipped 2 interrupted or invalid save(s); files preserved.")
 check("fallback recovery remains visible", "could not be used" in shown and "usable save" in shown)
 shown=scene.readable_message("No supported save found. Skipped 2 interrupted or invalid save(s); files preserved.")
 check("invalid saves distinguished from no files", "No usable save" in shown and "kept" in shown)
 # A stable synthetic fixture exercises failure, retry, disclosure, and scaled layout.
 await fight();await collect_and_shelter()
 var folder:String=scene.save_store.directory
 var obstruction:=FileAccess.open(base.path_join("blocked"),FileAccess.WRITE);obstruction.store_string("synthetic");obstruction.close()
 scene.save_store.directory=base.path_join("blocked/child")
 await key(KEY_ESCAPE)
 check("failed quit keeps paused session and progress",not scene.save_and_quit() and not scene.quit_requested and paused)
 scene.refresh_ui();await frames(3)
 check("save failure exposes recovery without disclosure",scene.pause_recover.visible and scene.pause_retry.text=="Retry save" and "not saved" in scene.pause_notice.text)
 scene.save_store.directory=folder
 scene.pause_retry.grab_focus();await key(KEY_SPACE);await frames(3)
 check("retry saves actual state and displays success", "stored" in scene.save_store.notice and scene.feedback.text=="Progress saved.")
 scene.details_button.grab_focus();await key(KEY_SPACE)
 var panel_before:Rect2=scene.pause_panel.get_global_rect()
 check("expanded pause fits 1280 by 720",Rect2(0,0,1280,720).encloses(panel_before))
 enlarge(scene,1.25);scene.refresh_ui();await frames(6)
 check("expanded pause fits with 125 percent text",Rect2(0,0,1280,720).encloses(scene.pause_panel.get_global_rect()))
 paused=false
 var failed:=checks.filter(func(item):return not item.passed)
 var output:=FileAccess.open(OS.get_environment("B2_CHECKS_PATH").replace("b2-checks.json","b2-ui-checks.json"),FileAccess.WRITE)
 output.store_string(JSON.stringify(checks,"  "));output.close()
 print("B2 UI RESULTS ",checks.size()," checks; ",failed.size()," failed")
 quit(0 if failed.is_empty() else 1)
func enlarge(node:Node,factor:float) -> void:
 if node is Button or node is Label:node.add_theme_font_size_override("font_size",roundi(node.get_theme_font_size("font_size")*factor))
 for child in node.get_children():enlarge(child,factor)

func gameplay() -> Dictionary:
 var data:Dictionary=scene.snapshot()
 data.erase("pet_position");data.erase("recruit_position")
 return data
