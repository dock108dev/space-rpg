extends "res://scripts/chapter_opening.gd"
const Language=preload("res://scripts/adventure_language.gd")
const AdventureSave=preload("res://scripts/adventure_save.gd")
var retrieval:=""
var history:Array=[]
var work:Array=[]
var current:Dictionary={}
var completed:=0
var total:=0
var steps_done:=0
var request_serial:=0
var epoch:=0
var seen:Dictionary={}
var recent:=""
var previous:=""
var last_target_verb:="inspect"
var clarification:Array=[]
var clarification_verb:="inspect"
var command_input:=LineEdit.new()
var transcript:=RichTextLabel.new()
var activity:=Label.new()
var choices:=HFlowContainer.new()
var stop_button:Button
var last_context:=""
var last_message:=""
var ready_adventure:=false
var backend_status:="Offline language interpreter"

func add_button(parent:Node,text:String,callback:Callable) -> Button:
	return super.add_button(parent,text,func():
		if ready_adventure and text not in ["Pause · Esc","Resume · Esc"] and (not work.is_empty() or not current.is_empty()):stop_work("Direct action control reclaimed.")
		callback.call())

func _ready() -> void:
	super._ready()
	var path:=OS.get_environment("B25_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B2.5-practice-v1")
	save_store=AdventureSave.new(path)
	get_window().content_scale_size=Vector2i(1280,980)
	get_window().title="Space Opera RPG · B2.5 · Command adventure"
	var ui:=CanvasLayer.new();ui.layer=3;ui.process_mode=Node.PROCESS_MODE_ALWAYS;add_child(ui)
	var panel:=Panel.new();panel.position=Vector2(16,720);panel.size=Vector2(1248,248);panel.add_theme_stylebox_override("panel",GlassUI.panel_style(true));ui.add_child(panel)
	transcript.position=Vector2(30,732);transcript.size=Vector2(762,166);transcript.add_theme_font_size_override("normal_font_size",18);transcript.scroll_following=true;transcript.selection_enabled=true;ui.add_child(transcript)
	choices.position=Vector2(810,734);choices.size=Vector2(440,180);choices.add_theme_constant_override("h_separation",7);choices.add_theme_constant_override("v_separation",7);ui.add_child(choices)
	activity.position=Vector2(30,899);activity.size=Vector2(1050,24);activity.add_theme_font_size_override("font_size",16);ui.add_child(activity)
	command_input.position=Vector2(30,930);command_input.size=Vector2(990,34);command_input.placeholder_text="Describe an intention…  e.g. go to the package, then inspect it";command_input.add_theme_font_size_override("font_size",18);ui.add_child(command_input)
	command_input.text_submitted.connect(func(value:String):command_input.clear();submit(value))
	var send:=Button.new();send.theme=GlassUI.make_theme();send.text="Send";send.position=Vector2(1030,926);send.size=Vector2(90,40);send.pressed.connect(func():var value:=command_input.text;command_input.clear();submit(value));ui.add_child(send)
	stop_button=Button.new();stop_button.theme=GlassUI.make_theme();stop_button.text="Stop";stop_button.position=Vector2(1130,926);stop_button.size=Vector2(110,40);stop_button.pressed.connect(func():stop_work("Stopped by you."));ui.add_child(stop_button)
	ready_adventure=true
	say(describe_place());refresh_choices()

func say(text:String) -> void:
	if text.is_empty():return
	history.append(text.left(1000))
	while history.size()>60 or JSON.stringify(history).to_utf8_buffer().size()>24000:history.pop_front()
	if is_instance_valid(transcript):transcript.text="\n\n".join(history)

