extends "res://scripts/preparation.gd"
const Home=preload("res://scripts/home_rules.gd")
const HomeSave=preload("res://scripts/home_save.gd")
var home:Dictionary=Home.initial()
var home_ready:=false
var furnishing:="chair"
var home_page:="main"

func create_save_store() -> RefCounted:
	var path:=OS.get_environment("B5_SAVE_DIR")
	if path.is_empty():path=ProjectSettings.globalize_path("res://../dev-state/B5-practice-v1")
	return HomeSave.new(path)

func _ready() -> void:
	super._ready()
	home_ready=true
	get_window().title="Space Opera RPG · B5 · A place of your own"
	set_location_art();sync_privacy();last_context=""
func snapshot() -> Dictionary:
	var data:=super.snapshot();data.merge({"home_version":1,"home":home.duplicate(true)});return data
func apply_snapshot(data:Dictionary) -> void:
	home=data.get("home",Home.initial()).duplicate(true);home_page="main"
	# Hide before the parent restores position/history or rebuilds UI.
	if data.get("location","")=="home":audience.hide();audience.text=""
	super.apply_snapshot(data);sync_privacy()
func reset_demo() -> bool:
	var ok:=super.reset_demo()
	if ok:home=Home.initial();home_page="main";sync_privacy();last_context=""
	return ok
func world_doors() -> Dictionary:
	if location=="home":return {"hub":Vector2i(0,5)}
	var result:=super.world_doors().duplicate()
	if location=="hub":result.home=Vector2i(11,5)
	return result
func inside(cell:Vector2i) -> bool:
	if location=="home":return cell.x>=0 and cell.x<12 and cell.y>=0 and cell.y<7
	return super.inside(cell)
func floor_free(cell:Vector2i) -> bool:
	if location=="home":return Home.cell_ok(cell,home) and cell not in extra_blocks
	return super.floor_free(cell)
func private_now() -> bool:return location=="home" and home.owned
func sync_privacy() -> void:
	if not is_instance_valid(audience):return
	audience.visible=not private_now()
	if private_now():audience.text=""
func claim_text() -> String:
	if home.owned:return "The receipt is stamped CLOSED. The arcade dwelling belongs to you: private interior, control of its furnishings, and a permanent route back through the hub. The 10-material settling allowance has already been paid."
	return "The allocation terminal wants your completed collection receipt. Collect the opening package, choose your shelter orientation reward, claim the hub preparation kit, then file settlement claim beside this board. Closing that main-route duty awards the vacant arcade dwelling and 10 material once. 'A roof, in recognition of your continued existence.' No optional work required."
func home_text() -> String:
	var parts:Array=["Your arcade home. The deed names you. The fine print has finally run out of strangers. Walk back through the hub to return; there is no teleportation.","Buy Reading chair, Task lamp or Keepsake shelf for 2 material each. Decorative furnishings grant no stats. Place or move one at window, alcove, reading nook or far wall. Store it to unplace for free.","Improve storage beside the locker for 4 material: deposit/withdraw up to 20 stored material. Rest here freely."]
	for id in Home.NAMES:
		var slot:int=home.furniture[id]
		parts.append(Home.NAMES[id]+": "+("unowned" if slot<0 else "owned, unplaced" if slot==0 else Home.SOCKETS.keys()[slot-1]))
	parts.append("Carried %d · Stored %d/20 · Storage %s." % [progression.material,home.stored,"improved" if home.storage else "not improved"])
	return "\n".join(parts)
func targets() -> Dictionary:
	var result:Dictionary={} if location=="home" else super.targets()
	if location=="hub":
		result.home={"aliases":["home","my home","owned home","property"],"cell":Vector2i(11,5),"inspect":claim_text()}
		result.board.inspect+="\n"+claim_text()
	if location=="home":
		result.hub={"aliases":["hub","doorway","door","exit"],"cell":Vector2i(0,5),"inspect":"The interior threshold is private. Outside is the public hub."}
		result.locker={"aliases":["locker","storage"],"cell":Home.LOCKER,"inspect":home_text()}
		for id in Home.NAMES:
			var slot:int=home.furniture[id]
			result[id]={"aliases":[id,Home.NAMES[id].to_lower()],"cell":Home.SOCKETS.values()[slot-1] if slot>0 else player_cell,"inspect":Home.NAMES[id]+" costs 2 material once; move/store free. "+home_text()}
		for socket in Home.SOCKETS:result[socket]={"aliases":[socket],"cell":Home.SOCKETS[socket],"inspect":"One-cell placement socket: "+socket+". Keep the walking lanes clear."}
	return result
