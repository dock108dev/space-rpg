extends "res://scripts/connected_world.gd"
const Rules=preload("res://scripts/preparation_rules.gd")
const PreparationSave=preload("res://scripts/preparation_save.gd")
var progression:Dictionary=Rules.initial()
var practice_result:Dictionary={}
var preparation_ready:=false
var preparation_page:="world"
var selected_item:="lens"
var range_visual:Node2D

func create_save_store() -> RefCounted:
	var path:=OS.get_environment("B4_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B4-practice-v1")
	return PreparationSave.new(path)

func _ready() -> void:
	super._ready()

	get_window().title="Space Opera RPG · B4 · Preparation"
	preparation_ready=true;set_location_art();last_context=""
func snapshot() -> Dictionary:
	var data:=super.snapshot();data.merge({"progression_version":1,"progression":progression.duplicate(true)});return data
func apply_snapshot(data:Dictionary) -> void:
	progression=data.get("progression",Rules.initial()).duplicate(true);practice_result={};preparation_page="world"
	super.apply_snapshot(data)
func reset_demo() -> bool:
	var ok:=super.reset_demo()
	if ok:progression=Rules.initial();practice_result={};preparation_page="world";last_context=""
	return ok
func held_bundles() -> int:return 1 if tasks.supplies=="completed" and not progression.bundle_exchanged else 0
func effects() -> Dictionary:return Rules.effects(progression)
func inventory_text() -> String:
	var lines:Array=["Material: %d. One equipment slot; swapping is free." % progression.material]
	for id in Rules.ITEMS:
		lines.append(Rules.ITEMS[id]+": "+("unowned" if progression.levels[id]<0 else "improved" if progression.levels[id]==1 else "base")+(" (equipped)" if progression.equipped==id else ""))
	lines.append("Chosen power: "+(power if power!="" else "not chosen")+"; "+("improved" if progression.power_level==1 else "base")+". Calibration: "+("earned" if progression.calibrated else "test your power at the approach range"))
	return "\n".join(lines)
func bench_text() -> String:
	return "A preparation bench sorts reclaimed parts into a Focus lens, Guard weave and Stride rig. Its sign reads: 'Equipment failure is now a personal choice.' Claim the preparation kit here for all three base items and 20 material, once. Each gear improvement costs 4; your chosen power improvement costs 4 after a range test. Exchange one sealed supply bundle for 4. One equipment slot: choose impact, protection or distance. Inspect an item or compare equipment before spending."
func power_upgrade_text() -> String:
	return "Chosen power: %s. Improvement costs 4 material, after testing that power at the approach range: %s. This is not a class commitment. %s" % [power,{"blast":"blast impact 3 → 5","shield":"shield protection 2 → 4","dash":"dash distance 2 → 3"}.get(power,"choose an initial power first"),"Already improved." if progression.power_level==1 else "No material is spent by asking."]
func range_text() -> String:
	return "An abandoned calibration range still works. The target withstands 5 impact; the harmless pulse measures 4 pressure. Test bolt, test guard, or test your chosen power. Dash starts at the stripe (2,0) and travels east on clear floor. Go to range first. Results are measurements, not injuries or material rewards. A chosen-power test earns calibration once; return to the hub bench to improve it."
func targets() -> Dictionary:
	var result:=super.targets()
	if location=="hub":
		result.bench={"aliases":["bench","preparation bench","workbench","kit"],"cell":Vector2i(2,1),"inspect":bench_text()}
		result.board.inspect+=" The preparation bench nearby offers a one-time kit and paid improvements."
	if location=="approach":result.range={"aliases":["range","practice range","calibration range"],"cell":Vector2i(1,0),"inspect":range_text()}
	for id in Rules.ITEMS:
		result[id]={"aliases":[id,Rules.ITEMS[id].to_lower()],"cell":player_cell,"inspect":Rules.item_description(id)+" State: "+("unowned" if progression.levels[id]<0 else "base" if progression.levels[id]==0 else "improved")+". Material: %d." % progression.material}
	return result
func supply_description() -> String:
	if tasks.supplies!="completed":return super.supply_description()
	return ("The bundle was exchanged for 4 material; no bundle remains. " if progression.bundle_exchanged else "One sealed supply bundle is held. Exchange it at the hub bench for 4 material. ")+("You carried it personally and preserved its label." if supply_method=="personal" else "The pet delivered it and chewed its label. The bench accepts the contents anyway.")