func targets() -> Dictionary:
	var result:Dictionary={
		"doorway":{"aliases":["doorway","door","exit","shelter entrance","shelter","concourse"],"cell":CONCOURSE_DOOR if location=="concourse" else SHELTER_DOOR,"inspect":"Blue paint promises shelter, not safety. A doorway is mercifully too small to print the full terms."},
		"pet":{"aliases":["pet","animal"],"cell":cell_at(pet.position),"inspect":"The small animal watches your hands. "+("It recognizes the supply mark you taught it." if learned else "It follows willingly. Fetch is not something it knows yet.")}}
	if location=="concourse":
		result.package={"aliases":["package","parcel","amber box"],"cell":PACKAGE,"inspect":"An amber welcome package. The collection policy has teeth. "+("You already took its supplies and taught the pet their mark." if package_taken else "Clear the assessment before collecting it." if journey=="encounter" else "Approaching is safe; interacting enters the assessment." if journey=="arrival" else "The threat is gone. The package is yours to collect.")}
		if not reward.is_empty():result.cache={"aliases":["cache","crate","supplies","supply box"],"cell":CACHE,"inspect":cache_description()}
		if enemy_hp>0:result.creature={"aliases":["creature","enemy","guard"],"cell":enemy_cell,"inspect":"The collection creature is alive. Watch its body before ending a turn. Bolt reaches four squares; obstacles block shots."}
		result.control={"aliases":["control","switch","green ring"],"cell":CONTROL,"inspect":"A green emergency control. Beside it, one AP deals two damage, once." if not used else "The control is spent. Its one useful contribution is over."}
	if location=="shelter" or recruit_status=="joined":result.traveler={"aliases":["traveler","recruit","companion","person"],"cell":RECRUIT if location=="shelter" else cell_at(recruit.position),"inspect":"The traveler has a practical bag and the expression of someone whose holiday acquired a plot. "+traveler_line()}
	if location=="shelter":result.desk={"aliases":["desk","rewards","orientation desk"],"cell":SHELTER_REWARD,"inspect":"Orientation offers one choice: two healing kits, a visible field lamp, or directions to the cache. "+("Your choice is already recorded: "+reward+"." if not reward.is_empty() else "No audience prize. Just supplies, with a queue implied by the furniture.")}
	return result

func cache_description() -> String:
	if retrieval=="personal":return "The empty cache still has its routing label. You read 'shared shelter supplies' before taking one kit. The traveler can discuss your careful salvage."
	if retrieval=="pet":return "Empty cache, tooth-marked wrapper. The pet delivered one kit and chewed the routing label. The traveler remembers the enthusiastic delivery."
	return "One recovery kit in a marked crate. Collect it yourself: walk there and preserve the routing label. Send the trained pet: stay here while it makes the round trip, but expect a chewed label. Either way yields one kit, once."
func traveler_line() -> String:
	if retrieval=="personal":return '“Shared shelter supplies. You kept the label? Evidence. How unfashionable.” The traveler remembers your careful retrieval.'
	if retrieval=="pet":return '“The kit survived. The paperwork did not. Your assistant has priorities.” The traveler remembers the pet delivery.'
	if reward.is_empty():return '“Pick something you can use. The desk has three answers and no sympathy.”'
	return '“There is a marked cache back in the concourse. You can carry it, or let your small colleague earn the title.”'
func describe_place() -> String:
	if phase=="selection":return "Shopping concourse. Shutters are down; the welcome package is guarded. An animal follows you. Try blast, shield and dash, then choose one. The previews cannot hurt you."
	if journey=="encounter":return "The assessment is live. Health %d/6, creature %d/6, %d AP. Read the creature's visible posture. Move, shoot, use your power or the green control; end your turn deliberately." % [hp,enemy_hp,ap]
	if location=="shelter":return "Temporary shelter: shared beds, an orientation desk, a traveler and an open exit. Neither owned nor private. "+traveler_line()
	return "Shopping concourse. "+("The creature is down; the package is waiting." if journey=="package" else "The amber package waits behind a very literal assessment." if journey=="arrival" else "The assessment stays cleared. The blue doorway leads to shelter.")+ (" "+cache_description() if not reward.is_empty() else "")

func question(text:String) -> String:
	for id in ["shield","blast","dash"]:
		if id in text:return power_description(id)+" This is advice; no action or AP spent."
	if "audience" in text or "feed" in text:return "Outside commentary is for the real player. Characters cannot see it, know it or earn rewards from it."
	if "cache" in text or "fetch" in text:return cache_description() if not reward.is_empty() else "The pet learns fetch when you collect the package. Orientation will point out a cache; no cache task is available yet."
	if "can i" in text or "do here" in text or "next" in text:return describe_place()+" The choices beside this history are available intentions; movement and action rules still apply."
	var resolved:=Language.resolve(text,targets(),recent)
	if resolved.has("target"):return targets()[resolved.target].inspect
	return describe_place()

