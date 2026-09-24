extends RefCounted
const Base=preload("res://scripts/chapter_locations.gd")
const IDS=["concourse","shelter","hub","approach"]
const DOORS={"concourse":{"shelter":Vector2i(11,1)},"shelter":{"concourse":Vector2i(0,5),"hub":Vector2i(11,5)},"hub":{"shelter":Vector2i(0,5),"approach":Vector2i(11,1)},"approach":{"hub":Vector2i(0,5)}}
const HUB_BLOCKS=[Vector2i(5,1),Vector2i(5,2),Vector2i(5,4),Vector2i(5,5),Vector2i(3,2),Vector2i(8,4)]
const APPROACH_BLOCKS=[Vector2i(3,2),Vector2i(4,2),Vector2i(7,4),Vector2i(8,4),Vector2i(9,1)]
static func blocks(id:String,opened:bool=false) -> Array:
	if id=="hub":return HUB_BLOCKS+([] if opened else [Vector2i(5,3)])
	if id=="approach":return APPROACH_BLOCKS
	return Base.blocks(id)
static func cell_ok(id:String,cell:Vector2i,opened:bool=false) -> bool:
	return id in IDS and cell.x>=0 and cell.x<12 and cell.y>=0 and cell.y<7 and cell not in blocks(id,opened)
static func pixel_ok(id:String,value:Variant,opened:bool) -> bool:
	if not value is Array or value.size()!=2:return false
	for n in value:
		if not (n is int or n is float) or not is_finite(float(n)):return false
	var p:=Vector2(float(value[0]),float(value[1]))
	if not Rect2(224,222,768,448).has_point(p):return false
	for cell in blocks(id,opened):
		if Rect2(Base.point(cell)-Vector2(26,26),Vector2(52,52)).has_point(p):return false
	return true
