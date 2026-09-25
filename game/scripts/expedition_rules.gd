extends RefCounted
const WARDEN:=Vector2i(4,3)
const COVER:=Vector2i(3,4)
const CORE:=Vector2i(10,3)
const WHEEL:=Vector2i(4,6)
static func initial() -> Dictionary:
	return {"entered":false,"warden":12,"cleared":false,"points":4,"guard":0,"round":0,"cover":false,"wheel":false,"route":"","crossed":false,"objective":false,"reported":false,"assists":0,"retreats":0,"exposures":0,"result":{}}
static func blocks(e:Dictionary) -> Array:
	var b:Array=[Vector2i(2,1),Vector2i(3,1),Vector2i(9,5),CORE,WHEEL]
	for y in [1,2,4,5,6]:b.append(Vector2i(6,y))
	if e.route not in ["drainage","maintenance"] and not e.objective:b.append(Vector2i(6,0))
	if e.route in ["drainage","maintenance"] and not e.objective:
		b.append(Vector2i(6,3));b.append(Vector2i(7,3))
	if not e.cleared:
		b.append(WARDEN);b.append(Vector2i(6,3))
	return b
static func cell_ok(c:Vector2i,e:Dictionary) -> bool:return c.x>=0 and c.x<12 and c.y>=0 and c.y<7 and c not in blocks(e)
static func pixel_ok(v:Variant,e:Dictionary) -> bool:
	if not v is Array or v.size()!=2:return false
	for n in v:
		if not (n is int or n is float) or not is_finite(float(n)):return false
	var p:=Vector2(v[0],v[1])
	if not Rect2(224,222,768,448).has_point(p):return false
	for c in blocks(e):
		if Rect2(Vector2(256+c.x*64,254+c.y*64)-Vector2(26,26),Vector2(52,52)).has_point(p):return false
	return true
