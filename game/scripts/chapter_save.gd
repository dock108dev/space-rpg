extends "res://scripts/tactical_save.gd"
# Reuse immutable atomic storage, never the S03/S04 one-map validator.
const Locations=preload("res://scripts/chapter_locations.gd")
const CHAPTER_VERSION:=1
func integer(value:Variant,low:int,high:int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value)==floor(float(value)) and value>=low and value<=high
func cell_valid(location:String,value:Variant) -> bool:
	return value is Array and value.size()==2 and integer(value[0],0,11) and integer(value[1],0,6) and Locations.cell_ok(location,Vector2i(int(value[0]),int(value[1])))
func valid(data:Variant) -> bool:
	if not data is Dictionary:return false
	for key in ["version","chapter_version","sequence","kind","location","journey","power","player","enemy","hp","enemy_hp","ap","shield","prepared","aim","used","turn","phase","package","learned","cache","kits","reward","recruit_status","pet_position","recruit_position"]:
		if not data.has(key):return false
	if data.version!=1 or data.chapter_version!=CHAPTER_VERSION or data.kind not in ["auto","manual"]:return false
	if data.location not in Locations.IDS or data.power not in POWERS:return false
	if data.journey not in ["arrival","encounter","package","shelter","complete"]:return false
	if data.reward not in ["","security","equipment","opportunity"]:return false
	if data.recruit_status not in ["available","declined","joined","waiting"]:return false
	for key in ["prepared","used","package","learned","cache"]:
		if not data[key] is bool:return false
	for spec in [["sequence",1,999999999],["turn",1,999999],["hp",1,6],["enemy_hp",0,6],["ap",0,4],["shield",0,2],["kits",0,3]]:
		if not integer(data[spec[0]],spec[1],spec[2]):return false
	if data.shield>0 and data.power!="shield":return false
	if not cell_valid(data.location,data.player):return false
	if not cell_valid("concourse",data.enemy) or not cell_valid("concourse",data.aim):return false
	if not Locations.pixel_ok(data.location,data.pet_position):return false
	var recruit_location:String=data.location if data.recruit_status=="joined" else "shelter"
	if not Locations.pixel_ok(recruit_location,data.recruit_position):return false
	if data.phase not in ["player","success"]:return false
	if (data.phase=="success")!=(data.enemy_hp==0):return false
	if data.enemy_hp>0 and (data.location!="concourse" or data.player==data.enemy):return false
	if data.prepared:
		if data.phase!="player" or data.journey!="encounter":return false
		if absi(int(data.enemy[0])-int(data.aim[0]))+absi(int(data.enemy[1])-int(data.aim[1]))!=1:return false
	if data.package!=data.learned:return false
	if data.cache and not data.learned:return false
	if data.kits>(1 if data.cache else 0)+(2 if data.reward=="security" else 0):return false
	if (data.journey=="complete")!=(data.reward!=""):return false
	if data.location=="shelter" and not data.package:return false
	if data.recruit_status!="available" and not data.package:return false
	match data.journey:
		"arrival":
			if data.phase!="player" or data.enemy_hp!=6 or data.hp!=6 or data.package or data.cache or data.used or data.prepared:return false
		"encounter":
			if data.phase!="player" or data.package:return false
		"package":
			if data.phase!="success" or data.package:return false
		"shelter","complete":
			if data.phase!="success" or not data.package:return false
	return true
func write(state:Dictionary,kind:String) -> bool:
	# Writer marker makes B2 recovery distinguish a live writer from a stale lock.
	notice=""
	var ancestor:=directory
	while not ancestor.is_empty():
		if FileAccess.file_exists(ancestor):
			notice="Save failed: part of the B2 save path is a file. Session remains open; restore folder access and Retry.";return false
		var parent:=ancestor.get_base_dir()
		if parent==ancestor:break
		ancestor=parent
	if DirAccess.make_dir_recursive_absolute(directory)!=OK:
		notice="Save failed: cannot create the B2 save folder. Session remains open; choose Retry after restoring access.";return false
	var lock_path:=directory.path_join(".writing")
	if DirAccess.make_dir_absolute(lock_path)!=OK:
		notice="Save blocked by an active or interrupted writer. Existing saves are intact. Use Recover save access, then Retry.";return false
	var marker:=FileAccess.open(lock_path.path_join("owner.json"),FileAccess.WRITE)
	if marker==null:
		DirAccess.remove_absolute(lock_path);notice="Save failed: cannot create writer marker. Session remains open.";return false
	marker.store_string(JSON.stringify({"pid":OS.get_process_id()}));marker.close()
	var ok:=write_locked(state,kind)
	DirAccess.remove_absolute(lock_path.path_join("owner.json"));DirAccess.remove_absolute(lock_path)
	return ok
func recover_interrupted_writer() -> bool:
	var lock_path:=directory.path_join(".writing")
	if not DirAccess.dir_exists_absolute(lock_path):
		notice="Save access ready. Retry Save, or Continue the latest valid snapshot.";return true
	var marker_path:=lock_path.path_join("owner.json")
	if FileAccess.file_exists(marker_path):
		var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(marker_path))
		if parsed is Dictionary and parsed.has("pid") and integer(parsed.pid,1,2147483647) and writer_is_running(int(parsed.pid)):
			notice="Another B2 process still owns save access. Close that session before retrying. No files changed.";return false
	else:
		# A live writer may have just made the directory and not written its marker yet.
		if Time.get_unix_time_from_system()-FileAccess.get_modified_time(lock_path)<10:
			notice="Writer status is settling. Wait ten seconds, then retry recovery. Existing saves are intact.";return false
	# Preserve all interrupted material, including the lock; never remove snapshots.
	var archive:=directory.path_join("interrupted-writer-%d-%d" % [Time.get_unix_time_from_system(),Time.get_ticks_usec()])
	if DirAccess.rename_absolute(lock_path,archive)!=OK:
		notice="Recovery could not preserve the interrupted writer. Restore folder access and retry.";return false
	notice="Interrupted writer preserved. Save access recovered; Retry Save. Existing snapshots are unchanged.";return true
func recover_writer() -> bool:return recover_interrupted_writer()

func writer_is_running(pid:int) -> bool:
	if pid==OS.get_process_id():return true
	# Godot's process helper uses waitpid on this Mac and cannot inspect a
	# separately launched peer. ps performs a read-only process-existence query.
	var output:Array=[]
	return OS.execute("/bin/ps",PackedStringArray(["-p",str(pid),"-o","pid="]),output,true)==0
