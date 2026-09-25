extends "res://scripts/companions_care.gd"
const Expedition=preload("res://scripts/expedition_rules.gd")
const ExpeditionSave=preload("res://scripts/expedition_save.gd")
var expedition:Dictionary=Expedition.initial()
var expedition_ready:=false

func create_save_store() -> RefCounted:
	var path:=OS.get_environment("B7_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B7-practice-v1")
	return ExpeditionSave.new(path)

func _ready() -> void:
	super._ready()
	expedition_ready=true
	get_window().title="Space Opera RPG · B7 · Relay receipt"
	last_context="";sync_care()
func snapshot() -> Dictionary:
	var d:=super.snapshot();d.merge({"expedition_version":1,"expedition":expedition.duplicate(true)});return d
func apply_snapshot(d:Dictionary) -> void:
	expedition=d.get("expedition",Expedition.initial()).duplicate(true)
	super.apply_snapshot(d);sync_care()
func reset_demo() -> bool:
	var ok:=super.reset_demo()
	if ok:expedition=Expedition.initial();set_location_art();sync_care()
	return ok
func yard_danger() -> bool:return location=="objective" and not expedition.cleared
func safe_idle() -> bool:return location!="objective" and super.safe_idle()
func inside(c:Vector2i) -> bool:
	if location=="objective":return c.x>=0 and c.x<12 and c.y>=0 and c.y<7
	return super.inside(c)
func floor_free(c:Vector2i) -> bool:
	if location=="objective":return Expedition.cell_ok(c,expedition) and c not in extra_blocks
	return super.floor_free(c)
func world_doors() -> Dictionary:
	if location=="objective":return {"approach":Vector2i(0,5)}
	var d:=super.world_doors().duplicate()
	if location=="approach":d.objective=Vector2i(11,3)
	return d
func clear_shot(a:Vector2i,b:Vector2i) -> bool:
	if location!="objective":return super.clear_shot(a,b)
	for block in Expedition.blocks(expedition)+extra_blocks:
		if block==b:continue
		var rect:=Rect2(point(block)-Vector2(31,31),Vector2(62,62))
		for i in range(129):
			if rect.has_point(point(a).lerp(point(b),float(i)/128)):return false
	return true
func sync_care() -> void:
	super.sync_care()
	if not is_instance_valid(pet):return
	if location=="objective":
		pet.set_physics_process(false);recruit.set_physics_process(false)
		creature.visible=not expedition.cleared;creature.position=point(Expedition.WARDEN);pose.modulate=Color.WHITE
		art.wall_detail.text="West court · Induction crossing · Routing core"
	elif location=="approach":art.wall_detail.text="North range · Optional breach · Relay yard beyond east barrier"
func assignment_text() -> String:
	return "The hub requests the district relay's routing core: a physical address receipt for the shelter. You get a finished obligation and 8 material when you file relay report at the board, not before. 'Voluntary infrastructure participation,' says the notice. The roof you sleep under needs an address more than a slogan. Finish orientation and claim the preparation kit, then enter expedition at the east barrier. A warden guards the west court; a live induction crossing guards the core. Equipment, chosen power and healthy companions help. Recruitment, purchases, home and optional tasks are not entry gates. Retreat gathers everyone; progress persists."
func route_text() -> String:
	return "Clear the yard warden first. Then choose: Take the live lane, a short crossing with 2 pressure on each movement/dash entering energized cells (6–7, row 3); guard/shield and passive weave absorb pressure, dash crosses more floor for one action. Exposed companions suffer recoverable injury/downing. Or take a longer dry passage along the north wall. "+("Your recorded survey identifies its drainage latch: Take the drainage route opens it immediately." if tasks.survey=="completed" else "Without the survey, go to wheel and turn isolation wheel, then take the maintenance route. That detour opens the dry passage without payment.")+" Recovering the core shuts the crossing down. Retreat keeps cleared danger and the core; no repeated combat rewards."
