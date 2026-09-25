extends RefCounted
const ITEMS={"lens":"Focus lens","weave":"Guard weave","rig":"Stride rig"}
static func initial() -> Dictionary:
	return {"material":0,"kit_claimed":false,"bundle_exchanged":false,"levels":{"lens":-1,"weave":-1,"rig":-1},"equipped":"","power_level":0,"calibrated":false}
static func effects(state:Dictionary) -> Dictionary:
	var gear:String=state.equipped
	var bonus:int=0 if gear.is_empty() else int(state.levels[gear])+1
	return {"bolt":2+(bonus if gear=="lens" else 0),"blast":3+2*int(state.power_level)+(bonus if gear=="lens" else 0),"shield":2+2*int(state.power_level)+(bonus if gear=="weave" else 0),"guard":bonus if gear=="weave" else 0,"dash":2+int(state.power_level)+(bonus if gear=="rig" else 0)}
static func item_description(id:String) -> String:
	return {"lens":"Focus lens: base adds 1 bolt/blast impact; improved adds 2. No protection or dash bonus.","weave":"Guard weave: base absorbs 1 pulse pressure; improved absorbs 2. Adds to shield. No impact or dash bonus.","rig":"Stride rig: base adds 1 dash cell; improved adds 2. No impact or protection bonus."}[id]+" Improvement costs 4 material. One equipped item at a time."
