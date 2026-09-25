extends RefCounted
# Bounded English grammar. Output is a proposal, never game state.
const MAX_COMMAND_LENGTH:=1000
const MAX_ACTIONS:=128
const DIRECTIONS={"up":Vector2i.UP,"north":Vector2i.UP,"down":Vector2i.DOWN,"south":Vector2i.DOWN,"left":Vector2i.LEFT,"west":Vector2i.LEFT,"right":Vector2i.RIGHT,"east":Vector2i.RIGHT}
static func rx(pattern:String,text:String) -> RegExMatch:
	var regex:=RegEx.new();regex.compile(pattern);return regex.search(text)
static func normalize(text:String) -> String:
	var t:=text.to_lower().strip_edges().replace("’","'").trim_suffix(".").trim_suffix("!")
	for prefix in ["please ","could you ","can you ","i want to ","i'd like to ","let's "]:
		if t.begins_with(prefix):t=t.substr(prefix.length())
	return t
static func interpret(text:String,targets:Dictionary,recent:String="") -> Dictionary:
	if text.length()>MAX_COMMAND_LENGTH:return {"error":"Use at most 1000 characters per request."}
	var t:=normalize(text)
	if t.is_empty():return {"error":"Type an intention or choose an action."}
	if t in ["stop","cancel","halt","never mind","nevermind","take control"]:return {"control":"stop"}
	if t.begins_with("what") or t.begins_with("why") or t.begins_with("how") or t.begins_with("where") or t.ends_with("?"):
		return {"question":t}
	var correction:=false
	for prefix in ["actually, ","actually ","instead, ","instead "]:
		if t.begins_with(prefix):correction=true;t=t.substr(prefix.length());break
	if rx("\\b(don't|do not|never|not)\\b",t):return {"error":"I won't act on a negated request. Say Stop, or name what you want to do instead.","correction":correction}
	var splitter:=RegEx.new();splitter.compile("\\s*(?:,?\\s+then\\s+|;|\\s+and then\\s+|\\s+and\\s+(?=(?:go|walk|enter|leave|interact|inspect|collect|take|ask|use|shoot|end|save|talk|choose|preview|try)\\b))\\s*")
	t=splitter.sub(t,"|",true)
	var actions:Array=[]
	for part in t.split("|",false):
		var result:=clause(part.strip_edges(),targets,recent)
		if result.has("error"):result.correction=correction;return result
		if actions.size()+result.actions.size()>MAX_ACTIONS:return {"error":"That is more than 128 steps. Give a shorter request."}
		actions.append_array(result.actions)
		for action in result.actions:
			if action.has("target"):recent=action.target
	if actions.size()>128:return {"error":"That is more than 128 steps. Give a shorter request."}
	return {"actions":actions,"correction":correction}
static func resolve(text:String,targets:Dictionary,recent:String) -> Dictionary:
	var matches:Array=[]
	for id in targets:
		for alias in targets[id].aliases:
			if rx("\\b"+alias+"\\b",text):
				if id not in matches:matches.append(id)
	if matches.size()==1:return {"target":matches[0]}
	if matches.size()>1:return {"error":"Which target do you mean?","candidates":matches}
	if rx("\\b(it|that|there|this|them)\\b",text) and targets.has(recent):return {"target":recent}
	return {"error":"Name a visible target: "+", ".join(targets.keys())+".","candidates":targets.keys()}