func describe_place() -> String:
	if location=="home":return home_text()
	return super.describe_place()+(" The lower east doorway leads to your home." if home.owned else " File a settlement claim at the work board to earn a home.") if location=="hub" else super.describe_place()
func question(text:String) -> String:
	if "audience" in text or "feed" in text or "privacy" in text:return "Player presentation: the entire owned home, including its inside threshold, suppresses outside commentary. The hub is public. Characters and the interpreter never receive audience information. No audience rewards."
	if "get a home" in text or "ownership" in text or "claim" in text:return claim_text()
	if "furnish" in text or "cost" in text or "changed" in text or "storage" in text or "home" in text or "afford" in text:
		home_page="main";last_context="";return home_text() if home.owned else claim_text()
	if "where" in text and ("more" in text or "material" in text):return super.question(text)+" Settlement claim adds 10 once after package, orientation and kit; "+("already paid." if home.owned else "not yet earned or counted.")
	return super.question(text)
func world_clause(text:String) -> Dictionary:
	if text.begins_with("what") or text.begins_with("where") or text.begins_with("how") or text.ends_with("?"):return {"question":text}
	if text in ["file settlement claim","claim home","claim my home"]:return {"actions":[{"verb":"home_action","operation":"claim","target":"board"}]}
	if text in ["improve storage","improve the storage","upgrade storage"]:return {"actions":[{"verb":"home_action","operation":"storage","target":"locker"}]}
	if text in ["rest","rest at home"] and location=="home":return {"actions":[{"verb":"home_action","operation":"rest"}]}
	if text in ["leave home","exit home","return to the hub"] and location=="home":text="go to hub"
	if Language.rx("^(go|walk|head|return|enter|travel)\\b",text) and "home" in text:
		if not home.owned:return {"error":claim_text()}
		if location=="home":return {"question":"home"}
		var clauses:Array=[]
		if location=="concourse":clauses.append({"verb":"deferred","text":"go to shelter"})
		if location!="hub":clauses.append({"verb":"deferred","text":"go to hub"})
		clauses.append({"verb":"deferred","text":"cross home threshold"});return {"actions":clauses}
	if text=="cross home threshold":
		if location!="hub":return {"error":"Reach the hub first."}
		return {"actions":[{"verb":"go","target":"home"},{"verb":"travel","destination":"home"}]}
	var transfer:=Language.rx("^(deposit|withdraw) ([0-9]+)( material)?$",text)
	if transfer:return {"actions":[{"verb":"home_action","operation":transfer.get_string(1),"amount":int(transfer.get_string(2)),"target":"locker"}]}
	var verb:=Language.rx("^(buy|acquire|place|move|store)\\b",text)
	if verb:
		var ids:Array=[]
		for id in Home.NAMES:
			if Language.rx("\\b"+id+"\\b",text):ids.append(id)
		if ids.is_empty() and ("this" in text or "that" in text) and recent in Home.NAMES:ids.append(recent)
		if ids.size()==1:
			var op:String=verb.get_string(1);var id:String=ids[0]
			if op=="acquire":op="buy"
			if op in ["place","move"]:
				var sockets:Array=[]
				for socket in Home.SOCKETS:
					if socket in text:sockets.append(socket)
				if sockets.size()!=1:
					furnishing=id;home_page="placement";last_context=""
					return {"error":"Choose one supported position for "+Home.NAMES[id]+": window, alcove, reading nook, or far wall. Doorway, locker and walking lanes are reserved. Nothing changed."}
				return {"actions":[{"verb":"home_action","operation":"place","item":id,"socket":sockets[0],"target":id}]}
			return {"actions":[{"verb":"home_action","operation":op,"item":id,"target":id}]}
		if verb.get_string(1)!="move":return {"error":"Name one furnishing: Reading chair, Task lamp, or Keepsake shelf."}
	if location=="home" and Language.rx("^(go|return|walk|enter)\\b",text) and "hub" in text:return {"actions":[{"verb":"go","target":"hub"},{"verb":"travel","destination":"hub"}]}
	return super.world_clause(text)
