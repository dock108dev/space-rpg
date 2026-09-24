extends "res://scripts/command_adventure.gd"
const World=preload("res://scripts/world_locations.gd")
const WorldSave=preload("res://scripts/world_save.gd")
const WorldArt=preload("res://scripts/world_art.gd")
var tasks:Dictionary={"supplies":"available","access":"available","survey":"available"}
var supply_method:=""
var supply_trip:=""
var supply_elapsed:=0.0
var world_ready:=false

func _ready() -> void:
	super._ready()
	var path:=OS.get_environment("B3_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B3-practice-v1")
	save_store=WorldSave.new(path)
	get_window().title="Space Opera RPG · B3 · Connected world"
	for node in art.scenery:
		if is_instance_valid(node):node.hide();node.queue_free()
	art.queue_free();art=WorldArt.new();add_child(art);art.configure(self)
	world_ready=true;set_location_art();last_context=""

func inside(cell:Vector2i) -> bool:return location in World.IDS and cell.x>=0 and cell.x<12 and cell.y>=0 and cell.y<7
func floor_free(cell:Vector2i) -> bool:return World.cell_ok(location,cell,tasks.access=="completed") and cell not in extra_blocks
func stable_boundary() -> bool:return supply_trip.is_empty() and super.stable_boundary()
func safe_idle() -> bool:return supply_trip.is_empty() and super.safe_idle()
func snapshot() -> Dictionary:
	var data:=super.snapshot();data.merge({"world_version":1,"tasks":tasks.duplicate(),"supply_method":supply_method});return data
func apply_snapshot(data:Dictionary) -> void:
	tasks=data.get("tasks",{"supplies":"available","access":"available","survey":"available"}).duplicate();supply_method=data.get("supply_method","");supply_trip=""
	super.apply_snapshot(data)
func reset_demo() -> bool:
	if not supply_trip.is_empty():return reject("Stop the pet assignment before starting a new practice.")
	var ok:=super.reset_demo()
	if ok:tasks={"supplies":"available","access":"available","survey":"available"};supply_method="";set_location_art()
	return ok
func targets() -> Dictionary:
	var result:=super.targets()
	result.erase("doorway")
	if location in ["hub","approach"]:
		result.erase("desk");result.erase("package");result.erase("cache");result.erase("control");result.erase("creature")
	for destination in World.DOORS[location]:
		result[destination]={"aliases":[destination,"district hub" if destination=="hub" else "expedition approach" if destination=="approach" else destination+" entrance","door","doorway","exit"],"cell":World.DOORS[location][destination],"inspect":"Reach this threshold to travel to "+destination+". Optional work never locks this route."}
	if location=="hub":
		result.supplies={"aliases":["supplies","salvage","pallet","bundle"],"cell":Vector2i(8,4),"inspect":supply_description()}
		result.access={"aliases":["access","access panel","panel","release","gate"],"cell":Vector2i(5,2),"inspect":"Manual release beside the partition. Restore it to open the central shortcut; the long route around either end is always usable. Status: "+tasks.access+". No power upgrade or fee required."}
		result.board={"aliases":["board","work board","noticeboard","jobs"],"cell":Vector2i(3,2),"inspect":"Three unpaid opportunities. Recover the marked supplies for one sealed bundle; restore the panel for a shorter local walk; survey the approach for visible trail information. Decline or resume any unfinished job. The clerk has been replaced by a sign. Its manners are comparable."}
		result.home={"aliases":["home","owned home","property"],"cell":Vector2i(10,5),"inspect":"Property allocation is unavailable until B5. This shutter grants neither ownership nor privacy."}
	if location=="approach":
		result.survey={"aliases":["survey","survey marker","marker","trail","ridge"],"cell":Vector2i(9,1),"inspect":survey_description()}
		result.objective={"aliases":["objective","expedition","barrier"],"cell":Vector2i(11,3),"inspect":"Beyond the barrier lies the later expedition. Danger, objective and resolution are unavailable until B7. You may explore this approach and return freely."}
	return result