static func clause(t:String,targets:Dictionary,recent:String) -> Dictionary:
	if t in ["look","look around","survey the room","describe the scene","help","options"]:return {"actions":[{"verb":"look"}]}
	var direct={"save":"save","save game":"save","save my game":"save","save progress":"save","save and quit":"quit","continue":"load","continue latest":"load","load latest":"load","resume saved game":"load","end turn":"end","finish my turn":"end","wait a turn":"end","pause":"pause","resume":"resume","use kit":"kit","heal":"kit","recover save access":"recover"}
	if direct.has(t):return {"actions":[{"verb":direct[t]}]}
	var movement:=rx("^(?:move|walk|step|go)\\s+(.+)$",t)
	if movement:
		var words:String=movement.get_string(1)
		for pair in [["one","1"],["two","2"],["three","3"],["four","4"],["five","5"],["six","6"],["seven","7"],["eight","8"],["nine","9"],["ten","10"]]:words=words.replace(pair[0],pair[1])
		var parts:=words.replace(","," and ").split(" and ",false)
		var steps:Array=[];var exact:=true
		for part in parts:
			var m:=rx("^(?:(\\d+)\\s+(?:steps?\\s+)?)?(up|down|left|right|north|south|east|west)(?:\\s+(\\d+)(?:\\s+steps?)?)?$",part.strip_edges())
			if m==null:exact=false;break
			var n:=1
			if not m.get_string(1).is_empty():n=int(m.get_string(1))
			elif not m.get_string(3).is_empty():n=int(m.get_string(3))
			if n<1 or n>64:return {"error":"Use between 1 and 64 steps per direction."}
			if steps.size()+n>MAX_ACTIONS:return {"error":"That is more than 128 steps. Give a shorter request."}
			for i in range(n):steps.append({"verb":"step","direction":DIRECTIONS[m.get_string(2)]})
		if exact:return {"actions":steps}
	if " and " in t:return {"error":"I could not separate those actions. Use then between supported requests."}
	var p:=rx("\\b(blast|shield|dash)\\b",t)
	if p:
		var id:String=p.get_string(1)
		if rx("^(try|preview|demonstrate|show me|test)\\b",t):return {"actions":[{"verb":"preview","value":id}]}
		if rx("^(choose|select|pick|take|give me)\\b",t):return {"actions":[{"verb":"choose","value":id}]}
		if rx("^(use|cast|raise|activate|fire|dash)\\b",t):
			var aimed:=resolve(t,targets,recent)
			if rx("\\b(on|at|against)\\b",t) and not aimed.has("target"):return aimed
			if aimed.has("target") and (id!="blast" or aimed.target!="creature"):
				return {"error":"That power does not support the named target. Blast targets the creature; shield protects you; dash takes a direction."}
			if aimed.get("error","")=="Which target do you mean?":return aimed
			var a={"verb":"power","value":id}
			if id=="dash":
				var dir:=rx("\\b(up|down|left|right|north|south|east|west)\\b",t)
				if dir==null:return {"error":"Which direction for the two-step dash? Try 'dash right'."}
				a.direction=DIRECTIONS[dir.get_string(1)]
			return {"actions":[a]}
	if rx("^(shoot|attack|fire|bolt|zap)\\b",t):
		if not rx("\\b(creature|enemy|bolt|it|that)\\b",t):return {"error":"Use 'shoot the creature' for the basic bolt."}
		var attacked:=resolve(t,targets,recent)
		if attacked.has("target") and attacked.target!="creature":return {"error":"Only the hostile creature is a supported attack target."}
		if attacked.get("candidates",[]).size()>1:return attacked
		return {"actions":[{"verb":"bolt"}]}
	if rx("\\b(join|rejoin|wait|stay|decline)\\b",t) or t in ["travel with pet","travel alone","invite the traveler"]:
		if rx("\\b(pet|animal)\\b",t):return {"error":"Waiting and recruitment choices belong to the traveler. The pet supports following and learned fetch."}
		var verb:="join"
		if "rejoin" in t:verb="rejoin"
		elif "wait" in t or "stay" in t:verb="wait"
		elif "decline" in t or t in ["travel with pet","travel alone"]:verb="decline"
		return {"actions":[{"verb":verb,"target":"traveler"}]}
	if rx("\\b(fetch|retrieve|bring)\\b",t) and rx("\\b(pet|animal|companion)\\b",t):
		if "companion" in t:return {"error":"The traveler cannot fetch. Ask the trained pet, or collect the cache yourself."}
		var target:=resolve(t.replace("pet",""),targets,recent)
		if target.has("error"):return target
		if target.target!="cache":return {"error":"The pet's learned task is the marked cache. It cannot fetch that target."}
		return {"actions":[{"verb":"fetch","target":"cache"}]}
	if rx("^(choose|take|claim|pick|select)\\b",t):
		for id in ["security","equipment","opportunity"]:
			if id in t or (id=="security" and "kits" in t) or (id=="equipment" and "lamp" in t) or (id=="opportunity" and "route" in t):return {"actions":[{"verb":"reward","value":id}]}
	var verb:=""
	if rx("^(go|walk|head|move|approach|return|take me)\\b",t):verb="go"
	elif rx("^(inspect|examine|look at|study|check)\\b",t):verb="inspect"
	elif rx("^(talk|ask|speak|chat)\\b",t):verb="talk"
	elif rx("^(enter|leave|exit)\\b",t):verb="travel"
	elif rx("^(collect|take|retrieve|pick up|grab|open)\\b",t):verb="collect"
	elif rx("^(interact|use|press|activate)\\b",t):verb="interact"
	if verb.is_empty():return {"error":"I couldn't map that request to a supported action. Try a visible choice, 'look around', or a named target."}
	if verb=="travel":return {"actions":[{"verb":"travel","target":"doorway","destination":"shelter" if "shelter" in t and not t.begins_with("leave") and not t.begins_with("exit") else "concourse"}]}
	var target:=resolve(t,targets,recent)
	if target.has("error"):return target
	return {"actions":[{"verb":verb,"target":target.target}]}