func describe_place() -> String:
	return super.describe_place()+(" Visit the preparation bench for equipment and material." if location=="hub" else " The calibration range offers repeatable, harmless practice." if location=="approach" else " Rest at the desk restores health freely." if location=="shelter" else "")
func question(text:String) -> String:
	if "audience" in text or "feed" in text:return super.question(text)
	if "afford" in text:
		return inventory_text()+"\nEach improvement costs 4. You can fund %d more improvements; eligibility still requires an owned base item or calibrated base power at the bench. Future home/care costs are not implemented." % (int(progression.material)/4)
	if "where" in text and ("more" in text or "material" in text):return "Explicit sources: claim the hub preparation kit (20, once); retrieve and exchange the optional sealed bundle (4, once). Access and survey grant no material. "+("Kit already claimed. " if progression.kit_claimed else "Kit still available. ")+("Bundle already exchanged." if progression.bundle_exchanged else "Bundle exchange still available after retrieval.")
	if "material" in text:return inventory_text()+"\n"+supply_description()
	if "equipment" in text or "inventory" in text or "do i have" in text:return inventory_text()
	if "upgrad" in text or "improv" in text:
		for id in Rules.ITEMS:
			if id in text or Rules.ITEMS[id].to_lower() in text:return Rules.item_description(id)
		if ("this" in text or "that" in text or "it" in text) and recent in Rules.ITEMS:return Rules.item_description(recent)
		return power_upgrade_text() if "power" in text or "shield" in text or "blast" in text or "dash" in text else "Name Focus lens, Guard weave, Stride rig, or your chosen power. Each improvement costs 4."
	if "work" in text or "unfinished" in text or "task" in text or "progress" in text:return "Optional work — supplies: %s; access: %s; survey: %s. Bundles held: %d. %s" % [tasks.supplies,tasks.access,tasks.survey,held_bundles(),supply_description()]
	return super.question(text)
func world_clause(text:String) -> Dictionary:
	if text.begins_with("what") or text.begins_with("where") or text.begins_with("how") or text.ends_with("?"):return {"question":text}
	if text in ["inventory","equipment","compare these","compare equipment","compare items","compare gear"] or text.begins_with("compare "):return {"actions":[{"verb":"compare"}]}
	if text in ["claim kit","claim preparation kit","collect preparation kit","take preparation kit","claim the preparation kit"]:return {"actions":[{"verb":"preparation","operation":"claim"}]}
	if text in ["exchange supply bundle","exchange the supply bundle","exchange bundle","redeem bundle","open supply bundle"]:return {"actions":[{"verb":"preparation","operation":"exchange"}]}
	if text in ["rest","rest at desk","recover at shelter"]:return {"actions":[{"verb":"preparation","operation":"rest"}]}
	if text in ["test power","practice power","test my power","test "+power,"practice "+power,"test bolt","test guard"]:return {"actions":[{"verb":"practice","kind":"bolt" if "bolt" in text else "guard" if "guard" in text else power}]}
	var m:=Language.rx("^(equip|wear|unequip|remove|improve|upgrade)\\b",text)
	if m:
		var op:String=m.get_string(1)
		if op=="wear":op="equip"
		if op=="remove":op="unequip"
		if op=="upgrade":op="improve"
		if op=="unequip" and text in ["unequip","unequip that","remove that"]:
			return {"actions":[{"verb":"preparation","operation":"unequip","item":progression.equipped}]}
		if op=="improve":
			var named:Array=[]
			for name in ["lens","weave","rig","blast","shield","dash","power"]:
				if Language.rx("\\b"+name+"\\b",text):named.append(name)
			if named.size()>1:return {"error":"Choose one improvement: name one item or your chosen power. Nothing spent."}
			for p in ["blast","shield","dash","power"]:
				if Language.rx("\\b"+p+"\\b",text):return {"actions":[{"verb":"preparation","operation":"power","power":power if p=="power" else p}]}
		var matches:Array=[]
		for id in Rules.ITEMS:
			if Language.rx("\\b"+id+"\\b",text) or Rules.ITEMS[id].to_lower() in text:matches.append(id)
		if matches.is_empty() and Language.rx("\\b(it|this|that)\\b",text) and recent in Rules.ITEMS:matches.append(recent)
		if matches.size()!=1:return {"error":"Name one item: Focus lens, Guard weave, or Stride rig. Inspect a choice for cost/effect, then explicitly equip or improve it.","candidates":["lens","weave","rig"]}
		return {"actions":[{"verb":"preparation","operation":op,"item":matches[0]}]}
	return super.world_clause(text)
