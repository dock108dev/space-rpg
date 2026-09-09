extends RefCounted
# Immutable snapshots: never overwrite or delete an existing development save.
var directory := ""
var notice := ""
const POWERS := ["blast", "shield", "dash"]
const BLOCKS := [Vector2i(5,3),Vector2i(5,4),Vector2i(6,3),Vector2i(3,1)]
func _init(path:String="") -> void:
	directory=path
func cell_ok(value:Variant) -> bool:
	if not value is Array or value.size()!=2:return false
	for n in value:
		if not (n is float or n is int) or not is_finite(float(n)) or float(n)!=floor(float(n)):return false
	var v:=Vector2i(int(value[0]),int(value[1]))
	return v.x>=0 and v.x<12 and v.y>=0 and v.y<7 and v not in BLOCKS
func valid(data:Variant) -> bool:
	if not data is Dictionary:return false
	for key in ["version","sequence","kind","power","player","enemy","hp","enemy_hp","ap","shield","prepared","aim","used","turn","phase"]:
		if not data.has(key):return false
	if data.version!=1 or data.power not in POWERS or data.kind not in ["manual","auto"]:return false
	for key in ["sequence","hp","enemy_hp","ap","shield","turn"]:
		var n:Variant=data[key]
		if not (n is float or n is int) or not is_finite(float(n)) or float(n)!=floor(float(n)):return false
	if data.sequence<1 or data.sequence>999999999 or data.turn<1 or data.turn>999999:return false
	if data.hp<1 or data.hp>6 or data.enemy_hp<0 or data.enemy_hp>6 or data.ap<0 or data.ap>4 or data.shield<0 or data.shield>2:return false
	if data.shield>0 and data.power!="shield":return false
	if not data.prepared is bool or not data.used is bool:return false
	if not cell_ok(data.player) or not cell_ok(data.enemy) or not cell_ok(data.aim):return false
	if data.player==data.enemy:return false
	var enemy:=Vector2i(int(data.enemy[0]),int(data.enemy[1]))
	var aim:=Vector2i(int(data.aim[0]),int(data.aim[1]))
	if data.prepared and absi(enemy.x-aim.x)+absi(enemy.y-aim.y)!=1:return false
	if data.phase not in ["player","success"]:return false
	if (data.phase=="success")!=(data.enemy_hp==0):return false
	return true
func files() -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(directory):return PackedStringArray()
	return DirAccess.get_files_at(directory)
func next_sequence() -> int:
	var next:=1
	for file in files():
		# Include malformed and interrupted entries so old files are never overwritten.
		if file.begins_with("snapshot-"):
			var number:=file.trim_prefix("snapshot-").get_slice(".",0)
			if number.is_valid_int():next=maxi(next,int(number)+1)
	return next
func write(state:Dictionary,kind:String) -> bool:
	notice=""
	if DirAccess.make_dir_recursive_absolute(directory)!=OK:notice="Save failed: cannot create development folder.";return false
	# Atomic directory creation serializes writers; never clobber another snapshot.
	var lock_path:=directory.path_join(".writing")
	if DirAccess.make_dir_absolute(lock_path)!=OK:
		notice="Save blocked by another or interrupted writer. Existing saves remain loadable; see save recovery notes."
		return false
	var ok:=write_locked(state,kind)
	DirAccess.remove_absolute(lock_path)
	return ok
func write_locked(state:Dictionary,kind:String) -> bool:
	var data:=state.duplicate(true);data.version=1;data.sequence=next_sequence();data.kind=kind
	if not valid(data):notice="Save rejected: state is outside supported boundaries.";return false
	var base:=directory.path_join("snapshot-%09d" % data.sequence)
	var file:=FileAccess.open(base+".tmp",FileAccess.WRITE)
	if file==null:notice="Save failed: cannot write snapshot.";return false
	file.store_string(JSON.stringify(data));file.flush()
	var error:=file.get_error();file.close()
	if error!=OK:notice="Save interrupted: previous snapshots preserved.";return false
	if DirAccess.rename_absolute(base+".tmp",base+".json")!=OK:notice="Save could not finish; previous snapshots preserved.";return false
	notice="%s save %d stored." % [kind.capitalize(),data.sequence]
	return true
func latest() -> Dictionary:
	var chosen:Dictionary={};var skipped:=0
	for name in files():
		if not name.begins_with("snapshot-"):continue
		if not name.ends_with(".json"):skipped+=1;continue
		var path:=directory.path_join(name)
		var file:=FileAccess.open(path,FileAccess.READ)
		if file==null:skipped+=1;continue
		if file.get_length()>32768:file.close();skipped+=1;continue
		var parser:=JSON.new()
		var error:=parser.parse(file.get_as_text());file.close()
		if error!=OK:skipped+=1;continue
		var parsed:Variant=parser.data
		if not valid(parsed):skipped+=1;continue
		if name!="snapshot-%09d.json" % int(parsed.sequence):skipped+=1;continue
		if chosen.is_empty() or parsed.sequence>chosen.sequence:chosen=parsed
	notice="No supported save found." if chosen.is_empty() else "Loaded %s save %d." % [chosen.kind,int(chosen.sequence)]
	if skipped>0:notice+=" Skipped %d interrupted or invalid save(s); files preserved." % skipped
	return chosen
