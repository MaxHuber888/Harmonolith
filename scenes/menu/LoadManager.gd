extends Node

signal progress_changed(progress)
signal load_done
signal process_done
signal loading_screen_has_full_coverage

var _load_screen_path : String = "res://scenes/menu/loading_screen.tscn"
var _load_screen = load(_load_screen_path)
var _loaded_resource: PackedScene
var _scene_path: String
var _progress: Array = []

# USE THIS TO CHANGE LEVELS WITH LOADING SCREEN
# (the second line is necessary to ensure that no part 
# of the process happens before the loading screen appears)
#LoadManager.load_scene("res://scenes/levels/lobby.tscn")
#await Signal(LoadManager, "loading_screen_has_full_coverage")


# USE THIS TO START A LOADING SCREEN DURING SOME PROCESS
#LoadManager.load_process("TEXT TO DISPLAY ON LOADING SCREEN")

# AND THEN WHEN THE PROCESS ENDS
#LoadManager.finish_process()

var use_sub_threads : bool = true

# This can be called to show a loading screen while any process is running
func load_process(descriptor: String) -> void:
	#No resource to load so set _scene_path to "process"
	_scene_path = "process"
	var new_loading_screen = _load_screen.instantiate()
	new_loading_screen.set_descriptor(descriptor)
	get_tree().get_root().add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._start_outro_animation)
	
	# Must at least wait for intro animation to complete
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	emit_signal("loading_screen_has_full_coverage")
	
func finish_process():
	emit_signal("progress_changed", 1.0)
	emit_signal("load_done")

func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._start_outro_animation)
	
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	
	start_load()
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	
func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2:
			# LOAD FAILED
			set_process(false)
			return
		1:
			# LOAD THREAD IN PROGRESS
			emit_signal("progress_changed", _progress[0])
		3:
			# LOAD COMPLETE
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			emit_signal("progress_changed", 1.0)
			emit_signal("load_done")
			get_tree().change_scene_to_packed(_loaded_resource)
