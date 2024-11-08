extends Node

const SaveFileManager = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/SaveFileManager.gd")

@export var save : SaveFileManager
var fs = false
var reset_pressed = false
var reset_timer = 0.0

func _unhandled_input(event):
	if event.is_action_pressed("reset") && !fs:
		reset_timer = 0
		reset_pressed = true
	if (event.is_action_released("reset")):
		reset_timer = 0
		reset_pressed = false

func _process(delta):
	if reset_pressed:
		reset_timer += delta
		if reset_timer >= 0.8:
			reset_pressed = false
			Reset()
			reset_timer = 0.0
	else:
		reset_timer = 0.0

func Reset(hard = true):
	var multiplayerManager = get_node("/root/MultiplayerManager")
	if hard:
		multiplayer.multiplayer_peer = null
		multiplayerManager.loggedIn = false
		multiplayerManager.savedInvite = ""
	multiplayerManager.inMatch = false
	save.ClearSave()
	print("changing scene to: death")
	get_tree().change_scene_to_file("res://scenes/death.tscn")
	fs = true
