extends "res://scripts/owned_home.gd"
const Care=preload("res://scripts/care_rules.gd")
const CareSave=preload("res://scripts/care_save.gd")
const BREACH:=Vector2i(6,3)
const THREAT:=Vector2i(9,3)
const PLATE:=Vector2i(8,3)
var care:Dictionary=Care.initial()
var care_ready:=false
var care_menu:=false
var care_motion:=""
var care_route:Array[Vector2]=[]
var care_clock:=0.0
var care_before:Dictionary={}
var care_cover:=false
var care_beam:=0.0
var care_pulse:=0.0
var rescue_routes:Array=[]

func create_save_store() -> RefCounted:
	var path:=OS.get_environment("B6_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B6-practice-v1")
	return CareSave.new(path)

func _ready() -> void:
	super._ready()
	care_ready=true
	get_window().title="Space Opera RPG · B6 · No one left behind"
	last_context="";sync_care()
func snapshot() -> Dictionary:
	var d:=super.snapshot();d.merge({"care_version":1,"care":care.duplicate(true)});return d
func apply_snapshot(d:Dictionary) -> void:
	care=d.get("care",Care.initial()).duplicate(true);care_motion="";care_route.clear();care_clock=0
	super.apply_snapshot(d);sync_care()
func reset_demo() -> bool:
	if not care_motion.is_empty():return reject("Finish the current care or evacuation action first.")
	var ok:=super.reset_demo()
	if ok:care=Care.initial();sync_care();last_context=""
	return ok
func active_breach() -> bool:return care.encounter=="active"
func stable_boundary() -> bool:return care_motion.is_empty() and super.stable_boundary()
func safe_idle() -> bool:return care_motion.is_empty() and not active_breach() and care.aid_actor=="" and super.safe_idle()
func care_idle() -> bool:return not busy and care_motion.is_empty() and not get_tree().paused and phase!="defeat" and fetch_state.is_empty() and supply_trip.is_empty()
func sync_care() -> void:
	if not is_instance_valid(pet):return
	pet.set_physics_process(not active_breach() and care_motion=="")
	recruit.set_physics_process(not active_breach() and care_motion=="")
	pet.modulate=Color("e6aa83") if care.pet=="injured" else Color.WHITE
	recruit.modulate=Color("d39494") if care.recruit=="downed" else Color.WHITE
	if is_instance_valid(recruit.visual):recruit.visual.rotation=PI/2 if care.recruit=="downed" else 0.0
	if active_breach():creature.position=point(THREAT);creature.show();pose.modulate=Color.WHITE
	if location=="approach":art.wall_detail.text="North: harmless range · Breach: real danger · Expedition closed"
func party_text() -> String:
	return "Pet: %s; %s. Traveler: %s, %s. A joined healthy traveler fires once at a visible creature within six squares when you End turn. The trained pet fetches one cover plate per breach, reducing one pulse by 1. Injured pets cannot fetch; downed travelers cannot fire. Retreat brings everyone back; the shelter desk treats either condition. No permanent party death." % [care.pet,"cover fetch learned" if care.trained else "teach cover fetch after a successful pet retrieval",recruit_status,care.recruit]
func care_text() -> String:
	return "At the shelter desk: Treat the pet / Help the companion recover costs 2 carried material each. Carried %d; stored %d. Stored funds require go home, go to locker, withdraw 2 material, then return to the desk. Or Begin assisted pet care / Begin assisted companion care for no material: two attended six-second rounds using Continue assisted care. Remain at the desk; cancel assistance discards progress. No offline healing. Rest heals only you, freely." % [progression.material,home.stored]
func breach_text() -> String:
	return "Containment breach: a loose assessment creature blocks a damaged latch. Go to breach, then enter breach. Real injury risk; 12 creature health, four AP per turn. Shoot creature (2 AP), chosen power, move, guard (1 AP), End turn. Creature pulses after allies act: 2 pressure against you, first exposed pulse injures pet, second downs traveler. Retreat carries everyone west to the hub; call evacuation if that route is blocked. No material reward. North range stays harmless; this is not the full expedition."
func targets() -> Dictionary:
	var t:=super.targets()
	if location=="approach":
		t.breach={"aliases":["breach","containment","latch"],"cell":BREACH,"inspect":breach_text()}
		if active_breach():t.creature={"aliases":["creature","threat","enemy"],"cell":THREAT,"inspect":"Loose containment creature: %d/12 health. It snaps toward the exposed party when you end your turn."%care.threat}
	if location=="shelter" and t.has("desk"):t.desk.inspect+="\n"+care_text()
	return t
