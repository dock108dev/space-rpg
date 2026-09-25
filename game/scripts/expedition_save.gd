extends "res://scripts/care_save.gd"
const Expedition=preload("res://scripts/expedition_rules.gd")
func resource_limit() -> int:return 42
func extra_grant(data:Dictionary) -> int:return 8 if data.expedition.reported else 0
func external_care_activity(data:Dictionary) -> bool:return data.expedition.entered
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("expedition_version",0)!=1:return false
	var e:Variant=data.get("expedition",null)
	if not e is Dictionary or e.size()!=Expedition.initial().size():return false
	for field in ["entered","cleared","cover","wheel","crossed","objective","reported"]:
		if not e.get(field,null) is bool:return false
	for spec in [["warden",0,12],["points",0,4],["guard",0,6],["round",0,999999],["assists",0,999999],["retreats",0,999999],["exposures",0,999999]]:
		if not integer(e.get(spec[0],null),spec[1],spec[2]):return false
	e=e.duplicate(true)
	for field in ["warden","points","guard","round","assists","retreats","exposures"]:e[field]=int(e[field])
	if e.get("route",null) not in ["","live","drainage","maintenance"] or not e.get("result",null) is Dictionary:return false
	if not data.get("care",null) is Dictionary or not data.get("tasks",null) is Dictionary:return false
	if not e.entered and e!=Expedition.initial():return false
	if e.entered and (not data.get("progression",{}).get("kit_claimed",false) or data.get("reward","")=="" or data.get("phase","")!="success"):return false
	if e.cleared!=(e.warden==0):return false
	if (e.wheel or e.route!="" or e.crossed or e.objective) and not e.cleared:return false
	if e.route=="drainage" and data.tasks.get("survey","")!="completed":return false
	if e.route=="maintenance" and not e.wheel:return false
	if e.crossed and e.route=="":return false
	if e.objective and not e.crossed:return false
	if e.cover and not data.care.get("trained",false):return false
	if e.reported and not e.objective:return false
	if not e.reported and not e.result.is_empty():return false
	if e.reported:
		var r:Dictionary=e.result
		if r.keys().size()!=11 or r.get("objective","")!="routing core delivered" or r.get("reward",0)!=8:return false
		if r.get("route","") not in ["live","drainage","maintenance"] or r.route!=e.route:return false
		if r.get("supply_method",null)!=data.get("supply_method",null) and r.get("supply_method","")!="":return false
		if r.get("retrieval",null)!=data.get("retrieval",null) and r.get("retrieval","")!="":return false
		if r.get("pet","") not in ["healthy","injured"] or r.get("recruit","") not in ["healthy","downed"]:return false
		if r.get("membership","") not in ["available","joined","declined","waiting"]:return false
		if not r.get("tasks",null) is Dictionary or r.tasks.size()!=3:return false
		for v in r.tasks.values():
			if v not in ["available","completed","skipped"]:return false
		for task in ["supplies","access","survey"]:
			if not r.tasks.has(task):return false
			if r.tasks[task]=="completed" and data.tasks.get(task,"")!="completed":return false
		for field in ["supply_method","retrieval"]:
			if r.get(field,null) not in ["","personal","pet"]:return false
		for field in ["assists","retreats"]:
			if not integer(r.get(field,null),0,int(e[field])):return false
	if data.get("location","")!="objective" and e.guard!=0:return false
	var base:Dictionary=data.duplicate(true)
	if data.get("location","")=="objective":
		if not e.entered or data.care.get("encounter","")=="active" or data.care.get("aid_actor","")!="":return false
		var c:Variant=data.get("player",null)
		if not c is Array or c.size()!=2 or not integer(c[0],0,11) or not integer(c[1],0,6):return false
		if not Expedition.cell_ok(Vector2i(c[0],c[1]),e) or not Expedition.pixel_ok(data.get("pet_position",null),e):return false
		if data.get("recruit_status","")=="joined" and not Expedition.pixel_ok(data.get("recruit_position",null),e):return false
		if not e.cleared and c[0]>=6:return false
		base.location="approach";base.player=[1,5];base.pet_position=[320,638]
		if data.get("recruit_status","")=="joined":base.recruit_position=[320,510]
	return super.valid(base)
