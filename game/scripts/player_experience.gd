extends "res://scripts/expedition.gd"
const ExperienceSave=preload("res://scripts/experience_save.gd")
const PALETTES:={"amber":Color("f5d4a0"),"teal":Color("86dcd1"),"plum":Color("d9a4dc")}
var character:={"name":"Alex","appearance":"amber"}
var experience_ready:=false
var setup_open:=true
var safe_walking:=false
var session_root:=""
var setup_cover:=ColorRect.new()
var setup_panel:=Panel.new()
var name_input:=LineEdit.new()
var appearance_choice:=OptionButton.new()
var setup_preview:CharacterBody2D
var setup_notice:=Label.new()
var outcome:=Label.new()
var objective_now:=Label.new()
var help_panel:=Panel.new()
var help_copy:=RichTextLabel.new()
var history_open:=false
var text_large:=false
var motion_phase:=0.0
var actor_previous:Dictionary={}
var rest_pivots:Dictionary={}
var party_labels:Dictionary={}
var choice_scroll:=ScrollContainer.new()
var last_outcome:=""
var pointer_ok:=true
var session_pointer_notice:=""
var fresh_unsaved:=false
var saved_characters:=OptionButton.new()
var text_switches:Array[Button]=[]
var pause_scrim:=ColorRect.new()

func create_save_store() -> RefCounted:
	if OS.has_feature("b9_personal"):
		# Explicit disposable qualification root only; never discover earlier saves.
		session_root=OS.get_environment("B9_SAVE_DIR")
		if session_root.is_empty():session_root=OS.get_user_data_dir().path_join("chapter-v1")
	else:
		session_root=OS.get_environment("B8_SAVE_DIR")
		if session_root.is_empty():session_root=ProjectSettings.globalize_path("res://../dev-state/B8-practice-v1")
	var slot:=read_session_slot()
	return ExperienceSave.new(session_root.path_join(slot))

func _ready() -> void:
	super._ready()

	get_window().title=str(ProjectSettings.get_setting("application/config/name"))+" · Your relay receipt" if OS.has_feature("b9_personal") else "Space Opera RPG · Your relay receipt"
	get_window().min_size=Vector2i(1152,882)
	transcript.bbcode_enabled=false
	transcript.position=Vector2(30,795);transcript.size=Vector2(760,98)
	outcome.position=Vector2(30,690);outcome.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;outcome.size=Vector2(760,205);outcome.clip_text=true;outcome.add_theme_font_size_override("font_size",18);transcript.get_parent().add_child(outcome)
	objective_now.position=Vector2(30,722);objective_now.size=Vector2(760,25);objective_now.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;objective_now.add_theme_font_size_override("font_size",18);transcript.get_parent().add_child(objective_now);objective_now.hide()
	var parent:=choices.get_parent();parent.remove_child(choices);parent.add_child(choice_scroll)
	# One lower working area replaces the empty feedback strip plus command panel.
	for child in feedback.get_parent().get_children():
		if child is Panel and child.position==Vector2(16,648):child.hide()
	feedback.hide();audience.reparent(parent);audience.position=Vector2(30,655);audience.size=Vector2(760,36);audience.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	activity.size.x=760
	for child in parent.get_children():
		if child is Panel and child.position==Vector2(16,720):child.position.y=648;child.size.y=320
	choice_scroll.position=Vector2(810,707);choice_scroll.size=Vector2(440,197);choice_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;choice_scroll.add_child(choices);choices.position=Vector2.ZERO;choices.custom_minimum_size=Vector2(420,0);choices.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	for spec in [["Help",810],["History",936],["Text +",1062]]:
		var button:=Button.new();button.theme=GlassUI.make_theme();button.text=spec[0];button.position=Vector2(spec[1],655);button.size=Vector2(118,44);parent.add_child(button)
		if spec[0]=="Help":button.pressed.connect(show_help)
		elif spec[0]=="History":button.pressed.connect(func():history_open=not history_open;update_reading())
		else:text_switches.append(button);button.pressed.connect(func():set_large_text(not text_large))
	build_setup();build_help()
	var pause_layer:=CanvasLayer.new();pause_layer.layer=11;pause_layer.process_mode=Node.PROCESS_MODE_ALWAYS;add_child(pause_layer);pause_scrim.color=Color(0.025,0.035,0.05,0.94);pause_scrim.size=Vector2(1280,980);pause_layer.add_child(pause_scrim);pause_scrim.hide();pause_panel.reparent(pause_layer)
	if not session_pointer_notice.is_empty():setup_notice.text=session_pointer_notice
	for id in human.groups:
		rest_pivots[id]={}
		for part in ["far_leg","near_leg","far_arm","near_arm","torso","head"]:rest_pivots[id][part]=human.groups[id].get_node(part).position
	for actor in [human,pet,recruit]:
		actor_previous[actor]=actor.position
		var label:=Label.new();label.position=Vector2(-72,9);label.size=Vector2(144,24);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",13);label.add_theme_color_override("font_outline_color",Color("172331"));label.add_theme_constant_override("outline_size",4);actor.add_child(label);party_labels[actor]=label
	experience_ready=true
	pause_reset.text="New character"
	pause_help.text="Type commands and press Return. Tab moves focus; Space activates buttons. Click the world to reclaim direct controls. WASD/arrows move, E interacts, Enter ends a turn. Escape pauses. Stop cancels future work. New character creates a separate session; earlier saves remain preserved."
	var prefs:=ConfigFile.new()
	var pref_path:=session_root.path_join("presentation.cfg")
	var pref_error:=ERR_FILE_NOT_FOUND
	if ExperienceSave.linked(session_root) or ExperienceSave.linked(pref_path):pref_error=ERR_UNAUTHORIZED
	elif ExperienceSave.path_presence(pref_path)!=1:
		var pref_file:=FileAccess.open(pref_path,FileAccess.READ)
		if pref_file:
			pref_error=ERR_INVALID_DATA
			if pref_file.get_length()<=4096:pref_error=prefs.parse(pref_file.get_as_text())
			pref_file.close()
		else:pref_error=ERR_FILE_CANT_READ
	if pref_error==OK:text_large=bool(prefs.get_value("display","large_text",false))
	elif pref_error!=ERR_FILE_NOT_FOUND:push_warning("PRESENTATION_LOAD_FAILED code=%d; using default text size" % pref_error)
	set_large_text(text_large,false);apply_appearance();update_reading()
	setup_panel.show();name_input.grab_focus()