func describe_place() -> String:
	return super.describe_place()+(" A containment breach beside the ridge is optional real danger. Inspect breach for the risk and return route." if location=="approach" else " The shelter desk provides paid or assisted companion care." if location=="shelter" else "")
func question(text:String) -> String:
	if "audience" in text or "feed" in text or "privacy" in text:return super.question(text)
	if "treat" in text or "care" in text or "recover" in text:
		care_menu=true;last_context="";return care_text()+"\n"+party_text()
	if "pet" in text or "companion" in text or "traveler" in text or "training" in text:return party_text()
	if "breach" in text or "danger" in text or "retreat" in text:return breach_text()
	return super.question(text)
func interpret_request(text:String) -> Dictionary:
	var normalized:=Language.normalize(text)
	# A final question is one deferred clause, not a reason to discard prior travel.
	if " then " in normalized and normalized.ends_with("?") and Language.rx("^(go|walk|return|enter|retreat|treat|begin)\\b",normalized):
		return super.interpret_request(normalized.trim_suffix("?"))
	return super.interpret_request(text)
func world_clause(text:String) -> Dictionary:
	if text.begins_with("what") or text.begins_with("how") or text.begins_with("where") or text.ends_with("?"):return {"question":text}
	if text=="close care menu":care_menu=false;last_context="";return {"question":"where am i"}
	var commands:={"teach the pet cover fetch":"train","teach pet cover fetch":"train","enter breach":"enter","enter the breach":"enter","retreat":"retreat","call evacuation":"evacuate","guard":"guard","treat the pet":"pet","treat pet":"pet","help the companion recover":"recruit","treat companion":"recruit","begin assisted pet care":"aid_pet","begin assisted companion care":"aid_recruit","continue assisted care":"aid_round","cancel assistance":"aid_cancel"}
	if text in commands:return {"actions":[{"verb":"care_action","operation":commands[text]}]}
	if text in ["treat","treat them","help them recover","teach pet","teach the pet"]:return {"error":"Name one action: teach the pet cover fetch, treat the pet, or help the companion recover. Nothing changed."}
	if text in ["have the companion wait","have companion wait","have the companion wait here"]:text="have traveler wait here"
	if text in ["rejoin companion","ask companion to rejoin"]:text="rejoin traveler"
	return super.world_clause(text)
func execute(a:Dictionary) -> bool:
	if a.has("target") and a.get("target_location",location)!=location:return reject("That reference belonged to another place. Name a current target.")
	if a.verb=="care_action":return care_action(a.operation)
	if active_breach():
		if a.verb=="bolt":return breach_attack("bolt")
		if a.verb=="power":
			if a.value!=power:return reject("Your chosen power is "+power+".")
			return breach_dash(a.direction) if power=="dash" else care_action("shield") if power=="shield" else breach_attack("blast")
		if a.verb in ["preparation","practice","home_action","task","join","decline","wait","rejoin","fetch","supply_fetch","kit"]:return reject("Finish or retreat from the breach before routine work. Everyone returns with you.")
	return super.execute(a)
func commit_care(before:Dictionary,outcome:String) -> bool:
	if not persist():
		var failure:=message;apply_snapshot(before);message=failure+" Entire action rolled back; conditions, party and funds unchanged.";return false
	epoch+=1;last_context="";message=outcome;sync_care();return true