func submit(text:String,request_id:String="",context_epoch:int=-1) -> bool:
	if request_id.is_empty():request_serial+=1;request_id="local-%d" % request_serial
	if seen.has(request_id):say("Duplicate request ignored; nothing repeated.");return false
	seen[request_id]=true
	if context_epoch!=-1 and context_epoch!=epoch:say("That choice belongs to an earlier state. Choose from the current options.");return false
	var normalized:=Language.normalize(text)
	if normalized in ["resume","unpause"]:get_tree().paused=false;return true
	if normalized=="pause":get_tree().paused=true;return true
	if normalized in ["actually, the other one","actually the other one","the other one"]:
		stop_work("Correction replaces remaining work.")
		if targets().has(previous):return submit(last_target_verb+" "+previous)
		clarification=targets().keys();clarification_verb=last_target_verb;say("Which one? Choose a visible target.");last_context="";return false
	if normalized.is_valid_int() and not clarification.is_empty():
		var index:=int(normalized)-1
		if index>=0 and index<clarification.size():text=clarification_verb+" "+str(clarification[index])
	var proposal:=Language.interpret(text,targets(),recent)
	if proposal.has("question"):say(question(proposal.question));return true
	if proposal.get("control","")=="stop":stop_work("Stopped by you.");return true
	if proposal.get("correction",false):stop_work("Correction replaces remaining work; completed effects remain.")
	if proposal.has("error"):
		clarification=proposal.get("candidates",[]);clarification_verb="go" if Language.rx("\\b(go|walk|move|approach)\\b",normalized) else "inspect"
		say(proposal.error);last_context="";return false
	if not work.is_empty() or not current.is_empty():say("An intention is already running. Say Stop or 'actually, …' to replace its remaining work.");return false
	clarification.clear();work=proposal.actions;completed=0;steps_done=0;total=work.size()
	for action in work:
		if action.has("target"):action.target_location=location
	say("You: "+text)
	last_context=""
	return true

func stop_work(reason:String) -> void:
	var committed:bool=current.get("committed",false) and current.get("verb","")!="fetch"
	var remaining:=work.size()+(0 if current.is_empty() or committed else 1)
	if committed:completed+=1
	work.clear();current.clear();routine=false
	if not fetch_state.is_empty():fetch_state="";fetch_elapsed=0;pet.target=human;pet.reset_path()
	epoch+=1
	say(reason+" %d completed actions, %d committed walking steps; %d remaining actions canceled. An already committed animation finishes." % [completed,steps_done,remaining])
	last_context=""
func select_reference(id:String) -> void:
	if recent!=id:previous=recent;recent=id

func execute(action:Dictionary) -> bool:
	var verb:String=action.verb
	if action.has("target"):
		if action.get("target_location",location)!=location:return reject("That target belonged to the previous place. Name a current target.")
		if not targets().has(action.target):return reject("That target is no longer present here.")
		select_reference(action.target)
		if action.verb in ["inspect","go","talk","collect","interact"]:last_target_verb=action.verb
	match verb:
		"look":say(describe_place());return true
		"inspect":say(targets()[action.target].inspect);return true
		"talk":
			if distance(player_cell,targets()[action.target].cell)>1:return reject("Walk beside the named character first.")
			if action.target=="traveler":say(traveler_line());return true
			if action.target=="pet":say("The pet watches your hand, unimpressed by the speech. "+("Try asking it to fetch the cache." if learned else "It needs a lesson before it can fetch."));return true
			return reject("That target has no conversation. Try inspecting it.")
		"step":mode="move";return act(player_cell+action.direction)
		"preview":return demonstrate(action.value)
		"choose":return choose(action.value)
		"bolt":mode="bolt";return act(enemy_cell)
		"power":
			if action.value!=power:return reject("Your chosen power is "+power+". A question can explain the others.")
			mode="power";return act(player_cell+action.direction*2 if power=="dash" else player_cell if power=="shield" else enemy_cell)
		"end":return end_turn()
		"travel":return travel(action.destination)
		"reward":return choose_reward(action.value)
		"join":return join_recruit()
		"decline":return decline_recruit()
		"wait":return wait_recruit()
		"rejoin":return rejoin_recruit()
		"fetch":return fetch_cache()
		"collect":
			if action.target=="cache":return collect_cache()
			if action.target=="package":
				if package_taken:return reject("The package was already collected. It cannot be collected again.")
				return interact()
			return reject("That target cannot be collected.")
		"interact":
			if action.target not in ["control","package","doorway","desk","traveler"]:return reject("Inspect that target for its supported actions.")
			if action.target=="control":mode="use";return act(CONTROL)
			if distance(player_cell,targets()[action.target].cell)>1:return reject("Walk beside the named target first.")
			return interact()
		"save":return manual_save()
		"quit":return save_and_quit()
		"load":return load_latest()
		"pause":get_tree().paused=true;return true
		"resume":get_tree().paused=false;return true
		"kit":return use_kit()
		"recover":return recover_save_access()
	return reject("Unsupported action.")

