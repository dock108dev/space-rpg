extends "res://scripts/adventure_save.gd"
const World=preload("res://scripts/world_locations.gd")
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("world_version",0)!=1:return false
	if not data.get("tasks",null) is Dictionary or data.tasks.size()!=3:return false
	for id in ["supplies","access","survey"]:
		if data.tasks.get(id,"") not in ["available","skipped","completed"]:return false
	if data.get("supply_method",null) not in ["","personal","pet"]:return false
	if (data.tasks.supplies=="completed")!=(data.supply_method!=""):return false
	if data.get("location","") not in World.IDS:return false
	var opened:bool=data.tasks.access=="completed"
	var cell:Variant=data.get("player",null)
	if not cell is Array or cell.size()!=2 or not integer(cell[0],0,11) or not integer(cell[1],0,6):return false
	if not World.cell_ok(data.location,Vector2i(int(cell[0]),int(cell[1])),opened):return false
	if not World.pixel_ok(data.location,data.get("pet_position",null),opened):return false
	var recruit_location:String=data.location if data.get("recruit_status","")=="joined" else "shelter"
	if not World.pixel_ok(recruit_location,data.get("recruit_position",null),opened):return false
	if data.location in ["hub","approach"] or data.tasks.values().any(func(s):return s!="available"):
		if not data.get("package",false) or data.get("phase","")!="success":return false
	# Validate all inherited chapter/adventure invariants against a safe coordinate
	# projection; actual world coordinates were validated above, never written back.
	var base:Dictionary=data.duplicate(true)
	if data.location in ["hub","approach"]:
		base.location="shelter";base.player=[1,5];base.pet_position=[320,638]
		if base.recruit_status=="joined":base.recruit_position=[256,638]
	return super.valid(base)