func build_setup() -> void:
	var layer:=CanvasLayer.new();layer.layer=12;layer.process_mode=Node.PROCESS_MODE_ALWAYS;add_child(layer)
	setup_cover.color=Color(0.055,0.075,0.10,0.98);setup_cover.size=Vector2(1280,980);layer.add_child(setup_cover)
	setup_panel.position=Vector2(160,174);setup_panel.size=Vector2(960,502);setup_panel.add_theme_stylebox_override("panel",GlassUI.panel_style(true));layer.add_child(setup_panel)
	var title:=Label.new();title.text="Create your character";title.position=Vector2(32,24);title.add_theme_font_size_override("font_size",30);setup_panel.add_child(title)
	var intro:=Label.new();intro.text="The shutters came down while you were shopping. A guarded package\noffers a way toward shelter. An unfamiliar animal follows you.";intro.position=Vector2(32,76);intro.add_theme_font_size_override("font_size",20);setup_panel.add_child(intro)
	var caption:=Label.new();caption.text="Name · up to 32 characters";caption.position=Vector2(32,144);setup_panel.add_child(caption)
	name_input.position=Vector2(32,178);name_input.size=Vector2(530,44);name_input.text="Alex";name_input.max_length=256;name_input.add_theme_font_size_override("font_size",22);setup_panel.add_child(name_input)
	appearance_choice.position=Vector2(32,242);appearance_choice.size=Vector2(280,44)
	for id in ExperienceSave.APPEARANCES:appearance_choice.add_item(id.capitalize()+" jacket")
	setup_panel.add_child(appearance_choice)
	setup_preview=load("res://scripts/human_controller.gd").new();setup_preview.automated=true;setup_preview.position=Vector2(754,330);setup_preview.scale=Vector2.ONE*1.8;setup_panel.add_child(setup_preview);setup_preview.set_physics_process(false)
	appearance_choice.item_selected.connect(func(_index:int):tint_actor(setup_preview,ExperienceSave.APPEARANCES[appearance_choice.selected]))
	tint_actor(setup_preview,"amber")
	setup_notice.position=Vector2(32,304);setup_notice.size=Vector2(580,80);setup_notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;setup_notice.text="Jacket choice changes your look; choose a power in the harmless trials.\nBlank names use Alex. Starting keeps earlier characters saved.";setup_panel.add_child(setup_notice)
	var start:=Button.new();start.theme=GlassUI.make_theme();start.text="Start new chapter";start.position=Vector2(32,414);start.size=Vector2(270,48);setup_panel.add_child(start);emphasize(start,true);start.pressed.connect(func():start_character(name_input.text,ExperienceSave.APPEARANCES[appearance_choice.selected]))
	var resume:=Button.new();resume.theme=GlassUI.make_theme();resume.text="Continue last character";resume.position=Vector2(322,414);resume.size=Vector2(302,48);setup_panel.add_child(resume);resume.pressed.connect(func():if not load_latest():setup_notice.text=setup_save_message(save_store.notice))
	saved_characters.allow_reselect=true;saved_characters.fit_to_longest_item=false;saved_characters.clip_text=true;saved_characters.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;saved_characters.position=Vector2(650,414);saved_characters.size=Vector2(280,48);saved_characters.add_item("Earlier characters");setup_panel.add_child(saved_characters)
	saved_characters.get_popup().about_to_popup.connect(list_saved_characters)
	saved_characters.item_selected.connect(func(index:int):
		var path:String=saved_characters.get_item_metadata(index)
		var previous_store=save_store;var previous_notice:=session_pointer_notice;var previous_fresh:=fresh_unsaved
		fresh_unsaved=false;session_pointer_notice="";save_store=ExperienceSave.new(path)
		if not load_latest():setup_notice.text=save_store.notice;save_store=previous_store;session_pointer_notice=previous_notice;fresh_unsaved=previous_fresh)
	var text_switch:=Button.new();text_switch.theme=GlassUI.make_theme();text_switch.position=Vector2(706,24);text_switch.size=Vector2(222,44);setup_panel.add_child(text_switch);text_switches.append(text_switch);text_switch.pressed.connect(func():set_large_text(not text_large))
	name_input.text_submitted.connect(func(_value:String):appearance_choice.grab_focus())