func care_action(op:String) -> bool:
	if not care_idle():return reject("Resume or finish the current action first.")
	if op in ["retreat","evacuate"]:return start_retreat(op=="evacuate")
	if op in ["guard","shield"]:
		if not active_breach() or care.points<1:return reject("Guard needs an active breach and 1 AP.")
		var prior:=snapshot();care.points-=1;care.guard=effects().shield if op=="shield" else effects().guard+1
		return commit_care(prior,"You brace. Protection %d for the next pulse; 1 AP spent."%care.guard)
	if active_breach():return reject("Retreat before training or care. The range is separate and harmless.")
	if op=="enter":
		if care.aid_actor!="" or location!="approach" or distance(player_cell,BREACH)>1 or not progression.kit_claimed or reward.is_empty():return reject("Claim your kit, finish care, then go to breach at the approach. Inspect breach for danger and return routes.")
		var prior:=snapshot();care.encounter="active";care.threat=12;care.round=0;care.points=4;care.guard=0;care.cover=false
		var ok:=commit_care(prior,"The latch fails. The creature wheels toward you. Four AP; End turn lets your companions act, then danger answers. Retreat is always a choice; blocked routes have overhead evacuation.")
		if ok:work.clear()
		return ok
	if op=="train":
		if care.aid_actor!="" or location!="approach" or distance(player_cell,Vector2i(1,0))>1 or care.pet!="healthy":return reject("Teach cover fetch beside the harmless range stripe with a healthy pet. Go to range first.")
		if care.trained:return reject("Cover fetch is already learned. No second lesson or cost.")
		if not learned or (retrieval!="pet" and supply_method!="pet"):return reject("First let the pet complete a real cache or supply retrieval. Then return here to adapt that learned behavior.")
		var prior:=snapshot();care.trained=true
		return commit_care(prior,"You pair the familiar fetch mark with a cover plate. The pet recognizes a useful object, rather than another receipt to eat. Cover fetch learned: once per breach it retrieves protection before the creature pulse. No fee.")
	if location!="shelter" or distance(player_cell,SHELTER_REWARD)>1:return reject("Go to the shelter desk for care. "+care_text())
	if op=="aid_cancel":
		if care.aid_actor=="":return reject("No assisted care is active.")
		var prior:=snapshot();care.aid_actor="";care.aid_steps=0
		return commit_care(prior,"Assistance canceled. Attended progress discarded; injury remains. You may start again without charge.")
	if op=="aid_round":
		if care.aid_actor=="":return reject("Begin assisted pet care or begin assisted companion care first.")
		care_before=snapshot();care_motion="aid";care_clock=0;busy=true;sync_care()
		message="You stay beside the patient for six seconds of supervised care. Pause freezes the procedure; no material is spent.";return true
	if care.aid_actor!="":return reject("Continue assisted care or cancel assistance first. No duplicate payment.")
	var actor:="pet" if op in ["pet","aid_pet"] else "recruit" if op in ["recruit","aid_recruit"] else ""
	if actor=="":return reject("Name the pet or companion for care.")
	if care[actor]=="healthy":return reject("Already healthy. No treatment or charge.")
	if actor=="recruit" and recruit_status not in ["joined","waiting"]:return reject("There is no recruited patient here.")
	var prior:=snapshot()
	if op.begins_with("aid_"):
		care.aid_actor=actor;care.aid_steps=2
		return commit_care(prior,"Assisted care arranged for the "+actor+". Two attended six-second rounds; Continue assisted care twice. No material required. The desk calls it a waiting list. You call it staying alive.")
	if progression.material<2:return reject("Need 2 carried material; stored %d is untouched. Withdraw at your home locker, or begin assisted %s care here for free."%[home.stored,"pet" if actor=="pet" else "companion"])
	progression.material-=2;care.paid+=1;care[actor]="healthy"
	return commit_care(prior,"Treatment complete for the "+actor+". Two carried material spent once. "+("Fetch and cover fetch are usable again." if actor=="pet" else "The traveler stands and can support you again."))
func fetch_cache() -> bool:
	if care.pet!="healthy":return reject("The pet is injured and cannot fetch. Retreat and seek treatment or free assisted care at the shelter desk.")
	return super.fetch_cache()
func start_supply_fetch() -> bool:
	if care.pet!="healthy":return reject("The pet is injured and cannot retrieve supplies. Shelter desk care restores this capability.")
	return super.start_supply_fetch()
func travel(destination:String) -> bool:
	if active_breach():return reject("Use Retreat to carry the party out together, or call evacuation if the route is blocked.")
	if care.aid_actor!="":return reject("Finish assisted care at the desk or cancel assistance before leaving.")
	return super.travel(destination)
func wait_recruit() -> bool:
	if active_breach() or care.recruit=="downed":return reject("A downed companion needs care; nobody is left in danger. Retreat together first.")
	return super.wait_recruit()
func floor_free(c:Vector2i) -> bool:
	return super.floor_free(c) and not (active_breach() and location=="approach" and c==THREAT)
