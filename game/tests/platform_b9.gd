extends SceneTree
var failures:Array=[]
var resources:Array=[]
func _initialize() -> void:call_deferred("run")
func inspect_folder(path:String) -> void:
	for file in DirAccess.get_files_at(path):
		var original:=path.path_join(file).trim_suffix(".remap").trim_suffix(".import")
		if original.get_extension() in ["png","svg","tscn","gd"]:
			var ok:=ResourceLoader.exists(original) and ResourceLoader.load(original)!=null
			resources.append({"path":original,"loaded":ok})
			if not ok:failures.append(original)
	for folder in DirAccess.get_directories_at(path):
		if not folder.begins_with("."):inspect_folder(path.path_join(folder))
func run() -> void:
	inspect_folder("res://art");inspect_folder("res://scripts");inspect_folder("res://scenes")
	var scene=load("res://scenes/player_experience.tscn").instantiate();scene.auto_focus_pause=false;root.add_child(scene);await process_frame
	var font:Font=scene.name_input.get_theme_font("font")
	var characters:Dictionary={}
	for c in "Mira Étoile 星 Ω Ж":characters[c]=font.has_char(c.unicode_at(0))
	var info:Dictionary={"feature":OS.has_feature("b9_personal"),"executable":OS.get_executable_path(),"user_data":OS.get_user_data_dir(),"session_root":scene.session_root,"main_scene":ProjectSettings.get_setting("application/run/main_scene"),"audio_driver":AudioServer.get_driver_name(),"renderer":RenderingServer.get_current_rendering_method(),"resources":resources,"failures":failures,"font_characters":characters,"window":[root.size.x,root.size.y],"minimum":[root.min_size.x,root.min_size.y],"system_fonts_copied":false}
	print("B9_PLATFORM ",JSON.stringify(info))
	var f:=FileAccess.open(OS.get_environment("B9_PLATFORM_OUTPUT"),FileAccess.WRITE);f.store_string(JSON.stringify(info,"  "));f.close()
	quit(0 if failures.is_empty() and info.feature and info.audio_driver=="Dummy" and info.main_scene=="res://scenes/b9_start.tscn" else 1)