func build_help() -> void:
	setup_panel.get_parent().add_child(help_panel);help_panel.position=Vector2(160,130);help_panel.size=Vector2(960,710);help_panel.add_theme_stylebox_override("panel",GlassUI.panel_style(true))
	help_copy.position=Vector2(28,24);help_copy.size=Vector2(904,596);help_copy.add_theme_font_size_override("normal_font_size",20);help_panel.add_child(help_copy)
	var close:=Button.new();close.theme=GlassUI.make_theme();close.text="Back to game";close.position=Vector2(28,642);close.size=Vector2(270,44);help_panel.add_child(close);close.pressed.connect(func():help_panel.hide();setup_cover.hide();get_tree().paused=false;command_input.grab_focus());help_panel.hide()
func show_help() -> void:
	if setup_open:return
	stop_work("Help opened; remaining plan stopped.");get_tree().paused=true
	help_copy.text=controls_text();setup_cover.show();help_panel.show();help_panel.get_child(1).grab_focus()
func controls_text() -> String:
	return "Commands\nType look around, inspect a target, or go to a named place. Choices send the same commands. Exact steps: move 2 up and 3 right. Questions explain; they never spend action points (AP).\n\nTurns and Stop\nIn danger: 4 AP per turn. Step, guard or shield: 1 AP. Shot or blast: 2 AP; the target must be in clear range. End turn lets allies and the enemy respond and restores AP. Then give a new command; the old plan stops. Stop cancels future steps; an action already committed finishes.\n\nPractice and recovery\nThe north range is harmless. Enter breach starts a repeatable fight; enter expedition starts the relay assignment. Preparation, home, recruitment and local jobs are optional. Retreat brings the party back. Rest heals you free; injured companions need care at the shelter desk.\n\nKeyboard and saving\nReturn sends a command. Tab selects a control; Space activates it. Click the world for WASD/arrows, E to interact, Enter to end a turn. Escape pauses. Help and History are available during play. Save and quit is in Pause; Continue restores saved progress. Commands support named actions, not arbitrary goals."
func setup_save_message(value:String) -> String:
	if value=="No supported save found.":return "No saved character yet. Choose a name and jacket, then Start new chapter."
	if value.begins_with("No supported save found."):return "No usable character save. Existing files were kept; choose an earlier character or start a new chapter."
	return readable_message(value)
func readable_message(value:String) -> String:
	# Keep partial-save warnings even when the leading snapshot write succeeded.
	if (value.begins_with("Manual save ") or value.begins_with("Auto save ")) and " stored." in value:
		return "Progress saved."+value.substr(value.find(" stored.")+8)
	return super.readable_message(value)
func start_character(value:String,appearance:String) -> bool:
	if appearance not in ExperienceSave.APPEARANCES:return false
	if not super.reset_demo():return false
	character={"name":ExperienceSave.clean_name(value),"appearance":appearance}
	save_store=ExperienceSave.new(session_root.path_join("session-%d-%d"%[Time.get_unix_time_from_system(),Time.get_ticks_usec()]))
	fresh_unsaved=true;pointer_ok=true;session_pointer_notice="";setup_open=false;setup_panel.hide();setup_cover.hide();safe_walking=false;human.facing="toward";human.show_facing();apply_appearance()
	message="";last_message="";history.clear();say(character.name+", the shutters have closed behind your shopping trip. A guarded package is the first step toward shelter. Try the three harmless powers, then choose one. Type look around or use the choices; Help explains controls.")
	command_input.grab_focus();return true
func list_saved_characters() -> void:
	saved_characters.clear()
	if ExperienceSave.linked(session_root):
		setup_notice.text="Linked character folders are not supported. Choose a regular save folder."
		saved_characters.add_item("Character folder unavailable");saved_characters.set_item_disabled(0,true);return
	var directories:=DirAccess.get_directories_at(session_root);directories.reverse()
	for directory in directories:
		if not directory.begins_with("session-"):continue
		var store:=ExperienceSave.new(session_root.path_join(directory));var data:=store.latest()
		if data.is_empty():continue
		saved_characters.add_item(data.character.name+" · "+data.location)
		saved_characters.set_item_metadata(saved_characters.item_count-1,store.directory)
	if saved_characters.item_count==0:
		saved_characters.add_item("No earlier saved characters");saved_characters.set_item_disabled(0,true)