func clear_shot(a:Vector2i,b:Vector2i) -> bool:
	for block in World.blocks(location,tasks.access=="completed")+extra_blocks:
		var rect:=Rect2(point(block)-Vector2(31,31),Vector2(62,62))
		for i in range(129):
			if rect.has_point(point(a).lerp(point(b),float(i)/128)):return false
	return true
func breach_attack(kind:String) -> bool:
	if not care_idle() or care.points<2:return reject("Need 2 AP and a ready player decision.")
	if distance(player_cell,THREAT)>(4 if kind=="blast" else 6) or not clear_shot(player_cell,THREAT):return reject("No clear target in range. Move closer on clear floor; nothing spent.")
	var prior:=snapshot();var hit:int=effects()[kind];care.points-=2;care.threat=maxi(0,int(care.threat)-hit)
	if care.threat==0:care.encounter="cleared";care.guard=0;care.victories+=1
	if not commit_care(prior,"%s hits for %d. Creature %d/12.%s"%[kind.capitalize(),hit,care.threat," Latch secured; no reward. Return to the hub or repeat later." if care.threat==0 else ""]):return false
	effect_from=human.position-Vector2(0,40);effect_to=point(THREAT)-Vector2(0,40);animate(kind,0.6,human.position,human.position);return true
func act(target:Vector2i) -> bool:
	if not active_breach():return super.act(target)
	if mode=="bolt":return breach_attack("bolt")
	if mode=="power":return breach_dash((target-player_cell).sign()) if power=="dash" else care_action("shield") if power=="shield" else breach_attack("blast")
	if not care_idle() or care.points<1:return reject("No movement until ready with at least 1 AP.")
	if not floor_free(target) or distance(player_cell,target)!=1:return reject("Choose adjacent clear floor. No AP spent.")
	var prior:=snapshot();var start:=player_cell;player_cell=target;care.points-=1
	if not commit_care(prior,"Moved one square; 1 AP spent."):return false
	animate("move",0.4,point(start),point(target));return true
func breach_dash(direction:Vector2i) -> bool:
	if not care_idle() or care.points<1 or abs(direction.x)+abs(direction.y)!=1:return reject("Dash needs a cardinal direction and 1 AP.")
	var length:int=effects().dash
	for step in range(1,length+1):
		if not floor_free(player_cell+direction*step):return reject("Dash route blocked; no AP spent.")
	var prior:=snapshot();var start:=player_cell;player_cell+=direction*length;care.points-=1
	if not commit_care(prior,"Dashed %d clear squares for 1 AP."%length):return false
	animate("dash",0.6,point(start),point(player_cell));return true
func select_action(id:String) -> bool:
	if active_breach():
		if id not in ["move","bolt","power"]:return reject("Use move, bolt, chosen power or retreat.")
		mode=id;return true
	return super.select_action(id)
func end_turn() -> bool:
	if not active_breach():return super.end_turn()
	if not care_idle():return reject("Finish the current action or resume first.")
	care_before=snapshot();care_cover=false;rescue_routes.clear()
	care_route.clear()
	if care.trained and care.pet=="healthy" and not care.cover:
		var start:=cell_at(pet.position)
		var outbound:Array[Vector2]=pet.find_route(start,PLATE)
		var back:Array[Vector2]=pet.find_route(PLATE,start)
		if (start==PLATE or not outbound.is_empty()) and (start==PLATE or not back.is_empty()) and outbound.size()<=7:
			care_route.assign(outbound+back);care_cover=true
	care_motion="turn";care_clock=0;busy=true;sync_care();message="You yield the turn. The traveler checks a target; the pet looks for reachable cover.";return true
func finish_breach_turn() -> void:
	var lines:Array=[];care.round+=1
	if recruit_status=="joined" and care.recruit=="healthy" and distance(cell_at(recruit.position),THREAT)<=6 and clear_shot(cell_at(recruit.position),THREAT) and care.threat>0:
		care.threat=maxi(0,int(care.threat)-1);care.assists+=1;care_beam=1.0;lines.append("The traveler fires once: 1 impact.")
	if care_cover:care.cover=true;lines.append("The pet returns with a cover plate: 1 pressure absorbed this turn.")
	if care.threat>0:
		care_pulse=1.0
		var damage:=maxi(0,2-int(care.guard)-(1 if care_cover else 0));hp=maxi(0,hp-damage);lines.append("The creature lashes out: you lose %d health."%damage)
		if care.pet=="healthy" and distance(cell_at(pet.position),THREAT)<=6 and clear_shot(cell_at(pet.position),THREAT):care.pet="injured";lines.append("The pet takes a glancing strike. Fetch is disabled until desk care; retreat carries it safely.")
		if care.round>=2 and recruit_status=="joined" and care.recruit=="healthy" and distance(cell_at(recruit.position),THREAT)<=6 and clear_shot(cell_at(recruit.position),THREAT):care.recruit="downed";lines.append("The traveler goes down, breathing. Retreat includes a rescue sling; nobody is abandoned.")
	else:care.encounter="cleared";care.victories+=1;lines.append("The latch is secured. No currency or supplies awarded.")
	care.points=4;care.guard=0
	if hp==0:
		phase="defeat";sync_care();message="Defeated. Continue restores the latest living snapshot, with its actual conditions and resources.";work.clear();return
	commit_care(care_before," ".join(lines))