func result_text() -> String:
	if not expedition.reported:return "Chapter unfinished. "+("Routing core held; return to the hub board and file relay report to receive 8 material." if expedition.objective else "Recover the routing core beyond the barrier, then file the report at the hub. No expedition reward has been paid.")
	var r:Dictionary=expedition.result
	return "OPENING CHAPTER COMPLETE — Relay receipt. Routing core delivered; shelter address recorded. Assignment paid 8 material once. Route: %s. At filing: pet %s; traveler %s (%s). Traveler support shots %d; retreats %d. Optional work: supplies %s (%s), access %s, survey %s. Cache retrieval: %s. Current carried %d, stored %d. The address is real; freedom is still another question. This is the end of the delivered chapter. Your home, care and unfinished local work remain usable."%[r.route,r.pet,r.recruit,r.membership,r.assists,r.retreats,r.tasks.supplies,r.supply_method if r.supply_method!="" else "uncollected",r.tasks.access,r.tasks.survey,r.retrieval if r.retrieval!="" else "uncollected",progression.material,home.stored]
func survey_description() -> String:
	return "Survey recorded: the drainage path skirts the ridge to a dry latch on the relay yard's north wall. After clearing the warden, take the drainage route to avoid the live lane and the isolation-wheel detour. No currency granted." if tasks.survey=="completed" else "Inspect and survey this marker to record a visible drainage approach. It may save a detour beyond the barrier. No reward or danger begins here."
func describe_place() -> String:
	if location=="objective":return "Relay yard. Cracked intake pipes crowd the west court; a ribbed induction spine divides it from the core dais. The west threshold returns to the approach. "+("The warden lies still; its contract did not include a retirement plan. "+route_text() if expedition.cleared else "A containment warden scrapes a groove around its station. It blocks the inner court. Four AP; shoot, chosen power, guard, move and End turn. Retreat remains available.")+ (" The empty socket is dark. Return to the board." if expedition.objective else "")
	if location=="approach":return "Expedition approach. The north range is harmless; the separate containment breach is optional. The east barrier now admits the relay assignment. "+assignment_text()
	return super.describe_place()
func traveler_line() -> String:
	if expedition.reported:return '“They stamped RECEIVED. Civilization may recover from this.” '+result_text()
	if location=="objective":return ('The traveler needs care and cannot fire. ' if care.recruit=="downed" else '“I will watch the moving problem. You watch the expensive floor.” ')+route_text()
	return super.traveler_line()
func question(text:String) -> String:
	if "audience" in text or "feed" in text or "privacy" in text:return super.question(text)
	if "preparing for" in text or "assignment" in text or "why" in text:return assignment_text()
	if "route" in text or "crossing" in text or "expedition" in text:return route_text()
	if "accomplish" in text or "chapter" in text:return result_text()
	if "unfinished" in text or "work" in text or "tasks" in text:return result_text()+" Optional work now: supplies %s, access %s, survey %s; skipped jobs can resume."%[tasks.supplies,tasks.access,tasks.survey]
	if "equipment and condition" in text or "ready" in text:return inventory_text()+"\n"+party_text()+"\n"+route_text()
	return super.question(text)
func targets() -> Dictionary:
	var t:Dictionary={} if location=="objective" else super.targets()
	if location=="approach":t.objective={"aliases":["barrier","expedition","relay yard","objective"],"cell":Vector2i(11,3),"inspect":assignment_text()+"\n"+route_text()}
	if location=="hub":t.board.inspect+="\n"+assignment_text()+"\n"+result_text()
	if location=="objective":
		t.approach={"aliases":["approach","exit","door","threshold"],"cell":Vector2i(0,5),"inspect":"Return to the approach. During danger use Retreat; all joined members are gathered, including injured/downed members. Progress persists."}
		t.creature={"aliases":["warden","creature","enemy"],"cell":Expedition.WARDEN,"inspect":"Relay warden: %d/12. Equipment and powers use ordinary impact/range. It strikes the exposed party after your turn; healthy allies can help first."%expedition.warden if not expedition.cleared else "The warden is cleared permanently. It yields no salvage or currency."}
		t.wheel={"aliases":["wheel","isolation wheel"],"cell":Expedition.WHEEL,"inspect":"Manual isolation opens the long north maintenance passage after the warden is cleared. No resources consumed. Survey information can open the drainage latch without this detour."}
		t.crossing={"aliases":["crossing","live lane","induction spine"],"cell":Vector2i(6,3),"inspect":route_text()}
		t.drainage={"aliases":["drainage","dry passage","north passage"],"cell":Vector2i(6,0),"inspect":route_text()}
		t.core={"aliases":["core","routing core","objective","socket"],"cell":Expedition.CORE,"inspect":"The routing core carries the district address. "+("Already removed; no duplicate item." if expedition.objective else "Cross to the east dais, stand beside it and recover routing core. Removal shuts the induction lane off. Payment follows only at the hub board.")}
		t.pet={"aliases":["pet","animal"],"cell":cell_at(pet.position),"inspect":party_text()}
		if recruit_status=="joined":t.traveler={"aliases":["traveler","companion","recruit"],"cell":cell_at(recruit.position),"inspect":party_text()}
	return t
