extends "res://scripts/world_save.gd"
func resource_limit() -> int:return 34
func extra_grant(_data:Dictionary) -> int:return 0
func valid(data:Variant) -> bool:
	if not super.valid(data) or data.get("progression_version",0)!=1:return false
	var p:Variant=data.get("progression",null)
	if not p is Dictionary or p.size()!=7:return false
	for flag in ["kit_claimed","bundle_exchanged","calibrated"]:
		if not p.get(flag,null) is bool:return false
	if not integer(p.get("material",null),0,resource_limit()) or not integer(p.get("power_level",null),0,1):return false
	if not p.get("levels",null) is Dictionary or p.levels.size()!=3:return false
	var upgrades:=int(p.power_level)
	for id in ["lens","weave","rig"]:
		if not integer(p.levels.get(id,null),-1,1):return false
		if (p.levels[id]>=0)!=p.kit_claimed:return false
		if p.levels[id]==1:upgrades+=1
	if p.get("equipped",null) not in ["","lens","weave","rig"]:return false
	if p.equipped!="" and not p.kit_claimed:return false
	if p.kit_claimed and not data.package:return false
	if p.bundle_exchanged and (not p.kit_claimed or data.tasks.supplies!="completed"):return false
	if p.calibrated and not p.kit_claimed:return false
	if p.power_level>0 and not p.calibrated:return false
	return p.material==extra_grant(data)+(20 if p.kit_claimed else 0)+(4 if p.bundle_exchanged else 0)-4*upgrades