func start_retreat(overhead:bool) -> bool:
	if not active_breach():return reject("No active breach to retreat from. Ordinary doors remain available.")
	var route:Array[Vector2]=pet.find_route(player_cell,Vector2i(0,5))
	if not overhead and route.is_empty():return reject("West evacuation route is blocked. No one moved. Call evacuation for overhead rescue; it forfeits this attempt without payment.")
	# Rescue first requires a connected path from each member to the carrier.
	if not overhead:
		for actor in [pet,recruit] if recruit_status=="joined" else [pet]:
			if cell_at(actor.position)!=player_cell and actor.find_route(cell_at(actor.position),player_cell).is_empty():return reject("A party member cannot reach the rescue sling. Call evacuation to lift everyone over the obstruction.")
	care_before=snapshot();care_motion="evacuate" if overhead else "rescue_pet";care_clock=0;busy=true
	rescue_routes.clear()
	if not overhead:
		rescue_routes.append(recruit.find_route(cell_at(recruit.position),player_cell) if recruit_status=="joined" else [])
		rescue_routes.append(route)
		care_route.assign(pet.find_route(cell_at(pet.position),player_cell))
	else:care_route.clear()
	sync_care()
	message="Overhead rescue requested. The party is lifted together; the attempt is forfeited." if overhead else "You secure the injured in the rescue sling and lead the whole party west. Conditions remain until explicit care."
	return true
func finish_retreat() -> void:
	care.encounter="retreated";care.retreats+=1;care.guard=0
	location="hub";player_cell=Vector2i(10,1);human.position=point(player_cell);pet.position=point(Vector2i(10,2));pet.reset_path()
	if recruit_status=="joined":recruit.position=point(Vector2i(10,0));recruit.reset_path()
	if commit_care(care_before,"Everyone returns to the hub. Pet: %s; traveler: %s. The rescue sling keeps a downed companion with you during travel. Go to shelter, then go to desk for care; rest alone will not heal them."%[care.pet,care.recruit]):
		set_location_art();sync_privacy();recent="";previous="";work.clear()
func finish_aid() -> void:
	care.aid_steps-=1
	var actor:String=care.aid_actor
	if care.aid_steps==0:care[actor]="healthy";care.assisted+=1;care.aid_actor=""
	commit_care(care_before,"Assisted care complete. %s capability restored; no funds spent."%actor if care.aid_steps==0 else "First care round complete. Patient still impaired. Continue assisted care for the final six-second round, or cancel assistance.")
func _process(delta:float) -> void:
	if care_motion!="":
		refresh_ui();queue_redraw()
		if get_tree().paused:return
		care_clock+=delta
		var actor:Node2D=pet if care_motion in ["turn","rescue_pet"] else recruit if care_motion=="rescue_recruit" else human
		if not care_route.is_empty():
			actor.position=actor.position.move_toward(care_route[0],delta*180)
			if actor.position.distance_to(care_route[0])<0.1:care_route.pop_front()
			if care_motion=="retreat":
				# Joined party is visibly carried, not independently wall-walking.
				pet.position=human.position
				if recruit_status=="joined":recruit.position=human.position
			return
		if care_motion in ["rescue_pet","rescue_recruit"]:
			care_route.assign(rescue_routes.pop_front());care_motion="rescue_recruit" if care_motion=="rescue_pet" else "retreat";return
		if care_motion=="evacuate":
			human.modulate.a=maxf(0,1-care_clock/2);pet.modulate.a=human.modulate.a;recruit.modulate.a=human.modulate.a
		if care_clock<(6.0 if care_motion=="aid" else 2.0 if care_motion=="evacuate" else 1.0):return
		var finished:=care_motion;care_motion="";busy=false;human.modulate=Color.WHITE
		if finished=="turn":finish_breach_turn()
		elif finished=="aid":finish_aid()
		else:finish_retreat()
		sync_care();return
	super._process(delta)
	if care_ready:
		sync_care()
		if not get_tree().paused:care_beam=maxf(0,care_beam-delta);care_pulse=maxf(0,care_pulse-delta)
