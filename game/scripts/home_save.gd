extends "res://scripts/preparation_save.gd"
const Home=preload("res://scripts/home_rules.gd")
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("home_version",0)!=1:return false
	var h:Variant=data.get("home",null)
	if not h is Dictionary or h.size()!=4:return false
	if not h.get("owned",null) is bool or not h.get("storage",null) is bool:return false
	if not integer(h.get("stored",null),0,20) or (not h.storage and h.stored!=0):return false
	if not h.get("furniture",null) is Dictionary or h.furniture.size()!=3:return false
	var expense:=4 if h.storage else 0
	var used:Array=[]
	for id in Home.NAMES:
		var slot:Variant=h.furniture.get(id,null)
		if not integer(slot,-1,4):return false
		if slot>=0:expense+=2
		if slot>0:
			if int(slot) in used:return false
			used.append(int(slot))
	if not h.owned and (expense>0 or h.stored>0):return false
	var p:Variant=data.get("progression",null)
	if not p is Dictionary or not integer(p.get("material",null),0,resource_limit()):return false
	if h.owned and (not p.get("kit_claimed",false) or data.get("reward","")==""):return false
	var base:Dictionary=data.duplicate(true)
	base.progression.material=int(p.material)+int(h.stored)-(10 if h.owned else 0)+expense
	if data.get("location","")=="home":
		if not h.owned:return false
		var c:Variant=data.get("player",null)
		if not c is Array or c.size()!=2 or not integer(c[0],0,11) or not integer(c[1],0,6):return false
		if not Home.cell_ok(Vector2i(c[0],c[1]),h) or not Home.pixel_ok(data.get("pet_position",null),h):return false
		if data.get("recruit_status","")=="joined" and not Home.pixel_ok(data.get("recruit_position",null),h):return false
		base.location="shelter";base.player=[1,5];base.pet_position=[320,638]
		if base.get("recruit_status","")=="joined":base.recruit_position=[256,638]
	return super.valid(base)