func execute(action:Dictionary) -> bool:
	if action.verb=="compare":
		preparation_page="gear";say(inventory_text()+"\n"+Rules.item_description("lens")+"\n"+Rules.item_description("weave")+"\n"+Rules.item_description("rig"));last_context="";return true
	if action.verb=="preparation":return transact(action)
	if action.verb=="practice":return practice(action.kind)
	if action.verb=="inspect" and action.get("target","") in Rules.ITEMS:selected_item=action.target;preparation_page="item";last_context=""
	if action.verb=="inspect" and action.get("target","")=="bench":preparation_page="bench";last_context=""
	return super.execute(action)
func nearest_route(target:String) -> Dictionary:
	if target=="range" and location=="approach":
		if player_cell==Vector2i(2,0):return {"route":[]}
		var route:=path_to(Vector2i(2,0))
		return {"route":route} if not route.is_empty() else {"error":"The range stripe is blocked."}
	return super.nearest_route(target)
func at_bench() -> bool:return location=="hub" and distance(player_cell,Vector2i(2,1))<=1
func transact(action:Dictionary) -> bool:
	if not safe_idle():return reject("Finish your action or resume before changing preparation.")
	var op:String=action.operation
	var item:String=action.get("item","")
	if op in ["claim","exchange","improve","power"] and not at_bench():return reject("Go to the preparation bench in the hub first. Inspect it for costs and effects.")
	var before:Dictionary=progression.duplicate(true);var old_hp:=hp
	var outcome:=""
	match op:
		"claim":
			if not package_taken or progression.kit_claimed:return reject("The preparation kit requires your collected package and can be claimed only once.")
			progression.kit_claimed=true;progression.material+=20
			for id in Rules.ITEMS:progression.levels[id]=0
			outcome="The bench releases three base items and 20 material. Nothing is equipped automatically. Compare equipment to choose impact, protection or distance."
		"exchange":
			if not progression.kit_claimed or held_bundles()!=1:return reject("Exchange requires the claimed kit and one unexchanged sealed supply bundle. No material gained.")
			progression.bundle_exchanged=true;progression.material+=4;outcome="The bench opens the sealed bundle: four usable material units. Bundle consumed once. "+("Your intact label is recorded." if supply_method=="personal" else "The chewed label is recorded; contents are accepted.")
		"equip","unequip","improve":
			if item not in Rules.ITEMS or progression.levels[item]<0:return reject("Name an owned item. Claim the preparation kit first.")
			if op=="equip":
				if progression.equipped==item:return reject("That item is already equipped; no bonus added.")
				progression.equipped=item;outcome=Rules.ITEMS[item]+" equipped. Previous gear stays in inventory; only this slot contributes."
			elif op=="unequip":
				if progression.equipped!=item:return reject("That item is not equipped.")
				progression.equipped="";outcome=Rules.ITEMS[item]+" unequipped. Its bonus is removed; ownership is retained."
			else:
				if progression.levels[item]!=0:return reject("Already improved. Each item has one improved tier.")
				if progression.material<4:return reject("Need 4 material. You have %d. Nothing spent." % progression.material)
				progression.levels[item]=1;progression.material-=4;outcome=Rules.ITEMS[item]+" improved for 4 material. "+Rules.item_description(item)
			select_reference(item)
		"power":
			if action.get("power",power)!=power:return reject("Improve the power you actually chose: "+power+".")
			if not progression.kit_claimed or not progression.calibrated:return reject("Claim your kit, then test your chosen power at the approach range to earn calibration.")
			if progression.power_level==1:return reject("Your chosen power is already improved.")
			if progression.material<4:return reject("Need 4 material. Nothing spent.")
			progression.power_level=1;progression.material-=4;outcome="Calibration applied for 4 material. "+power_upgrade_text()
		"rest":
			if location!="shelter" or distance(player_cell,SHELTER_REWARD)>1:return reject("Rest beside the shared shelter desk. Recovery is free.")
			hp=6;outcome="A shared cot and basic supplies restore your health to 6. No materials or kits spent; this shelter is still unowned and nonprivate."
		_:return reject("Unknown preparation action.")
	if not persist():
		var failure:=message;progression=before;hp=old_hp;message=failure+" Preparation unchanged; nothing spent or granted.";return false
	epoch+=1;last_context="";message=outcome+" Material %d → %d." % [before.material,progression.material];return true