func world_clause(text:String) -> Dictionary:
	if text in ["check our equipment and condition","check equipment and condition"]:return {"question":"equipment and condition"}
	if text.begins_with("what") or text.begins_with("how") or text.begins_with("why") or text.ends_with("?"):return {"question":text}
	var names:={"enter expedition":"enter","enter the expedition":"enter","go to objective":"enter","go to relay yard":"enter","take the live lane":"live","take live lane":"live","take the drainage route":"drainage","take drainage route":"drainage","take the maintenance route":"maintenance","turn isolation wheel":"wheel","turn the isolation wheel":"wheel","recover routing core":"core","take routing core":"core","file relay report":"report"}
	if text in names:
		if names[text]=="enter":return {"actions":[{"verb":"go","target":"objective"},{"verb":"expedition","operation":"enter"}]}
		return {"actions":[{"verb":"expedition","operation":names[text]}]}
	if text in ["take route","take the route","take the safe route","resolve objective"]:return {"error":"Name one action: take the live lane, take the drainage route, take the maintenance route, or recover routing core. Nothing changed."}
	if text in ["ask pet to fetch cover","ask the pet to fetch cover"]:return {"question":"pet"} if not yard_danger() else {"actions":[{"verb":"expedition","operation":"cover"}]}
	if location=="objective":
		if text in ["return home","go home","return to home"]:return {"actions":[{"verb":"expedition","operation":"retreat"},{"verb":"deferred","text":"go home"}]}
		if text in ["retreat","call evacuation"]:return {"actions":[{"verb":"expedition","operation":"evacuate" if text=="call evacuation" else "retreat"}]}
		if text in ["go to approach","return to approach","leave expedition"]:return {"actions":[{"verb":"expedition","operation":"retreat"}]}
		if text=="guard":return {"actions":[{"verb":"expedition","operation":"guard"}]}
	return super.world_clause(text)
func execute(a:Dictionary) -> bool:
	if a.has("target") and a.get("target_location",location)!=location:return reject("That target belonged to another place. Name a current target.")
	if a.verb=="expedition":return expedition_action(a.operation)
	if a.verb in ["interact","collect"]:
		if a.get("target","")=="objective" and location=="approach":return expedition_action("enter")
		if location=="objective" and a.get("target","") in ["core","wheel"]:return expedition_action(a.target)
	if location=="objective":
		if a.verb=="bolt":return yard_attack("bolt")
		if a.verb=="power":
			if a.value!=power:return reject("Your chosen power is "+power+".")
			return yard_dash(a.direction) if power=="dash" else expedition_action("shield") if power=="shield" else yard_attack("blast")
		if a.verb in ["care_action","preparation","practice","home_action","task","join","decline","wait","rejoin","fetch","supply_fetch","kit"]:return reject("Return with the party before routine work or care. No supplies spent.")
	return super.execute(a)
func commit_expedition(before:Dictionary,line:String) -> bool:
	var ok:=commit_care(before,line)
	if ok:set_location_art();sync_care()
	return ok