func execute(action:Dictionary) -> bool:
	if action.has("target") and action.get("target_location",location)!=location:return reject("That reference belonged to another place. Name a current target.")
	if action.verb=="home_action":return home_transaction(action)
	if action.verb=="inspect" and action.get("target","") in Home.NAMES:
		furnishing=action.target;home_page="placement";last_context=""
	return super.execute(action)
func home_transaction(a:Dictionary) -> bool:
	if not safe_idle():return reject("Finish the current action or resume first.")
	var op:String=a.operation;var id:String=a.get("item","")
	if op=="claim":
		if location!="hub" or distance(player_cell,Vector2i(3,2))>1:return reject("File beside the hub work board. Go to board first.")
		if home.owned:return reject("Already yours. No second allowance.")
		if not package_taken or reward.is_empty() or not progression.kit_claimed:return reject(claim_text())
	elif location!="home" or not home.owned:return reject("Enter your owned home first.")
	if op in ["storage","deposit","withdraw"] and distance(player_cell,Home.LOCKER)>1:return reject("Go to locker first. Storage improvement costs 4; transfers are free.")
	var old:Dictionary=home.duplicate(true);var wallet:Variant=progression.material;var old_hp:=hp;var outcome:=""
	match op:
		"claim":
			home.owned=true;progression.material+=10
			outcome="Receipt accepted. The terminal awards the arcade dwelling to you and pays 10 settling material once. 'Occupancy is a privilege. Maintaining the roof is now your problem.' The lower east door is yours."
		"buy":
			if id not in Home.NAMES:return reject("Name a furnishing.")
			if home.furniture[id]>=0:return reject("Already owned. Move or store it for free; no duplicate purchase.")
			if wallet<2:return reject("Need 2 carried material; nothing purchased. Withdraw your stored material if available.")
			home.furniture[id]=0;progression.material-=2;furnishing=id;home_page="placement"
			outcome=Home.NAMES[id]+" acquired for 2 material. Choose window, alcove, reading nook or far wall to place it."
		"place":
			if id not in Home.NAMES or home.furniture[id]<0:return reject("Buy that furnishing first; placement never buys it implicitly.")
			if a.get("socket","") not in Home.SOCKETS:return reject("Choose a named furnishing socket; entrances and walking lanes are reserved.")
			var slot:int=Home.SOCKETS.keys().find(a.socket)+1;var c:Vector2i=Home.SOCKETS[a.socket]
			if home.furniture[id]==slot:return reject("Already there. No charge or extra object.")
			if home.furniture.values().any(func(value):return int(value)==slot):return reject("That socket holds another furnishing. Move or store it first.")
			if c==player_cell or Rect2(point(c)-Vector2(30,30),Vector2(60,60)).has_point(pet.position) or (recruit_status=="joined" and Rect2(point(c)-Vector2(30,30),Vector2(60,60)).has_point(recruit.position)):return reject("Someone occupies that footprint. Step away and let your party follow; nothing moved.")
			home.furniture[id]=slot;outcome=Home.NAMES[id]+" placed by the "+a.socket+". No material spent. Walking lanes remain open."
		"store":
			if id not in Home.NAMES or home.furniture[id]<=0:return reject("Only a placed, owned furnishing can be stored.")
			home.furniture[id]=0;outcome=Home.NAMES[id]+" packed away. Still owned, no refund; place it again freely."
		"storage":
			if home.storage:return reject("Storage already improved. No repeated charge.")
			if wallet<4:return reject("Need 4 carried material. Nothing spent.")
			home.storage=true;progression.material-=4;outcome="Locker repaired for 4 material. Its seal now works: deposit and withdraw up to 20 material. It does not manufacture supplies."
		"deposit","withdraw":
			var amount:int=a.get("amount",0)
			if not home.storage:return reject("Improve storage for 4 first.")
			if amount<=0 or amount>20:return reject("Transfer a whole number from 1 to 20.")
			if op=="deposit":
				if amount>wallet or home.stored+amount>20:return reject("Not enough carried material or storage capacity. Nothing transferred.")
				progression.material-=amount;home.stored+=amount
			else:
				if amount>home.stored:return reject("Not that much material in storage. Nothing transferred.")
				home.stored-=amount;progression.material+=amount
			outcome=("Deposited " if op=="deposit" else "Withdrew ")+str(amount)+" material. Carried %d; stored %d/20." % [progression.material,home.stored]
		"rest":hp=6;outcome="You sit without having to justify occupying the room. Health restored to 6; no supplies spent."
		_:return reject("Unknown home action.")
	if not persist():
		var failure:=message;home=old;progression.material=wallet;hp=old_hp;message=failure+" Home and material unchanged.";return false
	epoch+=1;last_context="";set_location_art();sync_privacy();message=outcome;return true