func practice(kind:String) -> bool:
	if not safe_idle() or location!="approach" or not progression.kit_claimed:return reject("Claim the preparation kit, then go to the approach range at a safe moment.")
	if kind not in ["bolt","guard",power]:return reject("Test bolt, guard, or the power you chose.")
	if distance(player_cell,Vector2i(1,0))>1:return reject("Go to range first; each test starts beside the stripe.")
	var stats:=effects();var result:Dictionary={"kind":kind};var start:=player_cell
	match kind:
		"bolt","blast":result.impact=stats[kind];result.remaining=maxi(0,5-int(result.impact));result.success=result.remaining==0
		"shield","guard":result.protection=stats[kind];result.pressure=maxi(0,4-int(result.protection));result.success=result.pressure==0
		"dash":
			if player_cell!=Vector2i(2,0):return reject("For the dash test stand on stripe (2,0): go to range, then move right if beside its west edge.")
			for step in range(1,int(stats.dash)+1):
				if not floor_free(player_cell+Vector2i.RIGHT*step):return reject("The dash lane is blocked; no calibration recorded.")
			player_cell+=Vector2i.RIGHT*int(stats.dash);result.distance=stats.dash;result.success=int(stats.dash)>=4
	var before:Dictionary=progression.duplicate(true)
	if kind==power:progression.calibrated=true
	if not persist():
		progression=before;player_cell=start;return false
	practice_result=result
	if is_instance_valid(range_visual):range_visual.get_child(0).rotation=0.9 if kind in ["blast","bolt"] and result.success else 0.0
	if kind=="dash":animate("dash",0.6,point(start),point(player_cell));message="Dash carries you %d cells along the lane; four reaches the far marker. %s" % [result.distance,"Marker reached." if result.success else "Short of marker."]
	elif kind in ["blast","bolt"]:
		effect_from=human.position-Vector2(0,50);effect_to=point(Vector2i(6,0))-Vector2(0,35);animate(kind,0.7,human.position,human.position);message="%s hits for %d impact. Target integrity: 5 → %d. %s" % [kind.capitalize(),result.impact,result.remaining,"Target folds." if result.success else "Target holds."]
	else:
		animate("shield",0.7,human.position,human.position);message="The harmless 4-pressure pulse meets %d protection: %d pressure reaches the sensor. %s" % [result.protection,result.pressure,"Fully blocked." if result.success else "Sensor flashes amber."]
	message+=" No resources awarded or spent."+(" Power calibration earned; improve at the hub bench for 4." if kind==power and not before.calibrated else "")
	last_context="";queue_redraw();return true
func travel(destination:String) -> bool:
	var ok:=super.travel(destination)
	if ok:preparation_page="world";practice_result={};last_context=""
	return ok
func interact() -> bool:
	if at_bench() and safe_idle():preparation_page="bench";say(bench_text());last_context="";return true
	if location=="approach" and distance(player_cell,Vector2i(1,0))<=1 and safe_idle():say(range_text());last_context="";return true
	return super.interact()