func reset_demo() -> bool:
	if not experience_ready:return super.reset_demo()
	if busy:return reject("Finish the current action before character setup.")
	stop_work("Character setup opened.");get_tree().paused=false;setup_open=true;setup_cover.show();setup_panel.show();name_input.grab_focus();return true
func read_session_slot() -> String:
	session_pointer_notice=""
	var path:=session_root.path_join("current-session.txt")
	if ExperienceSave.linked(session_root) or ExperienceSave.linked(path):
		session_pointer_notice="Continue selection uses a linked path. Choose a regular save folder; no files changed."
		return "session-default"
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null:
		if ExperienceSave.path_presence(path)==1:return "session-default"
		session_pointer_notice="Continue selection could not be read. Restore folder access, or choose Earlier characters."
		return "session-default"
	var slot:=""
	if file.get_length()<=256:slot=file.get_as_text()
	var error:=file.get_error();file.close()
	if (error!=OK and error!=ERR_FILE_EOF) or not slot.begins_with("session-") or "/" in slot or "\\" in slot or ".." in slot:
		session_pointer_notice="Continue selection is unreadable or invalid. Choose Earlier characters; saved chapters are preserved."
		return "session-default"
	return slot
func load_latest() -> bool:
	if fresh_unsaved or not session_pointer_notice.is_empty():
		var has_selector:=ExperienceSave.path_presence(session_root.path_join("current-session.txt"))!=1
		var slot:=read_session_slot()
		if has_selector and session_pointer_notice.is_empty():save_store=ExperienceSave.new(session_root.path_join(slot))
	if not session_pointer_notice.is_empty():
		save_store.notice=session_pointer_notice
		return false
	var ok:=super.load_latest()
	if ok:fresh_unsaved=false;setup_open=false;setup_panel.hide();setup_cover.hide();help_panel.hide();safe_walking=false;command_input.grab_focus()
	return ok
func snapshot() -> Dictionary:
	var direction:Vector2=point(player_cell)-human.position
	var facing:String=human.facing
	if direction.length()>1 and direction.length()<400:
		facing=("left" if direction.x<0 else "right") if absf(direction.x)>absf(direction.y) else ("away" if direction.y<0 else "toward")
	var d:=super.snapshot();d.merge({"experience_version":1,"character":character.duplicate(true),"facing":facing});return d
func apply_snapshot(d:Dictionary) -> void:
	character=d.get("character",{"name":"Alex","appearance":"amber"}).duplicate(true)
	safe_walking=false
	super.apply_snapshot(d)
	human.facing=d.get("facing","toward");human.show_facing();apply_appearance()
	for actor in [human,pet,recruit]:actor_previous[actor]=actor.position
func persist(kind:String="auto") -> bool:
	if ExperienceSave.linked(session_root):
		save_store.notice="Save failed: linked character folders are not supported.";message=save_store.notice;return false
	var ok:=super.persist(kind)
	if ok:fresh_unsaved=false
	if ok and experience_ready and save_store.directory.get_base_dir()==session_root and save_store.directory.get_file().begins_with("session-"):
		pointer_ok=false
		var temporary:=session_root.path_join("current-session-%d-%d.tmp" % [OS.get_process_id(),Time.get_ticks_usec()])
		var pointer:FileAccess=null
		if not ExperienceSave.linked(temporary):pointer=FileAccess.open(temporary,FileAccess.WRITE)
		if pointer:
			pointer.store_string(save_store.directory.get_file());pointer.flush();var error:=pointer.get_error();pointer.close()
			if error==OK:pointer_ok=DirAccess.rename_absolute(temporary,session_root.path_join("current-session.txt"))==OK
		if not pointer_ok:
			save_store.notice+=" Chapter saved, but Continue selection could not update. Retry Save or use Earlier characters next launch."
			push_warning("SESSION_POINTER_UPDATE_FAILED snapshot_committed=true")
			say(save_store.notice)
	return ok
func save_and_quit() -> bool:
	quit_requested=false
	if not stable_boundary():return reject("Finish or Stop the current action, then Save and quit.")
	if not manual_save():return false
	if not pointer_ok:return reject("Chapter saved, but Continue selection could not update. Session stays open. Retry Save and quit, or use Earlier characters next launch.")
	quit_requested=true
	if OS.get_environment("B2_TEST_NO_QUIT")!="1":get_tree().quit()
	return true