func expedition_action(op:String) -> bool:
	if not care_idle():return reject("Finish the current action or resume first.")
	if op=="enter":return travel("objective")
	if op=="report":
		if location!="hub" or distance(player_cell,Vector2i(3,2))>1:return reject("Go to board in the hub, then file relay report.")
		if expedition.reported:return reject(result_text())
		if not expedition.objective:return reject("Recover the routing core first. No reward has been paid.")
		var before:=snapshot();expedition.reported=true;progression.material+=8
		expedition.result={"objective":"routing core delivered","reward":8,"route":expedition.route,"tasks":tasks.duplicate(true),"supply_method":supply_method,"retrieval":retrieval,"pet":care.pet,"recruit":care.recruit,"membership":recruit_status,"assists":expedition.assists,"retreats":expedition.retreats}
		return commit_expedition(before,result_text())
	if location!="objective":return reject("That action belongs in the relay yard beyond the east barrier.")
	if op in ["retreat","evacuate"]:return start_retreat(op=="evacuate")
	if op=="cover":
		if care.pet!="healthy" or not care.trained:return reject("A healthy pet with learned cover fetch is required. Injured pets need explicit shelter care.")
		if expedition.cover:return reject("The reachable cover plate was already fetched; no second plate exists.")
		message="Cover fetch uses the pet's actual learned behavior automatically on End turn if the plate is reachable. End turn also allows the warden to respond.";return true
	if op in ["guard","shield"]:
		if expedition.points<1:return reject("Need 1 AP; End turn refreshes four.")
		var before:=snapshot();expedition.points-=1;expedition.guard=effects().shield if op=="shield" else effects().guard+1
		return commit_expedition(before,"Protection %d readied for the next warden pulse or live-lane movement. One AP spent."%expedition.guard)
	if not expedition.cleared:return reject("The warden blocks the inner court. Clear it or retreat first.")
	var before:=snapshot()
	match op:
		"wheel":
			if distance(player_cell,Expedition.WHEEL)>1:return reject("Go to wheel before operating the isolation handle.")
			if expedition.wheel:return reject("The wheel is already open.")
			expedition.wheel=true
			return commit_expedition(before,"The wheel opens the maintenance latch. Take the maintenance route, then walk through the north passage. No charge. The sign says AUTOMATED; you have corrected its optimism.")
		"live","drainage","maintenance":
			if expedition.objective:return reject("The core is removed; the crossing is already dark. No approach needs replaying.")
			if player_cell.x>=6 or expedition.crossed:return reject("You have crossed already. That route remains recorded until the report.")
			if op=="drainage" and tasks.survey!="completed":return reject("No recorded survey identifies that latch. Use the live lane or open the isolation wheel for the dry maintenance route.")
			if op=="maintenance" and not expedition.wheel:return reject("Go to wheel and turn isolation wheel first, or use your completed survey's drainage route.")
			expedition.route=op
			return commit_expedition(before,"Route selected: "+op+". "+("The short central lane stays energized. Guard/shield, weave or dash can help. Walk across to the core." if op=="live" else "The north dry passage is open. Go to drainage, then go to core to follow that passage. No exposure if you stay on the dry route."))
		"core":
			if expedition.objective:return reject("The socket is empty. One objective only.")
			if not expedition.crossed or distance(player_cell,Expedition.CORE)>1:return reject("Cross to the east dais and go to core first.")
			expedition.objective=true;expedition.guard=0
			return commit_expedition(before,"The routing core releases with a tired click. The induction spine goes dark. One core held, zero material paid. Return to the hub board and file relay report. The shelter will finally have an address that is not 'near the screaming'.")
	return reject("Use the current expedition choices.")
