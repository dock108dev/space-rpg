extends "res://scripts/tactical_save.gd"
# Independent S04 schema; S03 snapshots remain untouched and are not migrated.
func valid(data:Variant) -> bool:
	if not data is Dictionary:return false
	if not super.valid(data):return false
	for key in ["loop_version","journey","package","learned","cache","kits","reward"]:
		if not data.has(key):return false
	if data.loop_version!=1 or data.journey not in ["package","encounter","shelter","reward","complete"]:return false
	for key in ["package","learned","cache"]:
		if not data[key] is bool:return false
	if not (data.kits is int or data.kits is float) or not is_finite(float(data.kits)) or data.kits!=floor(data.kits) or data.kits<0 or data.kits>3:return false
	if data.reward not in ["","security","equipment","opportunity"]:return false
	if data.package!=data.learned:return false
	if data.journey!="package" and not data.package:return false
	if data.cache and not data.learned:return false
	if data.kits>(1 if data.cache else 0)+(2 if data.reward=="security" else 0):return false
	if (data.journey=="complete")!=(data.reward!=""):return false
	if data.journey in ["shelter","reward","complete"]:
		if data.enemy_hp!=0 or data.phase!="success":return false
	elif data.phase!="player" or data.enemy_hp<=0:return false
	if data.journey=="package" and (data.enemy_hp!=6 or data.cache or data.hp!=6):return false
	return super.valid(data)