func supply_description() -> String:
	if tasks.supplies=="completed":return "The pallet is empty. One sealed supply bundle is in your inventory. "+("You preserved the delivery label by carrying it yourself." if supply_method=="personal" else "The pet delivered the bundle; the label is now confetti.")+" Spending and upgrades are unavailable until B4."
	return "One marked supply bundle. Carry it yourself: walk to the pallet and preserve its label. Or ask the trained pet to fetch supplies: stay where you are during its physical round trip; expect a chewed label. One bundle either way. Status: "+tasks.supplies+". Skipped work can resume."
func survey_description() -> String:
	if tasks.survey=="completed":return "Survey recorded: a drainage path skirts the ridge and returns to this approach. Fresh scuffs stop at the closed expedition barrier. You have information, not clearance. Expedition effects remain unavailable until B7."
	return "A trail marker faces the broken ridge. Walk beside it and survey the approach to record what can actually be seen. Status: "+tasks.survey+". No expedition combat begins here."
func describe_place() -> String:
	if location=="hub":return "District hub. A shuttered arcade surrounds a work board, salvage pallet and manual access panel. Shelter lies west; the expedition approach lies east. Read the board for optional work. Nobody pays in exposure here; they merely offer it for free. "+("The central shortcut is open." if tasks.access=="completed" else "The partition forces a longer walk around its ends.")
	if location=="approach":return "Expedition approach. Rain-dark paving gives way to a broken ridge, a survey marker and a closed expedition barrier. Explore, survey, or return to the hub. This is preparation space; no expedition has been completed. "+(survey_description() if tasks.survey=="completed" else "")
	return super.describe_place()+(" The east doorway leads to the district hub and optional work." if location=="shelter" else "")
func traveler_line() -> String:
	var line:=super.traveler_line()
	if location in ["hub","approach"]:
		line+=' “A map, a shortcut, and something to carry. Almost a functioning civilization.”'
		if tasks.supplies=="completed":line+=' “Readable paperwork. Bold choice.”' if supply_method=="personal" else ' “Your assistant has eaten the receipt. Again, efficient.”'
	return line
func question(text:String) -> String:
	if "work" in text or "unfinished" in text or "task" in text or "progress" in text:
		if not package_taken:return "Reach shelter first. You have not discovered district work yet."
		return "Optional work — supplies: %s; access: %s; survey: %s. Skipped work can resume at its location. Main travel remains open. Bundles held: %d. B4 spending, B5 home and B7 expedition remain unavailable." % ["active" if not supply_trip.is_empty() else tasks.supplies,tasks.access,tasks.survey,1 if tasks.supplies=="completed" else 0]
	return super.question(text)

func interpret_request(text:String) -> Dictionary:
	var normalized:=Language.normalize(text)
	if normalized.begins_with("what") or normalized.begins_with("where") or normalized.begins_with("why") or normalized.begins_with("how") or normalized.ends_with("?"):return {"question":normalized}
	var correction:=false
	for prefix in ["actually, ","actually ","instead, ","instead "]:
		if normalized.begins_with(prefix):correction=true;normalized=normalized.substr(prefix.length());break
	# Keep inherited early refusal of negated plans; no partial action on negation.
	if Language.rx("\\b(don't|do not|never|not)\\b",normalized):return {"error":"I won't act on a negated plan. Say Stop or name the action you want.","correction":correction}
	var splitter:=RegEx.new();splitter.compile("\\s*(?:,?\\s+then\\s+|;|\\s+and then\\s+|\\s+and\\s+(?=(?:go|walk|enter|leave|interact|inspect|collect|take|ask|use|shoot|end|save|talk|choose|preview|try|restore|survey|skip|resume)\\b))\\s*")
	var parts:=splitter.sub(normalized,"|",true).split("|",false)
	if parts.size()>1:
		if parts.size()>32:return {"error":"Use at most 32 clauses."}
		var actions:Array=[]
		for part in parts:actions.append({"verb":"deferred","text":part.strip_edges()})
		return {"actions":actions,"correction":correction}
	var result:=world_clause(normalized);result.correction=correction;return result