func travel(destination:String) -> bool:
	if location=="objective":return start_retreat(false) if destination=="approach" else reject("Return through the approach first. Retreat gathers the party.")
	if destination!="objective":return super.travel(destination)
	if not safe_idle() or location!="approach" or distance(player_cell,Vector2i(11,3))>1 or reward=="" or not progression.kit_claimed:return reject("Finish orientation, claim your kit, then go to the east barrier. Finish breach/care first. No optional preparation is required.")
	var before:=snapshot();expedition.entered=true;location="objective";player_cell=Vector2i(1,5);human.position=point(player_cell);pet.position=point(Vector2i(1,4));pet.reset_path()
	if recruit_status=="joined":recruit.position=point(Vector2i(2,5));recruit.reset_path()
	var ok:=commit_expedition(before,describe_place())
	if ok:work.clear();recent="";previous=""
	return ok
func act(target:Vector2i) -> bool:
	if location!="objective":return super.act(target)
	if mode=="bolt":return yard_attack("bolt")
	if mode=="power":return yard_dash((target-player_cell).sign()) if power=="dash" else expedition_action("shield") if power=="shield" else yard_attack("blast")
	return yard_move(target,false)
func select_action(id:String) -> bool:
	if location=="objective":
		if id not in ["move","bolt","power"]:return reject("Choose move, shot, chosen power, or retreat.")
		mode=id;return true
	return super.select_action(id)
func yard_dash(direction:Vector2i) -> bool:
	if abs(direction.x)+abs(direction.y)!=1:return reject("Dash requires one cardinal direction.")
	return yard_move(player_cell+direction*int(effects().dash),true)
func yard_move(target:Vector2i,dashing:bool) -> bool:
	if not care_idle() or expedition.points<1:return reject("Need a ready decision and 1 AP. End turn refreshes AP.")
	var start:=player_cell;var direction:=(target-start).sign();var count:=distance(start,target)
	if (not dashing and count!=1) or abs(direction.x)+abs(direction.y)!=1:return reject("Choose adjacent clear floor or a cardinal dash.")
	var hot:=false
	for step in range(1,count+1):
		var cell:=start+direction*step
		if not floor_free(cell):return reject("The route is blocked. No AP spent.")
		if not expedition.objective and cell.y==3 and cell.x in [6,7]:hot=true
	if target.x>=6 and expedition.route=="":return reject("Choose the live lane, surveyed drainage or wheel-opened maintenance route before crossing.")
	# The chosen dry route must be physically used; pathfinding never silently uses live floor.
	if hot and expedition.route in ["drainage","maintenance"]:return reject("The selected dry route goes through the north passage. Go to drainage first; no live-floor step was taken.")
	var before:=snapshot();player_cell=target;expedition.points-=1
	var line:="Moved %d square%s for 1 AP."%[count,"s" if count!=1 else ""]
	if hot:
		var damage:=maxi(0,2-maxi(int(expedition.guard),int(effects().guard)));hp=maxi(0,hp-damage);expedition.guard=0;expedition.exposures+=1
		care.pet="injured"
		if recruit_status=="joined":care.recruit="downed"
		line+=" Induction crossing: %d health lost. The party is tethered for crossing; exposed pet injured and joined traveler downed, both recoverable. Retreat carries everyone."%damage
	if target.x>=8 and not expedition.crossed:expedition.crossed=true;line+=" East dais reached. The routing core is within reach."
	# At cleared-yard movement boundaries, party travels in a rescue sling/tether.
	# Same collision-checked path as protagonist, including impaired members.
	if expedition.cleared:
		pet.position=point(target)+Vector2(-18,14);pet.reset_path()
		if recruit_status=="joined":recruit.position=point(target)+Vector2(18,8);recruit.reset_path()
	if hp==0:
		phase="defeat";human.position=point(target);work.clear();message="Defeated on the live crossing. Continue restores the latest living snapshot, including resources and party condition.";return true
	if not commit_expedition(before,line):return false
	animate("dash" if dashing else "move",0.6 if dashing else 0.4,point(start),point(target));return true
