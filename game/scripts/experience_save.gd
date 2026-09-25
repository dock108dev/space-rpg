extends "res://scripts/expedition_save.gd"
const APPEARANCES:=["amber","teal","plum"]
static func clean_name(value:String) -> String:
	var result:=""
	for c in value:
		var n:=c.unicode_at(0)
		if n>=32 and not (n>=127 and n<=159) and n not in [0x2028,0x2029,0x200e,0x200f,0x202a,0x202b,0x202c,0x202d,0x202e,0x2066,0x2067,0x2068,0x2069]:result+=c
	result=result.strip_edges().left(32)
	return "Alex" if result.is_empty() else result
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("experience_version",0)!=1:return false
	var c:Variant=data.get("character",null)
	if not c is Dictionary or c.size()!=2:return false
	if not c.get("name",null) is String or c.name!=clean_name(c.name):return false
	if c.get("appearance","") not in APPEARANCES:return false
	if data.get("facing","") not in ["toward","away","left","right"]:return false
	return super.valid(data)