func world_clause(text:String) -> Dictionary:
	if text=="leave shelter" and location=="shelter":return {"actions":[{"verb":"go","target":"concourse"},{"verb":"travel","destination":"concourse"}]}
	if text in ["survey the approach","survey approach","record the trail"]:text="survey marker"
	if text in ["recover supplies","recover the supplies"]:text="collect supplies"
	var task_action:=Language.rx("^(skip|decline|resume|accept|restore|repair|survey|record)\\b",text)
	if task_action:
		var resolved:=Language.resolve(text,targets(),recent)
		if resolved.has("target") and resolved.target in ["supplies","access","survey"]:
			return {"actions":[{"verb":"task","target":resolved.target,"operation":task_action.get_string(1)}]}
		if task_action.get_string(1) not in ["decline","resume"] or Language.rx("\\b(supplies|access|survey)\\b",text):return resolved if resolved.has("error") else {"error":"Name the access panel or survey marker."}
	if Language.rx("\\b(fetch|retrieve|bring)\\b",text) and "pet" in text and ("supplies" in text or "bundle" in text or "salvage" in text or (Language.rx("\\b(it|that)\\b",text) and recent=="supplies")):
		if location!="hub":return {"error":"The salvage pallet is in the hub. Travel there first."}
		return {"actions":[{"verb":"supply_fetch","target":"supplies"}]}
	if Language.rx("^(go|walk|head|return|enter|leave|exit|travel)\\b",text) and not Language.rx("\\b(or|and)\\b",text):
		for destination in World.IDS+["home","objective"]:
			if Language.rx("\\b"+destination+"\\b",text):
				if destination in ["home","objective"]:return {"error":"That destination is unavailable until "+("B5 ownership." if destination=="home" else "B7 expedition.")}
				if destination==location:
					if text.begins_with("leave") or text.begins_with("exit"):
						return {"error":"Name a destination: "+", ".join(World.DOORS[location].keys())+"."}
					return {"error":"You are already in "+location+"."}
				if not World.DOORS[location].has(destination):return {"error":"No direct doorway to "+destination+". From here choose "+", ".join(World.DOORS[location].keys())+"."}
				return {"actions":[{"verb":"go","target":destination},{"verb":"travel","destination":destination}]}
	# Explicit leave shelter retains its accepted westward meaning.
	if text=="leave shelter":return {"actions":[{"verb":"go","target":"concourse"},{"verb":"travel","destination":"concourse"}]}
	return Language.interpret(text,targets(),recent)
func execute(action:Dictionary) -> bool:
	if action.verb=="deferred":
		var proposal:=world_clause(action.text)
		if proposal.has("error"):
			clarification=proposal.get("candidates",[]);last_context="";return reject("After completed actions: "+proposal.error)
		if proposal.has("question"):say(question(proposal.question));return true
		if not proposal.has("actions"):return reject("That continuation is unsupported. Use a current choice.")
		var next:Array=proposal.actions
		for item in next:
			if item.has("target"):item.target_location=location
		work=next+work;current={};return true # Parsing a clause is not a completed game action.
	if action.has("target") and action.get("target_location",location)!=location:return reject("That reference belonged to another place. Name a current target.")
	if action.get("target","") in ["supplies","access","survey"]:select_reference(action.target)
	if action.verb=="supply_fetch":return start_supply_fetch()
	if action.verb=="task":return task_action(action.target,action.operation)
	if action.verb in ["collect","interact"] and action.get("target","") in ["supplies","access","survey"]:return task_action(action.target,"complete")
	if action.verb=="interact" and World.DOORS[location].has(action.get("target","")):return travel(action.target)
	return super.execute(action)
func travel(destination:String) -> bool:
	if not safe_idle() or not package_taken or not World.DOORS[location].has(destination):return reject("Travel requires a safe idle moment, the collected package and a connected doorway.")
	if distance(player_cell,World.DOORS[location][destination])>1:return reject("Walk beside the destination doorway first.")
	var before:=snapshot();var origin:=location
	location=destination
	var entry:Vector2i=World.DOORS[location][origin]
	player_cell=entry+Vector2i(1 if entry.x==0 else -1,0);human.position=point(player_cell)
	pet.position=point(player_cell+Vector2i.DOWN);pet.target=human;pet.reset_path()
	if recruit_status=="joined":recruit.position=point(player_cell+Vector2i.UP)
	recruit.target=human if recruit_status=="joined" else recruit_home;recruit.reset_path()
	if not persist():apply_snapshot(before);return false
	set_location_art();epoch+=1;recent="";previous="";clarification.clear();last_context="";message=describe_place();return true
