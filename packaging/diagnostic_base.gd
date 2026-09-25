extends Node
var root:Window:
	get:return get_tree().root
var paused:bool:
	get:return get_tree().paused
	set(value):get_tree().paused=value
func quit(code:int=0) -> void:get_tree().quit(code)
func get_root() -> Window:return get_tree().root