func refresh_choices() -> void:
	if not preparation_ready or location not in ["hub","approach","shelter"]:super.refresh_choices();return
	if not clarification.is_empty():super.refresh_choices();return
	if location=="hub" and preparation_page in ["bench","gear","item"]:
		for child in choices.get_children():child.queue_free()
		if preparation_page=="bench":
			add_world_choice("Compare gear","compare equipment")
			add_world_choice("Claim kit · +20","claim preparation kit")
			add_world_choice("Exchange · +4","exchange supply bundle")
			add_world_choice("Power cost/effect","what would improving my power change?")
			add_world_choice("Improve power · 4","improve my power")
		elif preparation_page=="gear":
			for id in Rules.ITEMS:add_world_choice(Rules.ITEMS[id],"inspect "+id)
			add_world_choice("Inventory","what equipment do I have?")
		else:
			add_world_choice("Equip "+selected_item,"equip "+selected_item)
			add_world_choice("Unequip","unequip that")
			add_world_choice("Improve · 4","improve "+selected_item)
			add_world_choice("Compare gear","compare equipment")
		add_world_choice("Bench details","inspect bench")
		add_world_choice("To approach","go to approach")
		return
	if location=="hub":
		for child in choices.get_children():child.queue_free()
		add_world_choice("Look / work","what work is unfinished?")
		add_world_choice("To shelter","go to shelter")
		add_world_choice("To approach","go to approach")
		add_world_choice("Preparation","go to bench then inspect bench")
		add_world_choice("Read work board","inspect board")
		if tasks.supplies!="completed":
			if tasks.supplies=="skipped":add_world_choice("Resume supplies","resume supplies")
			else:
				add_world_choice("Carry supplies","go to supplies then collect supplies")
				add_world_choice("Pet retrieves","ask pet to fetch supplies")
		if tasks.access!="completed":add_world_choice("Resume access" if tasks.access=="skipped" else "Restore access","resume access" if tasks.access=="skipped" else "go to access then restore access")
		return
	super.refresh_choices()
	if location=="hub":add_world_choice("Preparation","go to bench then inspect bench")
	elif location=="approach":
		add_world_choice("Go to range","go to range")
		add_world_choice("Test power","test power")
		add_world_choice("Test bolt","test bolt")
		add_world_choice("Test guard","test guard")
	elif not reward.is_empty():add_world_choice("Free rest","go to desk then rest")
func refresh_ui() -> void:
	super.refresh_ui()
	if not preparation_ready:return
	var summary:=readable_message(message)
	feedback.text=summary if summary.length()<=105 else summary.left(102)+"…"
	if location in ["hub","approach"]:
		context_line.text="%s · Health %d/6 · Material %d · %s · Bundle %d" % ["Hub" if location=="hub" else "Approach",hp,progression.material,Rules.ITEMS.get(progression.equipped,"No gear"),held_bundles()]
		detail.text="One slot: impact, guard or distance. Improvements cost 4 at the hub bench." if location=="hub" else "Range: test power, bolt or guard. No rewards; no injuries."
		status.text="Choose your preparation" if location=="hub" else "Test your preparation"
func set_location_art() -> void:
	super.set_location_art()
	if not preparation_ready:return
	if location in ["hub","approach"]:
		var anchor:=Node2D.new();anchor.position=point(Vector2i(2,1) if location=="hub" else Vector2i(6,0))+Vector2(0,20);sorted.add_child(anchor);art.scenery.append(anchor)
		if location=="approach":range_visual=anchor
		var sprite:=Sprite2D.new();sprite.texture=load("res://art/b4/bench.svg" if location=="hub" else "res://art/b4/range.svg");sprite.position=Vector2(0,-38);anchor.add_child(sprite)
func _draw() -> void:
	super._draw()
	if not preparation_ready:return
	if location=="approach":
		draw_line(point(Vector2i(2,0))+Vector2(0,15),point(Vector2i(7,0))+Vector2(0,15),Color("c8bd87"),3,true)
		for x in [2,6,7]:draw_line(point(Vector2i(x,0))+Vector2(0,4),point(Vector2i(x,0))+Vector2(0,26),Color("c8bd87"),3,true)
		if not practice_result.is_empty():
			var color:=Color("a8dbb1") if practice_result.success else Color("e0b569")
			draw_arc(point(Vector2i(6,0))-Vector2(0,35),30,0,TAU,32,color,5,true)
	if progression.equipped!="" and is_instance_valid(human):
		var color:Color={"lens":Color("eed18e"),"weave":Color("8cd2dd"),"rig":Color("aed19b")}[progression.equipped]
		draw_arc(human.position,23,0,TAU,32,color,3+int(progression.levels[progression.equipped]),true)
