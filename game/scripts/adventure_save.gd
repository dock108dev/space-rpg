extends "res://scripts/chapter_save.gd"
# Independent B2.5 namespace; no reading or migration of B2 snapshots.
func valid(data:Variant) -> bool:
	if not data is Dictionary or data.get("adventure_version",0)!=1:return false
	if data.get("retrieval",null) not in ["","personal","pet"]:return false
	if data.get("cache",false)!=(data.retrieval!=""):return false
	if not data.get("history",null) is Array or data.history.size()>60:return false
	if JSON.stringify(data.history).to_utf8_buffer().size()>24000:return false
	for line in data.history:
		if not line is String or line.length()>1000:return false
	return super.valid(data)