func yard_attack(kind:String) -> bool:
	if not yard_danger() or not care_idle() or expedition.points<2:return reject("A live warden and 2 AP are required.")
	if distance(player_cell,Expedition.WARDEN)>(4 if kind=="blast" else 6) or not clear_shot(player_cell,Expedition.WARDEN):return reject("Warden outside clear range. Move closer; no AP spent.")
	var before:=snapshot();var hit:int=effects()[kind];expedition.points-=2;expedition.warden=maxi(0,int(expedition.warden)-hit)
	if expedition.warden==0:expedition.cleared=true;expedition.guard=0;expedition.points=4
	if not commit_expedition(before,"%s: %d impact. Warden %d/12. %s"%[kind.capitalize(),hit,expedition.warden,"West court permanently clear; choose an induction-crossing route. No currency awarded." if expedition.cleared else "End turn gives eligible allies their action before the warden responds."]):return false
	effect_from=human.position-Vector2(0,40);effect_to=point(Expedition.WARDEN)-Vector2(0,40);animate(kind,0.6,human.position,human.position);return true
func end_turn() -> bool:
	if location!="objective":return super.end_turn()
	if not care_idle():return reject("Finish the current action or resume first.")
	if expedition.cleared:
		var before:=snapshot();expedition.points=4
		return commit_expedition(before,"Four AP refreshed. No warden remains; the crossing responds only when you enter live floor. Readied protection remains until that exposure.")
	care_before=snapshot();care_cover=false;care_route.clear()
	if care.trained and care.pet=="healthy" and not expedition.cover:
		var start:=cell_at(pet.position);var outbound:Array[Vector2]=pet.find_route(start,Expedition.COVER);var back:Array[Vector2]=pet.find_route(Expedition.COVER,start)
		if (start==Expedition.COVER or not outbound.is_empty()) and (start==Expedition.COVER or not back.is_empty()) and outbound.size()<=7:care_route.assign(outbound+back);care_cover=true
	care_motion="turn";care_clock=0;busy=true;sync_care();message="The traveler lines up a shot; the pet checks for cover. The warden responds after the party.";return true
func finish_breach_turn() -> void:
	if location!="objective":super.finish_breach_turn();return
	expedition.round+=1;var lines:Array=[]
	if recruit_status=="joined" and care.recruit=="healthy" and distance(cell_at(recruit.position),Expedition.WARDEN)<=6 and clear_shot(cell_at(recruit.position),Expedition.WARDEN):
		expedition.warden=maxi(0,int(expedition.warden)-1);expedition.assists+=1;care.assists+=1;care_beam=1.0;lines.append("Traveler fires once: 1 impact.")
	if care_cover:expedition.cover=true;lines.append("The pet physically returns the cover plate: 1 pressure absorbed this turn.")
	if expedition.warden>0:
		care_pulse=1.0;var damage:=maxi(0,2-maxi(int(expedition.guard),int(effects().guard))-(1 if care_cover else 0));hp=maxi(0,hp-damage);lines.append("Warden strikes: %d health lost."%damage)
		if care.pet=="healthy" and distance(cell_at(pet.position),Expedition.WARDEN)<=6 and clear_shot(cell_at(pet.position),Expedition.WARDEN):care.pet="injured";lines.append("Pet injured: fetch disabled until explicit care.")
		if expedition.round>=2 and recruit_status=="joined" and care.recruit=="healthy" and distance(cell_at(recruit.position),Expedition.WARDEN)<=6 and clear_shot(cell_at(recruit.position),Expedition.WARDEN):care.recruit="downed";lines.append("Traveler downed but breathing; retreat rescues them.")
	else:expedition.cleared=true;lines.append("Warden cleared permanently. No salvage reward. The crossing is now reachable.")
	expedition.points=4;expedition.guard=0
	if hp==0:phase="defeat";work.clear();message="Defeated. Continue the latest living save; no reward or recovery was invented.";return
	commit_expedition(care_before," ".join(lines))