func tint_actor(actor:Node,appearance:String) -> void:
	for group in actor.groups.values():
		var sprite:Sprite2D=group.get_node("torso").get_child(0)
		var material:=ShaderMaterial.new();var shader:=Shader.new()
		shader.code="shader_type canvas_item; uniform vec4 jacket: source_color; void fragment(){vec4 c=texture(TEXTURE,UV);float l=dot(c.rgb,vec3(0.299,0.587,0.114));COLOR=vec4(mix(c.rgb,jacket.rgb*l*1.8,0.85),c.a);}"
		material.shader=shader;material.set_shader_parameter("jacket",PALETTES[appearance]);sprite.material=material
func apply_appearance() -> void:
	if is_instance_valid(human):tint_actor(human,character.appearance)
func set_large_text(enabled:bool,save_pref:bool=true) -> void:
	text_large=enabled
	if not has_meta("reading_fonts_ready"):
		var font:=SystemFont.new();font.font_names=PackedStringArray(["Helvetica Neue","PingFang SC","Arial Unicode MS"]);font.allow_system_fallback=true
		var unicode_font:=SystemFont.new();unicode_font.font_names=PackedStringArray(["Arial Unicode MS"]);unicode_font.allow_system_fallback=true;font.fallbacks=[unicode_font]
		for control in [name_input,outcome,command_input,setup_notice,saved_characters]:control.add_theme_font_override("font",font)
		transcript.add_theme_font_override("normal_font",font)
		saved_characters.get_popup().add_theme_font_override("font",font)
		for label in party_labels.values():label.add_theme_font_override("font",font)
		set_meta("reading_fonts_ready",true)
	# Capture unscaled setup geometry before changing font minimum sizes.
	for control in setup_panel.get_children():
		if control is Control and not control.has_meta("layout_100"):control.set_meta("layout_100",Rect2(control.position,control.size))
	apply_interface_fonts(self,enabled)
	# Layout uses stable 100% geometry, never the previous enlarged geometry.
	var factor:=1.25 if enabled else 1.0
	for control in setup_panel.get_children():
		if control is Control:
			var rect:Rect2=control.get_meta("layout_100");control.position=rect.position*factor;control.size=rect.size*factor
	setup_panel.size=Vector2(960,502)*factor;setup_panel.position=(Vector2(1280,980)-setup_panel.size)/2
	setup_preview.position=Vector2(754,330)*factor
	help_panel.size=Vector2(1200,890) if enabled else Vector2(960,710);help_panel.position=(Vector2(1280,980)-help_panel.size)/2
	help_copy.size=Vector2(1144,775) if enabled else Vector2(904,596)
	help_panel.get_child(1).position.y=816 if enabled else 642
	help_panel.get_child(1).size.y=50 if enabled else 44
	for button in text_switches:
		button.text=("Text: 125%" if enabled else "Text: 100%") if button.get_parent()==setup_panel else ("125%" if enabled else "100%")
		button.tooltip_text="Change all interface text to "+("100%" if enabled else "125%")
	status.size.x=790;status.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	utility_panel.position.x=850
	command_input.size.y=40 if enabled else 34;command_input.position.y=926 if enabled else 930
	for label in party_labels.values():label.size=Vector2(180,30) if enabled else Vector2(144,24);label.position.x=-label.size.x/2
	last_context=""
	if save_pref:
		var error:=ERR_UNAUTHORIZED if ExperienceSave.linked(session_root) or ExperienceSave.linked(session_root.path_join("presentation.cfg")) else DirAccess.make_dir_recursive_absolute(session_root)
		var prefs:=ConfigFile.new();prefs.set_value("display","large_text",enabled)
		if error==OK:error=prefs.save(session_root.path_join("presentation.cfg"))
		if error!=OK:
			push_warning("PRESENTATION_SAVE_FAILED code=%d" % error)
			say("Text size changed for this session, but the preference could not be saved. Try the text-size switch again after restoring folder access.")
func apply_interface_fonts(node:Node,enabled:bool) -> void:
	if node.is_queued_for_deletion():return
	if node is Control:
		var keys:Array=["normal_font_size","bold_font_size","italics_font_size","bold_italics_font_size","mono_font_size"] if node is RichTextLabel else ["font_size"]
		for key in keys:
			var meta:String="font_100_"+key
			if not node.has_meta(meta):node.set_meta(meta,node.get_theme_font_size(key))
			node.add_theme_font_size_override(key,roundi(float(node.get_meta(meta))*(1.25 if enabled else 1.0)))
	if node is OptionButton:apply_interface_fonts(node.get_popup(),enabled)
	for child in node.get_children():apply_interface_fonts(child,enabled)
func update_reading() -> void:
	transcript.visible=history_open;outcome.visible=not history_open
	var reading_top:float=maxf(690,audience.position.y+audience.get_line_count()*audience.get_line_height()+8) if audience.visible else 690
	for control in [outcome,transcript]:control.position.y=reading_top;control.size.y=895-reading_top
