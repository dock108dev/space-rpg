extends RefCounted
const NAMES={"chair":"Reading chair","lamp":"Task lamp","shelf":"Keepsake shelf"}
const SOCKETS={"window":Vector2i(3,1),"alcove":Vector2i(7,1),"reading nook":Vector2i(3,4),"far wall":Vector2i(8,4)}
const LOCKER=Vector2i(10,1)
static func initial() -> Dictionary:return {"owned":false,"furniture":{"chair":-1,"lamp":-1,"shelf":-1},"storage":false,"stored":0}
static func occupied(h:Dictionary) -> Array:
	var cells:Array=[LOCKER]
	for slot in h.furniture.values():
		if slot>0:cells.append(SOCKETS.values()[int(slot)-1])
	return cells
static func cell_ok(c:Vector2i,h:Dictionary) -> bool:return c.x>=0 and c.x<12 and c.y>=0 and c.y<7 and c not in occupied(h)
static func pixel_ok(v:Variant,h:Dictionary) -> bool:
	if not v is Array or v.size()!=2:return false
	for n in v:
		if not (n is int or n is float) or not is_finite(float(n)):return false
	var p:=Vector2(v[0],v[1])
	if not Rect2(224,222,768,448).has_point(p):return false
	for c in occupied(h):
		if Rect2(Vector2(256,254)+Vector2(c)*64-Vector2(26,26),Vector2(52,52)).has_point(p):return false
	return true