func start_retreat(overhead:bool) -> bool:
	if location!="objective":return super.start_retreat(overhead)
	if not care_idle():return reject("Finish the current action first.")
	var route:Array[Vector2]=pet.find_route(player_cell,Vector2i(0,5))
	if not overhead:
		if route.is_empty() and player_cell!=Vector2i(0,5):return reject("Floor retreat blocked. Call evacuation explicitly for overhead extraction.")
		for actor in [pet,recruit] if recruit_status=="joined" else [pet]:
			if cell_at(actor.position)!=player_cell and actor.find_route(cell_at(actor.position),player_cell).is_empty():return reject("A member cannot reach the rescue sling. Call evacuation to gather everyone overhead.")
	care_before=snapshot();care_motion="evacuate" if overhead else "rescue_pet";care_clock=0;busy=true;rescue_routes.clear()
	if not overhead:
		rescue_routes.append(recruit.find_route(cell_at(recruit.position),player_cell) if recruit_status=="joined" else []);rescue_routes.append(route);care_route.assign(pet.find_route(cell_at(pet.position),player_cell))
	else:care_route.clear()
	sync_care();message="You gather everyone into the insulated rescue sling. Return preserves injuries and expedition progress, including a recovered core. No payment.";return true
func finish_retreat() -> void:
	if location!="objective":super.finish_retreat();return
	expedition.retreats+=1;expedition.guard=0;location="approach";player_cell=Vector2i(10,3);human.position=point(player_cell);pet.position=point(Vector2i(10,4));pet.reset_path()
	if recruit_status=="joined":recruit.position=point(Vector2i(10,2));recruit.reset_path()
	if commit_expedition(care_before,"Whole party returned to the approach. Warden health %d; core %s. Pet %s; traveler %s. Conditions require shelter care; free protagonist rest remains available. Go to hub to continue homeward."%[expedition.warden,"held" if expedition.objective and not expedition.reported else "delivered" if expedition.reported else "unclaimed",care.pet,care.recruit]):recent="";previous=""
func interact() -> bool:
	if location=="approach" and distance(player_cell,Vector2i(11,3))<=1:return expedition_action("enter")
	if location=="objective":
		if distance(player_cell,Expedition.CORE)<=1:return expedition_action("core")
		if distance(player_cell,Expedition.WHEEL)<=1:return expedition_action("wheel")
		if distance(player_cell,Vector2i(0,5))<=1:return start_retreat(false)
		return reject("Stand beside the core, isolation wheel or west threshold. Inspect crossing for approaches.")
	return super.interact()
func refresh_ui() -> void:
	super.refresh_ui()
	if not expedition_ready:return
	if location=="objective":
		status.text="Relay yard · "+("Defeated — Continue" if phase=="defeat" else "Core recovered" if expedition.objective else "Induction crossing" if expedition.cleared else "Your decision")
		context_line.text="Health %d/6 · AP %d/4 · Warden %d · Pet %s · Traveler %s"%[hp,expedition.points,expedition.warden,care.pet,care.recruit]
		detail.text="Choose a route; go to core, recover it, then return." if expedition.cleared else "Shoot / power / guard / move. End turn resolves allies, then warden. Retreat gathers everyone."
		audience.text="Outside audience (characters cannot see this): Infrastructure has acquired a receipt. No tips accepted." if expedition.reported else "Outside audience (characters cannot see this): Voluntary participation has an unusually expensive floor."
		play_panel.show();chapter_panel.hide();buttons.use.hide()
		for id in ["move","bolt","power","end"]:buttons[id].disabled=not care_idle()
	elif location=="approach" and not active_breach():detail.text="East barrier: relay expedition. North range stays harmless; breach is separate optional danger."
	elif location=="shelter" and reward!="":status.text="Shelter · Prepare or recover"
	elif location=="hub":
		if expedition.reported:status.text="Opening chapter complete"
		detail.text="Relay core: file report at the board after recovery." if not expedition.reported else "Home, care and unfinished local work remain available. Ask what we accomplished."
	sync_privacy()