func say(text:String) -> void:
	if text.is_empty():return
	# Current outcomes remain pinned; routine step accounting remains inspectable in History.
	super.say(text)
	if not text.begins_with("You:") and not text.begins_with("Intention finished") and not text.begins_with("Moved "):
		last_outcome=text
		var shown:=text
		if expedition.reported and text==result_text():
			var r:Dictionary=expedition.result
			shown="Relay core delivered. The report paid 8 material once.\nAt the report: pet %s; traveler %s (%s).\nNow: %d material carried, %d stored. Home and local work remain open.\nHistory has the route, support and task details." % [r.pet,r.recruit,r.membership,progression.material,home.stored]
		outcome.text=shown if shown.length()<=(390 if text_large else 470) else shown.left(345 if text_large else 425)+"… Full response in History."
		outcome.size=Vector2(760,205)
func objective_text() -> String:
	if phase=="selection":return "Try the powers, then choose one"
	if journey=="arrival":return "Reach the package"
	if journey=="encounter":return "Clear the creature, then collect the package"
	if not package_taken:return "Collect the welcome package"
	if reward=="":return "Choose supplies at the shelter desk"
	if not progression.kit_claimed:return "Collect your preparation kit at the hub bench"
	if expedition.reported:return "Chapter complete — keep exploring"
	if expedition.objective:return "Report the core at the hub board for 8 material"
	if location=="objective":return "Clear the warden or retreat" if not expedition.cleared else "Choose a crossing, then recover the core"
	return "Enter the expedition when you are ready"
func describe_place() -> String:
	if location=="approach":return "Expedition approach. North range: harmless practice. Breach: optional repeatable danger. East barrier: full relay expedition. Inspect barrier for assignment, or ask what routes are available."
	if location=="objective" and not expedition.cleared:return "The warden blocks the way to the relay core. You can retreat with the whole party and return later."
	if location=="objective":return objective_text()+". "+("Warden %d/12; four AP. Shoot, power, guard, move, End turn or retreat. Read the actual outcome before choosing again."%expedition.warden if not expedition.cleared else "Choose live lane for a short dangerous crossing, or open the dry north passage. Ask about routes. "+("Return and file relay report; the socket stays empty." if expedition.objective else "Go to core after crossing and recover routing core."))
	return super.describe_place()
func result_text() -> String:return character.name+": "+super.result_text().replace("OPENING CHAPTER COMPLETE — Relay receipt.","Chapter complete.")
func question(text:String) -> String:
	if "end turn" in text or "ap"==text or "action point" in text or "stop" in text or "controls" in text:return controls_text()
	if "name" in text or "who am i" in text:return character.name+", caught shopping during the takeover. Your "+character.appearance+" jacket changes appearance only."
	if "heal" in text or "treat" in text:return care_text()
	if "next" in text or "objective" in text or "where am i" in text:return objective_text()+". "+describe_place()
	if "can i do" in text or "help" in text:return objective_text()+". Targets here: "+", ".join(targets().keys())+". Try inspect or go to a target; use the current choices for actions."
	return super.question(text)
func world_clause(text:String) -> Dictionary:
	if text in ["help","controls"]:return {"question":"controls"}
	if text in ["who am i","where am i","what now","what next"]:return {"question":"who am i" if "who" in text else "next"}
	if text=="walk safely":return {"actions":[{"verb":"safe_walk"}]}
	var aliases:={"start expedition":"enter expedition","begin expedition":"enter expedition","return to shelter":"go to shelter","report back":"file relay report","hand in core":"file relay report","pick up core":"recover routing core","turn wheel":"turn isolation wheel","heal pet":"treat pet","heal companion":"treat companion"}
	return super.world_clause(aliases.get(text,text))
func submit(text:String,request_id:String="",context_epoch:int=-1) -> bool:
	if setup_open:return false
	return super.submit(text,request_id,context_epoch)
func execute(a:Dictionary) -> bool:
	if a.verb=="safe_walk":
		if location!="objective" or not expedition.cleared or not care_idle():return reject("Safe walking requires a cleared relay yard. Clear the warden first; no turn was advanced.")
		safe_walking=true;say("Safe walking ON: clear floor costs no AP. Choose a dry route and go to drainage, then core. Stops before live floor, blocks, travel, Stop, Pause or failed save. No enemy turn or automatic action.");return true
	return super.execute(a)
func stop_work(reason:String) -> void:
	safe_walking=false;super.stop_work(reason)
func fail_work(reason:String) -> void:
	safe_walking=false;super.fail_work(reason)
	if "AP" in reason:say(reason+" End turn deliberately, then repeat your destination command. The old plan will not resume.")
	elif "block" in reason.to_lower() or "reachable" in reason.to_lower():say(reason+" Inspect the named target or choose another clear destination. Exact steps never route around an obstruction.")
