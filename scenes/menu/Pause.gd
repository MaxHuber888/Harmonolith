extends Control

signal exit

var current_pause : bool = false:
	set = set_paused

func set_paused(value):
	current_pause = value
	get_tree().paused = current_pause
	%PauseMenu.visible = current_pause

# Settings Menu
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") && %MapInstance.get_child_count() > 0:
		current_pause = !current_pause

func _on_settings_button_pressed():
	print("Settings!")

func _on_resume_button_pressed():
	current_pause = false

func _on_quit_button_pressed():
	get_tree().paused = false
	
	for p in %PlayerSpawn.get_children():
		p.queue_free()
	for m in %MapInstance.get_children():
		m.queue_free()
	exit.emit(multiplayer.get_unique_id())	
	
	%PauseMenu.hide()
	%MainMenu.show()

func _on_exit_button_pressed():
	get_tree().quit()