func refresh_choices() -> void:
	if location=="objective":
		for child in choices.get_children():child.queue_free()
		var items:Array=[]
		if not expedition.cleared:items=[["Shoot warden","shoot creature"],["Guard","guard"],["End turn","end turn"],["Party / gear","check our equipment and condition"],["Retreat","retreat"]]
		elif expedition.objective:items=[["Return party","retreat"],["Return home","return home"],["Objective","what did we accomplish?"]]
		else:items=[["Route information","what do we know about the route?"],["Live lane","take the live lane"],["Drainage" if tasks.survey=="completed" else "Isolation wheel","take the drainage route" if tasks.survey=="completed" else "go to wheel then turn isolation wheel then take the maintenance route"],["North passage","go to drainage"],["Reach core","go to core"],["Recover core","recover routing core"],["End turn","end turn"],["Retreat","retreat"]]
		for item in items:add_world_choice(item[0],item[1])
		return
	super.refresh_choices()
	if location=="approach" and not active_breach():
		for child in choices.get_children():child.queue_free()
		for item in [["Assignment","what am I preparing for?"],["Enter expedition","enter expedition"],["Survey","go to marker then survey the approach"],["Range / train","go to range then inspect range"],["Breach","go to breach then inspect breach"],["To hub","go to hub"]]:add_world_choice(item[0],item[1])
	if location=="hub" and preparation_page=="world":add_world_choice("Chapter result" if expedition.reported else "Relay report","what did we accomplish?" if expedition.reported else "go to board then file relay report")
func set_location_art() -> void:
	if location!="objective":super.set_location_art();return
	if not is_instance_valid(art):return
	for child in location_collisions.get_children():child.free()
	for c in Expedition.blocks(expedition):
		var body:=StaticBody2D.new();body.position=point(c);var shape:=CollisionShape2D.new();var box:=RectangleShape2D.new();box.size=Vector2(52,52);shape.shape=box;body.add_child(shape);location_collisions.add_child(body)
	for node in art.scenery:
		if is_instance_valid(node):node.hide();node.queue_free()
	art.scenery.clear();art.package_prop=null;art.cache_prop=null;art.location="home";art.floor_picture.hide()
	art.background.texture=load("res://art/b7/yard.svg");art.background.show();art.wall_title.text="Relay yard";art.wall_detail.text="West court · Induction crossing · Routing core"
	art.prop("doorway",point(Vector2i(0,5))+Vector2(0,30),Vector2(92,110))
	for spec in [["core_empty" if expedition.objective else "core",Expedition.CORE],["wheel",Expedition.WHEEL]]:
		var anchor:=Node2D.new();anchor.position=point(spec[1])+Vector2(0,24);sorted.add_child(anchor);art.scenery.append(anchor)
		var sprite:=Sprite2D.new();sprite.texture=load("res://art/b7/"+spec[0]+".svg");sprite.position=Vector2(0,-40);anchor.add_child(sprite)
	recruit.visible=recruit_status=="joined";art.queue_redraw();queue_redraw();sync_privacy();sync_care()
func _draw() -> void:
	super._draw()
	if location!="objective":return
	for c in [Vector2i(6,3),Vector2i(7,3)]:draw_rect(Rect2(point(c)-Vector2(27,25),Vector2(54,50)),Color(0.9,0.62,0.28,0.5) if not expedition.objective else Color(0.3,0.5,0.48,0.3),false,4)
	if expedition.route in ["drainage","maintenance"]:draw_line(point(Vector2i(5,0)),point(Vector2i(7,0)),Color("afdcbd"),5,true)
	if yard_danger():
		draw_arc(point(Expedition.WARDEN),30,0,TAU,32,Color("d8877c"),3,true)
		if not expedition.cover:draw_rect(Rect2(point(Expedition.COVER)-Vector2(12,8),Vector2(24,16)),Color("aebdc5"))
		if care_beam>0:draw_line(recruit.position-Vector2(0,40),point(Expedition.WARDEN)-Vector2(0,40),Color("efdc92"),4,true)
		if care_pulse>0:draw_arc(point(Expedition.WARDEN)-Vector2(0,35),35+80*(1-care_pulse),0,TAU,48,Color(0.9,0.5,0.35,care_pulse),5,true)

func _process(delta:float) -> void:
	super._process(delta)
	if location=="objective" and expedition.cleared and care_motion=="" and busy and motion in ["move","dash"]:
		pet.position=human.position+Vector2(-18,14)
		if recruit_status=="joined":recruit.position=human.position+Vector2(18,8)