func nearest_route(target:String) -> Dictionary:
	if not targets().has(target):return {"error":"Target is no longer in this place."}
	var cell:Vector2i=targets()[target].cell
	if distance(player_cell,cell)<=1:return {"route":[]}
	var best:Array=[]
	for offset in DIRS:
		var goal:Vector2i=cell+offset
		if not floor_free(goal):continue
		var route:=path_to(goal)
		if not route.is_empty() and (best.is_empty() or route.size()<best.size()):best=route
	return {"route":best} if not best.is_empty() else {"error":"No reachable interaction point beside "+target+"."}

func tick_work() -> void:
	if get_tree().paused or busy or not fetch_state.is_empty():return
	if not current.is_empty():
		if current.verb=="go":
			if current.get("target_location",location)!=location:fail_work("Destination belonged to the previous place.");return
			var route:=nearest_route(current.target)
			if route.has("error"):fail_work(route.error);return
			if not route.route.is_empty():
				mode="move"
				if not act(route.route[0]):fail_work(message);return
				steps_done+=1;return
			say("Arrived beside "+current.target+" after %d walking steps." % steps_done)
		completed+=1;current={}
		if work.is_empty():say("Intention finished: %d actions, %d walking steps." % [completed,steps_done]);return
	if work.is_empty():return
	current=work.pop_front()
	if current.verb=="go":
		if not targets().has(current.target):fail_work("That destination is not present.");return
		select_reference(current.target);last_target_verb="go";return
	var before_journey:=journey
	if not execute(current):fail_work(message if not message.is_empty() else "The action is unavailable now.");return
	if current.is_empty():return # Continue clears the old queue/context.
	current.committed=true
	if current.verb=="step":steps_done+=1
	if journey=="encounter" and before_journey!="encounter":
		completed+=1;current={};work.clear();say("Assessment entered. Remaining plan stopped for a new tactical decision.")
	elif current.verb=="end":
		work.clear();say("Turn ended. Remaining plan stopped so you can reassess the creature's response.")
func fail_work(reason:String) -> void:
	var remaining:=work.size()+1
	say("Stopped: "+reason+" Completed %d actions and %d walking steps; %d actions remain unexecuted." % [completed,steps_done,remaining])
	work.clear();current={};last_context=""

func collect_cache() -> bool:
	if not safe_idle() or location!="concourse" or reward.is_empty() or not learned or cache_taken:return reject("The cache requires completed orientation and can be collected only once at a safe moment.")
	if distance(player_cell,CACHE)>1:return reject("Walk beside the cache to collect it yourself.")
	cache_taken=true;kits+=1;retrieval="personal"
	if not persist():cache_taken=false;kits-=1;retrieval="";return false
	message="One kit collected by hand. You preserve the routing label: shared shelter supplies. The traveler will have something to say about this.";return true
func snapshot() -> Dictionary:
	var data:=super.snapshot();data.merge({"adventure_version":1,"retrieval":retrieval,"history":history.duplicate()});return data
func persist(kind:String="auto") -> bool:
	var assigned:=cache_taken and retrieval.is_empty()
	if assigned:retrieval="pet"
	var ok:=super.persist(kind)
	if not ok and assigned:retrieval=""
	return ok
func apply_snapshot(data:Dictionary) -> void:
	retrieval=data.get("retrieval","");history=data.get("history",[]).duplicate()
	work.clear();current={};recent="";previous="";clarification.clear();epoch+=1
	super.apply_snapshot(data)
	if ready_adventure:say("Continued saved state. No old command is active. "+describe_place());last_context=""