func travel(destination:String) -> bool:
	if destination=="home" and not home.owned:return reject(claim_text())
	var ok:=super.travel(destination);sync_privacy();return ok
func interact() -> bool:
	if location=="home":
		if distance(player_cell,Vector2i(0,5))<=1:return travel("hub")
		home_page="main";last_context="";message=home_text();return true
	return super.interact()
func refresh_ui() -> void:
	super.refresh_ui()
	if not home_ready:return
	if location=="home":
		status.text="A place of your own"
		chapter_buttons.walk.visible=false
		chapter_buttons.interact.text="To hub · E" if distance(player_cell,Vector2i(0,5))<=1 else "Home details · E"
		context_line.text="Owned home · Private · Health %d/6 · Carried %d · Stored %d/20" % [hp,progression.material,home.stored]
		detail.text="Furnish, rearrange, rest. Locker: improve for 4, then deposit / withdraw material."
	sync_privacy()
func refresh_choices() -> void:
	if location!="home":
		super.refresh_choices()
		if location=="hub":add_world_choice("Your home" if home.owned else "Earn a home","go home" if home.owned else "go to board then inspect board")
		if location=="hub" and not home.owned:add_world_choice("File claim","file settlement claim")
		return
	for child in choices.get_children():child.queue_free()
	if home_page=="placement":
		for socket in Home.SOCKETS:add_world_choice(socket.capitalize(),"place "+Home.NAMES[furnishing]+" by the "+socket)
		add_world_choice("Store item","store "+Home.NAMES[furnishing]);add_world_choice("All furnishings","what can I furnish?")
	else:
		for id in Home.NAMES:add_world_choice(("Buy " if home.furniture[id]<0 else "Arrange ")+Home.NAMES[id],("buy " if home.furniture[id]<0 else "inspect ")+Home.NAMES[id])
		add_world_choice("Improve storage · 4" if not home.storage else "Storage details","go to locker then improve storage" if not home.storage else "inspect locker")
		if home.storage:
			add_world_choice("Deposit 1","go to locker then deposit 1 material");add_world_choice("Withdraw 1","go to locker then withdraw 1 material")
	add_world_choice("Home / costs","what can I furnish?");add_world_choice("Rest","rest");add_world_choice("To hub","return to the hub")
func set_location_art() -> void:
	if location!="home":super.set_location_art();return
	for child in location_collisions.get_children():child.free()
	for c in Home.occupied(home):
		var body:=StaticBody2D.new();body.position=point(c);var shape:=CollisionShape2D.new();var box:=RectangleShape2D.new();box.size=Vector2(52,52);shape.shape=box;body.add_child(shape);location_collisions.add_child(body)
	for node in art.scenery:
		if is_instance_valid(node):node.hide();node.queue_free()
	art.scenery.clear();art.package_prop=null;art.cache_prop=null;art.location="home";art.floor_picture.hide()
	art.background.texture=load("res://art/b5/home.svg");art.background.show();art.wall_title.text="Your arcade dwelling";art.wall_detail.text="Owned · Private interior · A door that closes"
	art.prop("doorway",point(Vector2i(0,5))+Vector2(0,30),Vector2(92,110))
	add_home_prop("locker_open" if home.storage else "locker",Home.LOCKER)
	for id in Home.NAMES:
		if home.furniture[id]>0:add_home_prop(id,Home.SOCKETS.values()[int(home.furniture[id])-1])
	recruit.visible=recruit_status=="joined";creature.hide();art.queue_redraw();queue_redraw();sync_privacy()
func add_home_prop(id:String,cell:Vector2i) -> void:
	var anchor:=Node2D.new();anchor.name="Home_"+id;anchor.position=point(cell)+Vector2(0,24);sorted.add_child(anchor);art.scenery.append(anchor)
	var sprite:=Sprite2D.new();sprite.texture=load("res://art/b5/"+id+".svg");sprite.position=Vector2(0,-40);anchor.add_child(sprite)
func _draw() -> void:
	super._draw()
	if location=="home":
		for socket in Home.SOCKETS:
			var c:Vector2i=Home.SOCKETS[socket]
			if c not in Home.occupied(home):draw_arc(point(c),22,0,TAU,24,Color("abbdac"),2,true)