func interact() -> bool:
	if location=="shelter" and distance(player_cell,World.DOORS.shelter.hub)<=1:return travel("hub")
	if location not in ["hub","approach"]:return super.interact()
	for destination in World.DOORS[location]:
		if distance(player_cell,World.DOORS[location][destination])<=1:return travel(destination)
	for id in ["supplies","access","survey"]:
		if targets().has(id) and distance(player_cell,targets()[id].cell)<=1:return task_action(id,"complete")
	return reject("Stand beside a doorway or task object. Read the current choices for actions.")
func task_action(id:String,operation:String) -> bool:
	if not safe_idle() or not targets().has(id):return reject("That task is unavailable here or an action is still running.")
	if tasks[id]=="completed":return reject("Already completed. Its result is saved; no repeated gain.")
	var before:=snapshot()
	if operation in ["skip","decline"]:tasks[id]="skipped";message="Skipped "+id+". You may resume it here later. Travel remains open."
	elif operation in ["resume","accept"]:tasks[id]="available";message="Resumed "+id+". Approach its target to do the work."
	else:
		if tasks[id]=="skipped":return reject("You skipped this work. Say resume "+id+" first.")
		if distance(player_cell,targets()[id].cell)>1:return reject("Walk beside "+id+" first.")
		tasks[id]="completed"
		match id:
			"supplies":supply_method="personal";message=supply_description()
			"access":message="The manual release opens the central shortcut. The mechanism accepts your effort without asking for a subscription."
			"survey":message=survey_description()
	if not persist():apply_snapshot(before);return false
	set_location_art();last_context="";return true
func start_supply_fetch() -> bool:
	if not safe_idle() or location!="hub" or not learned or tasks.supplies!="available":return reject("Pet retrieval requires the learned mark and available hub supplies. Resume skipped work first.")
	fetch_marker.position=point(Vector2i(8,3));pet.target=fetch_marker;pet.reset_path();supply_trip="outbound";supply_elapsed=0;message="The pet heads to the pallet. You stay here; the bundle counts only when it returns.";last_context="";return true
func load_latest() -> bool:
	if not supply_trip.is_empty():return reject("Stop the pet assignment before Continue.")
	return super.load_latest()
func stop_work(reason:String) -> void:
	if not supply_trip.is_empty():supply_trip="";pet.target=human;pet.reset_path()
	super.stop_work(reason)
func tick_work() -> void:
	if not supply_trip.is_empty():return
	super.tick_work()
func set_location_art() -> void:
	if not world_ready:super.set_location_art();return
	for child in location_collisions.get_children():child.free()
	for cell in World.blocks(location,tasks.access=="completed"):
		var body:=StaticBody2D.new();body.position=point(cell);var shape:=CollisionShape2D.new();var box:=RectangleShape2D.new();box.size=Vector2(52,52);shape.shape=box;body.add_child(shape);location_collisions.add_child(body)
	art.set_location(location);recruit.visible=location=="shelter" or recruit_status=="joined";creature.visible=location=="concourse" and (journey=="encounter" or phase=="selection")
func refresh_ui() -> void:
	super.refresh_ui()
	if not world_ready:return
	var summary:=readable_message(message)
	feedback.text=summary if summary.length()<=155 else summary.left(152)+"…"
	if location in ["hub","approach"]:
		status.text="Explore the district" if location=="hub" else "Survey or return"
		context_line.text=("District hub" if location=="hub" else "Expedition approach")+" · Health %d/6 · Kits %d · Bundle %d · %s" % [hp,kits,1 if tasks.supplies=="completed" else 0,"Pet + traveler" if recruit_status=="joined" else "Pet follows"]
		detail.text="Optional work never locks travel. Ask: what work is unfinished?"
		chapter_buttons.interact.text="Interact nearby · E";chapter_buttons.walk.visible=false
		audience.text="Outside audience (characters cannot see this): Infrastructure has become a side quest."
	elif location=="shelter" and package_taken:detail.text="Shared, not owned or private. West: concourse. East: district hub."