func reset_demo() -> bool:
	var ok:=super.reset_demo()
	if ok:retrieval="";history.clear();work.clear();current={};recent="";previous="";epoch+=1;say(describe_place());last_context=""
	return ok
func travel(destination:String) -> bool:
	var ok:=super.travel(destination)
	if ok:epoch+=1;recent="";previous="";last_context=""
	return ok

func refresh_choices() -> void:
	for child in choices.get_children():child.queue_free()
	var options:Array=[]
	if not clarification.is_empty():
		for id in clarification:options.append([clarification_verb.capitalize()+" "+str(id),clarification_verb+" "+str(id)])
	elif phase=="selection":
		for id in ["blast","shield","dash"]:options.append(["Try "+id,"try "+id])
		if demonstrated.size()==3:
			for id in ["blast","shield","dash"]:options.append(["Choose "+id,"choose "+id])
	elif journey=="encounter":options=[["Look / tactics","look around"],["Shoot creature","shoot creature"],["Use "+power,"use "+power if power!="dash" else "dash down"],["End turn","end turn"]]
	elif journey in ["arrival","package"]:options=[["Go to package","go to package"],["Inspect package","inspect package"],["Enter assessment" if journey=="arrival" else "Collect package","interact with package"]]
	elif location=="shelter":
		if reward.is_empty():
			options=[["Go to desk","go to desk"],["Two kits","choose security"],["Field lamp","choose equipment"],["Cache route","choose opportunity"]]
		else:options=[["Talk to traveler","go to traveler, then talk to traveler"],["Approach traveler","go to traveler"],["Join me" if recruit_status in ["available","declined"] else "Wait here" if recruit_status=="joined" else "Rejoin me","join traveler" if recruit_status in ["available","declined"] else "have traveler wait here" if recruit_status=="joined" else "rejoin traveler"],["Leave shelter","go to doorway, then leave shelter"],["Save and quit","save and quit"]]
	else:
		options=[["Enter shelter","go to doorway, then enter shelter"]]
		if not reward.is_empty() and not cache_taken:options.append_array([["Read cache tradeoff","inspect cache"],["Collect it yourself","go to cache, then collect cache"],["Send pet","ask pet to fetch cache"]])
	var binding:=epoch
	for option in options:
		var button:=Button.new();button.theme=GlassUI.make_theme();button.text=option[0];button.custom_minimum_size=Vector2(130,36);button.add_theme_font_size_override("font_size",16);choices.add_child(button)
		var command:String=option[1]
		button.pressed.connect(func():submit(command,"",binding))
func _process(delta:float) -> void:
	super._process(delta)
	if not ready_adventure:return
	tick_work()
	if message!=last_message:
		last_message=message
		if not message.is_empty():say("Preview: "+power_description(preview) if message.begins_with("DEMONSTRATION ONLY") else readable_message(message))
	var context:=str([location,journey,phase,demonstrated,reward,recruit_status,cache_taken,clarification])
	if context!=last_context:last_context=context;refresh_choices()
	activity.text="Paused — Escape resumes; Stop cancels queued work." if get_tree().paused else "Working: %s · %d completed · %d walking steps · %d queued" % [current.get("verb","ready"),completed,steps_done,work.size()] if not current.is_empty() or not work.is_empty() else "Ready · Click the world or press Tab to leave text input and use direct controls."
func _input(event:InputEvent) -> void:
	super._input(event)
	if event is InputEventKey and command_input.has_focus() and event.physical_keycode!=KEY_ESCAPE:return
func _unhandled_key_input(event:InputEvent) -> void:
	if command_input.has_focus():return
	if event.is_pressed() and not event.is_echo() and event.physical_keycode!=KEY_ESCAPE and (not work.is_empty() or not current.is_empty()):stop_work("Direct keyboard control reclaimed.")
	super._unhandled_key_input(event)
func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		command_input.release_focus()
		var pointer:Vector2=get_global_transform_with_canvas().affine_inverse()*event.position
		var clicked:=cell_at(pointer)
		for id in targets():
			if targets()[id].cell==clicked:select_reference(id);break
		if not work.is_empty() or not current.is_empty():stop_work("Direct mouse control reclaimed.")
	super._unhandled_input(event)