func yard_move(target:Vector2i,dashing:bool) -> bool:
	if not safe_walking or dashing:return super.yard_move(target,dashing)
	if not expedition.cleared or not care_idle():safe_walking=false;return reject("Safe walking stopped: a ready cleared yard is required.")
	if not expedition.objective and target.y==3 and target.x in [6,7]:safe_walking=false;return reject("Safe walking stopped before live floor. Choose a dry passage or make an ordinary paid movement decision.")
	if distance(player_cell,target)!=1 or not floor_free(target):safe_walking=false;return reject("Safe walking stopped at blocked or nonadjacent floor. No AP spent.")
	if target.x>=6 and expedition.route=="":safe_walking=false;return reject("Select the live, drainage or maintenance route before crossing.")
	var before:=snapshot();var start:=player_cell;player_cell=target;face(point(target)-point(start))
	if target.x>=8 and not expedition.crossed:expedition.crossed=true
	pet.position=point(target)+Vector2(-18,14);pet.reset_path()
	if recruit_status=="joined":recruit.position=point(target)+Vector2(18,8);recruit.reset_path()
	if not commit_expedition(before,"Safe walking · AP unchanged · stop before live floor"):safe_walking=false;return false
	animate("move",0.4,point(start),point(target));return true
func travel(destination:String) -> bool:
	safe_walking=false;return super.travel(destination)
func toggle_pause() -> void:
	safe_walking=false
	if setup_open:return
	if help_panel.visible:help_panel.hide();setup_cover.hide();get_tree().paused=false;command_input.grab_focus();return
	super.toggle_pause()
	if not get_tree().paused:command_input.grab_focus()
func refresh_ui() -> void:
	super.refresh_ui()
	if not experience_ready:return
	feedback.hide();update_reading();pause_scrim.visible=pause_panel.visible
	pause_panel.position.y=maxf(12,(980-pause_panel.size.y)/2)
	audience.text=audience.text.replace("Outside audience (characters cannot see this):", "Outside audience (not visible to characters):")
	if phase!="selection" and phase!="defeat" and not active_breach() and care.aid_actor=="" and location!="objective":status.text=objective_text()
	if journey=="arrival" and phase!="selection":detail.text="Type go to package or choose it below. Entering the assessment starts danger."
	if location=="home":detail.text="Arrange furnishings, use storage or rest. Your home is private."
	if location=="objective" and not expedition.cleared and phase!="defeat":
		status.text="Warden’s turn" if phase=="enemy" else "Your turn"
		detail.text="Choose an action. End turn lets allies and the warden respond; Retreat brings everyone back."
	if get_tree().paused:pause_notice.text=pause_notice.text.replace("In Pause, choose", "Choose")
	if get_tree().paused and not pause_recover.visible:
		pause_notice.text="Save and quit keeps your progress." if stable_boundary() else "Resume to finish the current action before saving." if phase!="selection" and phase!="defeat" else "Choose a power before saving." if phase=="selection" else "Continue your saved game to try again."
func refresh_choices() -> void:
	super.refresh_choices()
	if not experience_ready:return
	if location=="objective" and expedition.cleared:
		var b:=Button.new();b.theme=GlassUI.make_theme();b.text="Walk safely";choices.add_child(b);var binding:=epoch;b.pressed.connect(func():submit("walk safely","",binding))
	for button in choices.get_children():
		if button is Button:
			var labels:={"To hub":"Go to hub","To concourse":"Go to concourse","Party / gear":"Party and gear","Look / tactics":"Look around","Range / train":"Practice range","Return party":"Retreat together","Objective":"Chapter result","Arrange Reading chair":"Arrange chair","Arrange Task lamp":"Arrange lamp","Arrange Keepsake shelf":"Arrange shelf","Home / costs":"Furnishing costs","Deposit 1":"Store 1 material","Withdraw 1":"Take 1 material"}
			button.text=labels.get(button.text,button.text)
			button.add_theme_font_size_override("font_size",16);button.custom_minimum_size.y=44;apply_interface_fonts(button,text_large)
	if location=="home" and home_page!="placement":
		var position:=0
		for label in ["Go to hub","Rest"]:
			for button in choices.get_children():
				if button is Button and not button.is_queued_for_deletion() and button.text==label:
					choices.move_child(button,position);position+=1;break
func _unhandled_key_input(event:InputEvent) -> void:
	if setup_open:return
	super._unhandled_key_input(event)
func _unhandled_input(event:InputEvent) -> void:
	if setup_open:return
	super._unhandled_input(event)
func _process(delta:float) -> void:
	if setup_open and experience_ready:
		refresh_ui();return
	super._process(delta)
	if not experience_ready:return
	if get_tree().paused:safe_walking=false;return
	objective_now.text=objective_text()
	if care_motion!="":activity.text=message
	elif safe_walking:activity.text="Walking on safe floor. No AP spent; Stop cancels."
	elif current.is_empty() and work.is_empty():activity.text="Type a command, choose an action, or click the world to move."
	else:
		var verbs:={"step":"Walking","go":"Walking","fetch":"Pet is fetching","deferred":"Following your plan","ready":"Following your plan"}
		activity.text="%s · %d actions finished · %d steps taken · %d actions left" % [verbs.get(current.get("verb","ready"),"Following your plan"),completed,steps_done,work.size()]
	update_motion_presentation(delta)
