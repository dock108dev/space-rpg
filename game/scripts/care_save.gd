extends "res://scripts/home_save.gd"
const Care=preload("res://scripts/care_rules.gd")
func external_care_activity(_data:Dictionary) -> bool:return false
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("care_version",0)!=1:return false
	var c:Variant=data.get("care",null)
	if not c is Dictionary or c.size()!=Care.initial().size():return false
	for flag in ["trained","cover"]:
		if not c.get(flag,null) is bool:return false
	if c.get("pet","") not in ["healthy","injured"] or c.get("recruit","") not in ["healthy","downed"]:return false
	for field in ["paid","assisted","round","assists","retreats","victories"]:
		if not integer(c.get(field,null),0,999999):return false
	for spec in [["threat",0,12],["points",0,4],["guard",0,6],["aid_steps",0,2]]:
		if not integer(c.get(spec[0],null),spec[1],spec[2]):return false
	if c.get("encounter","") not in ["idle","active","retreated","cleared"]:return false
	if c.get("aid_actor",null) not in ["","pet","recruit"]:return false
	if (c.aid_actor=="")!=(c.aid_steps==0):return false
	if c.aid_actor!="" and (data.get("location","")!="shelter" or c[c.aid_actor]=="healthy" or c.encounter=="active"):return false
	if c.recruit=="downed" and data.get("recruit_status","") not in ["joined","waiting"]:return false
	if c.trained and (not data.get("learned",false) or (data.get("retrieval","")!="pet" and data.get("supply_method","")!="pet")):return false
	if c.cover and not c.trained:return false
	if c.encounter!="idle" and (not data.get("progression",{}).get("kit_claimed",false) or data.get("reward","")==""):return false
	if c.encounter=="active" and (data.get("location","")!="approach" or c.threat<=0):return false
	if c.encounter=="active":
		var cell:Variant=data.get("player",null)
		if not cell is Array or cell.size()!=2:return false
		if cell[0]==9 and cell[1]==3:return false
	if c.aid_actor!="":
		var cell:Variant=data.get("player",null)
		if not cell is Array or cell.size()!=2 or not integer(cell[0],0,11) or not integer(cell[1],0,6):return false
		if absi(int(cell[0])-5)+absi(int(cell[1])-1)>1:return false
	if c.encounter in ["idle","cleared"] and c.threat!=0:return false
	if c.encounter=="idle" and not external_care_activity(data) and (c.round!=0 or c.cover or c.pet!="healthy" or c.recruit!="healthy" or c.paid+c.assisted+c.assists+c.retreats+c.victories>0):return false
	if c.encounter=="cleared" and c.victories<1:return false
	if c.encounter=="retreated" and c.retreats<1:return false
	if c.encounter!="active" and c.guard!=0:return false
	if not data.get("progression",null) is Dictionary:return false
	if not integer(data.progression.get("material",null),0,resource_limit()):return false
	var base:Dictionary=data.duplicate(true)
	base.progression.material+=2*int(c.paid)
	return super.valid(base)