func refresh_ui() -> void:
	super.refresh_ui()
	if not care_ready:return
	if location=="approach" and not active_breach():detail.text="North range: harmless practice. Breach: real danger. Return west to the hub."
	if active_breach():
		status.text="Containment breach · Your decision" if phase!="defeat" else "Defeated · Continue your save"
		context_line.text="Health %d/6 · Creature %d/12 · AP %d/4 · Pet %s · Traveler %s"%[hp,care.threat,care.points,care.pet,care.recruit]
		detail.text="End turn: allies act, then creature. Retreat rescues the party. No automatic turns."
		play_panel.show();chapter_panel.hide();buttons.use.hide()
		for id in ["move","bolt","power","end"]:buttons[id].disabled=not care_idle()
	elif care.aid_actor!="":
		status.text="Assisted care · Stay at the desk"
		context_line.text="Patient: %s · Rounds remaining: %d · No payment"%[care.aid_actor,care.aid_steps]
		detail.text="Continue assisted care: six seconds. Cancel assistance discards progress."
	if care_motion!="":activity.text=message
func refresh_choices() -> void:
	if active_breach() or care.aid_actor!="":
		for child in choices.get_children():child.queue_free()
		if active_breach():
			for item in [["Shoot","shoot creature"],["Guard","guard"],["End turn","end turn"],["Retreat","retreat"],["Evacuate","call evacuation"],["Party status","how is the pet?"]]:add_world_choice(item[0],item[1])
		else:
			add_world_choice("Attend care round","continue assisted care");add_world_choice("Cancel assistance","cancel assistance")
		return
	super.refresh_choices()
	if location=="approach":
		for child in choices.get_children():child.queue_free()
		for item in [["To hub","go to hub"],["Range","go to range then inspect range"],["Teach cover fetch","go to range then teach the pet cover fetch"],["Breach / risk","inspect breach"],["Enter breach","go to breach then enter breach"],["Survey","go to marker then survey the approach"],["Party status","how is the pet?"]]:add_world_choice(item[0],item[1])
	if location=="shelter" and reward!="":
		if care_menu:
			for child in choices.get_children():child.queue_free()
			for item in [["Pet care · 2","treat the pet"],["Traveler care · 2","help the companion recover"],["Free pet assistance","begin assisted pet care"],["Free traveler assistance","begin assisted companion care"]]:add_world_choice(item[0],"go to desk then "+item[1])
			add_world_choice("Care / costs","what does treatment cost?");add_world_choice("Back","close care menu")
		else:add_world_choice("Companion care","what does treatment cost?")
func _draw() -> void:
	super._draw()
	if not care_ready:return
	if location=="approach":
		draw_arc(point(BREACH),24,0,TAU,32,Color("e4a47c"),3,true)
		if not care.cover:draw_rect(Rect2(point(PLATE)-Vector2(12,8),Vector2(24,16)),Color("aebdc5"))
	if active_breach():
		draw_arc(point(THREAT),30,0,TAU,32,Color("d8877c"),3,true)
		if care_pulse>0:
			draw_arc(point(THREAT)-Vector2(0,35),35+80*(1-care_pulse),0,TAU,48,Color(0.9,0.5,0.35,care_pulse),5,true)
			draw_line(point(THREAT)-Vector2(0,35),human.position-Vector2(0,35),Color(0.9,0.5,0.35,care_pulse),3,true)
		if care_beam>0:draw_line(recruit.position-Vector2(0,40),point(THREAT)-Vector2(0,40),Color("efdc92"),4,true)
	if care.pet=="injured":draw_arc(pet.position,23,0,TAU,32,Color("e79e73"),4,true)
	if care.recruit=="downed" and recruit.visible:draw_line(recruit.position-Vector2(20,0),recruit.position+Vector2(20,0),Color("e99595"),6,true)
