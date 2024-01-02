extends Control

signal exit

var current_pause : bool = false:
	set = set_paused

func set_paused(value):
	current_pause = value
	get_tree().paused = current_pause
	%Settings.visible = current_pause

# Settings Menu
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		current_pause = !current_pause

func _on_settings_button_pressed():
	print("Settings!")

func _on_resume_button_pressed():
	current_pause = false

func _on_quit_button_pressed():
	get_tree().paused = false
	exit.emit(multiplayer.get_unique_id())
	
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()
	for p in get_tree().get_nodes_in_group("Player"):
		p.queue_free()
	%Settings.hide()
	%Menu.show()

func _on_exit_button_pressed():
	get_tree().quit()
