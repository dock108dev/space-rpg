extends RefCounted
# Opening-area geometry used by runtime movement and save validation.
const IDS := ["concourse", "shelter"]
const PACKAGE := Vector2i(1,3)
const CONCOURSE_DOOR := Vector2i(11,1)
const SHELTER_DOOR := Vector2i(0,5)
const SHELTER_REWARD := Vector2i(5,1)
const RECRUIT := Vector2i(7,2)
const CACHE := Vector2i(9,5)
const ORIGIN := Vector2(256,254)
const STEP := 64.0
const CONCOURSE_BLOCKS := [Vector2i(5,3),Vector2i(5,4),Vector2i(6,3),Vector2i(3,1)]
const SHELTER_BLOCKS := [Vector2i(5,1),Vector2i(2,1),Vector2i(3,1),Vector2i(2,2),Vector2i(8,2),Vector2i(8,3),Vector2i(9,5)]
static func blocks(location:String) -> Array:
	return SHELTER_BLOCKS if location=="shelter" else CONCOURSE_BLOCKS
static func inside(location:String,cell:Vector2i) -> bool:
	return location in IDS and cell.x>=0 and cell.x<12 and cell.y>=0 and cell.y<7
static func cell_ok(location:String,cell:Vector2i) -> bool:
	return inside(location,cell) and cell not in blocks(location)
static func point(cell:Vector2i) -> Vector2:return ORIGIN+Vector2(cell)*STEP
static func cell_at(position:Vector2) -> Vector2i:return Vector2i(((position-ORIGIN)/STEP).round())
static func spawn(location:String) -> Vector2i:return Vector2i(1,5) if location=="shelter" else Vector2i(10,1)
static func pixel_ok(location:String,value:Variant) -> bool:
	if not value is Array or value.size()!=2:return false
	for n in value:
		if not (n is int or n is float) or not is_finite(float(n)):return false
	var p:=Vector2(float(value[0]),float(value[1]))
	if not Rect2(224,222,768,448).has_point(p):return false
	for block in blocks(location):
		if Rect2(point(block)-Vector2(26,26),Vector2(52,52)).has_point(p):return false
	return true
