extends "res://tests/run_b2.gd"
# Supplemental visual harness only; no runtime mutation or progression injection.
func run() -> void:
	base=OS.get_environment("B2_SAVE_DIR")
	await fresh("blast")
	await enter_assessment()
	for i in range(12):
		if scene.hp<6:break
		check("ordinary turn exposes creature approach/cue/strike",scene.end_turn())
		await settle()
		await frames(18)
	check("ordinary creature strike occurred",scene.hp<6 and scene.hp>0)
	await frames(60)
	print("CUE_FINAL ",JSON.stringify(scene.snapshot()))
	quit(0)