func update_motion_presentation(delta:float) -> void:
	motion_phase+=delta*11.0
	var movement:Vector2=human.position-actor_previous.get(human,human.position)
	var walking:=movement.length()>0.05 and movement.length()<80
	var step:=sin(motion_phase) if walking else 0.0
	for animation in human.animations.values():animation.pause()
	for id in human.groups:
		for part in rest_pivots[id]:
			var joint:Node2D=human.groups[id].get_node(part);joint.position=rest_pivots[id][part];joint.rotation=0
			var sign_value:=1.0 if part.begins_with("near") else -1.0
			if part.ends_with("leg"):
				joint.rotation=step*sign_value*(0.26 if id=="side" else 0.035)
				if id!="side":joint.position.y+=step*sign_value*38
			elif part.ends_with("arm"):joint.rotation=-step*sign_value*0.14
			elif part=="torso" or part=="head":joint.position.y-=absf(step)*9
			if busy and motion in ["bolt","blast","shield","use"] and part=="near_arm":joint.rotation=-0.4*sin(PI*minf(clock/maxf(duration,0.01),1.0))
	var pet_movement:Vector2=pet.position-actor_previous.get(pet,pet.position)
	pet.picture.position.y=-42+absf(sin(motion_phase))*1.2 if pet_movement.length()>0.05 else -42
	pet.picture.rotation=sin(motion_phase)*0.04 if pet_movement.length()>0.05 else 0.0
	if care.pet=="injured":pet.picture.rotation=0.12;pet.picture.position.y=-36
	if is_instance_valid(recruit.visual):
		var recruit_movement:Vector2=recruit.position-actor_previous.get(recruit,recruit.position)
		recruit.visual.update_motion(recruit_movement,recruit_movement.length()>0.05 and care.recruit=="healthy",delta)
		recruit.visual.rotation=0
		recruit.visual.scale=Vector2.ONE;recruit.visual.position.y=0
		if care.recruit=="downed":
			recruit.visual.facing="toward";recruit.visual.update_motion(Vector2.ZERO,false,0)
			for part in recruit.visual.PARTS:
				var joint:Node2D=recruit.visual.views.toward.get_node(part)
				if part.ends_with("leg"):
					joint.position.y+=12;joint.rotation=0.9 if part.begins_with("near") else -0.9
				else:joint.position.y+=36
				if part.ends_with("arm"):joint.rotation=0.25 if part.begins_with("near") else -0.25
	party_labels[human].text=character.name
	party_labels[human].text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	party_labels[pet].position=Vector2(-38,16);party_labels[pet].size=Vector2(76,22)
	party_labels[recruit].position=Vector2(-62,25);party_labels[recruit].size=Vector2(124,22)
	party_labels[pet].text="Needs care" if care.pet=="injured" else "Fetching" if not fetch_state.is_empty() or not supply_trip.is_empty() or care_motion=="turn" and care_cover else "Pet"
	party_labels[recruit].text="Rescue sling · care" if care.recruit=="downed" else "Supporting" if care_beam>0 else "Traveler"
	# Tall cutouts overlap neighboring cells by design; suppress overlapping
	# floating labels while the persistent party HUD retains every condition.
	party_labels[pet].visible=pet.position.distance_to(human.position)>96
	party_labels[recruit].visible=recruit.position.distance_to(human.position)>96
	for actor in [human,pet,recruit]:actor_previous[actor]=actor.position
	queue_redraw()
func _draw() -> void:
	super._draw()
	if not experience_ready:return
	for actor in [human,pet,recruit]:
		if actor.visible:draw_ellipse_shadow(actor.position)
	if care.recruit=="downed" and recruit.visible:
		draw_line(recruit.position+Vector2(-22,-12),recruit.position+Vector2(22,-12),Color("c6d8de"),4,true)
		if care_motion!="" or busy and motion in ["move","dash"]:draw_line(human.position+Vector2(0,-28),recruit.position+Vector2(0,-12),Color("e6c78c"),2,true)
func draw_ellipse_shadow(at:Vector2) -> void:
	var points:=PackedVector2Array()
	for i in range(25):points.append(at+Vector2(cos(i*TAU/24)*17,sin(i*TAU/24)*5))
	draw_colored_polygon(points,Color(0.06,0.08,0.10,0.28))

func _notification(what:int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST and experience_ready:
		if setup_open or phase=="selection":get_tree().quit();return
		safe_walking=false;get_tree().paused=true;message="Your session is still open. Use Save and quit to preserve this character; Resume returns to play.";return
	super._notification(what)