func refresh_choices() -> void:
	if location=="shelter" and package_taken:
		for child in choices.get_children():child.queue_free()
		if not clarification.is_empty():
			for id in clarification:add_world_choice("Inspect "+str(id),"inspect "+str(id))
			return
		add_world_choice("To concourse","go to concourse");add_world_choice("To hub","go to hub")
		if reward.is_empty():
			add_world_choice("Go to desk","go to desk")
			for id in ["security","equipment","opportunity"]:add_world_choice(id.capitalize(),"choose "+id)
		else:
			add_world_choice("Talk traveler","go to traveler then talk to traveler")
			add_world_choice("Approach traveler","go to traveler")
			add_world_choice("Wait here" if recruit_status=="joined" else "Rejoin" if recruit_status=="waiting" else "Join", "have traveler wait here" if recruit_status=="joined" else "rejoin traveler" if recruit_status=="waiting" else "join traveler")
			if recruit_status in ["available","declined"]:add_world_choice("Decline traveler","decline traveler")
			add_world_choice("Save and quit","save and quit")
		return
	if location not in ["hub","approach"]:
		super.refresh_choices()
		if location=="shelter" and package_taken:add_world_choice("District hub","go to hub")
		return
	for child in choices.get_children():child.queue_free()
	if not clarification.is_empty():
		for id in clarification:add_world_choice("Inspect "+str(id),"inspect "+str(id))
		return
	add_world_choice("Look / work","what work is unfinished?")
	for destination in World.DOORS[location]:add_world_choice("To "+destination,"go to "+destination)
	if location=="hub":
		add_world_choice("Read work board","inspect board")
		if tasks.supplies!="completed":
			if tasks.supplies=="skipped":add_world_choice("Resume supplies","resume supplies")
			else:
				add_world_choice("Carry supplies","go to supplies then collect supplies");add_world_choice("Pet retrieves","ask pet to fetch supplies");add_world_choice("Skip supplies","skip supplies")
		if tasks.access!="completed":
			add_world_choice("Resume access" if tasks.access=="skipped" else "Restore access","resume access" if tasks.access=="skipped" else "go to access then restore access");add_world_choice("Skip access","skip access")
	else:
		if tasks.survey!="completed":
			add_world_choice("Resume survey" if tasks.survey=="skipped" else "Survey trail","resume survey" if tasks.survey=="skipped" else "go to marker then survey marker");add_world_choice("Skip survey","skip survey")
		else:add_world_choice("Read survey","inspect marker")
func add_world_choice(label:String,command:String) -> void:
	var button:=Button.new();button.theme=GlassUI.make_theme();button.text=label;button.custom_minimum_size=Vector2(125,44);button.add_theme_font_size_override("font_size",15);choices.add_child(button)
	var binding:=epoch;button.pressed.connect(func():submit(command,"",binding))
func _process(delta:float) -> void:
	super._process(delta)
	if not world_ready or get_tree().paused or supply_trip.is_empty():return
	supply_elapsed+=delta
	if supply_elapsed>45 or (supply_elapsed>0.5 and pet.blocked):
		stop_work("Pet route blocked. No supply bundle was awarded; retry from clear floor.");return
	if supply_trip=="outbound" and pet.position.distance_to(fetch_marker.position)<5:
		supply_trip="returning";supply_elapsed=0;pet.target=human;pet.reset_path();message="The pet lifts the marked bundle. The label has attracted professional interest."
	elif supply_trip=="returning" and pet.position.distance_to(human.position)<90:
		supply_trip="";tasks.supplies="completed";supply_method="pet"
		if not persist():tasks.supplies="available";supply_method="";message="Delivery could not be saved. No bundle awarded; retry when save access is restored."
		else:message=supply_description();set_location_art()
		last_context=""
