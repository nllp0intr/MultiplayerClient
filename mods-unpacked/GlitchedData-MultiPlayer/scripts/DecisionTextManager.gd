extends Node

const InteractionManager = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/InteractionManager.gd")
const TextInteraction = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/TextInteraction.gd")

@export var inter : InteractionManager
@export var array_obj : Array[Node3D]
@export var textArray : Array[TextInteraction]
@export var colliderArray : Array[StaticBody3D]
@export var animator : AnimationPlayer
@export var uiParent : Control

func _ready():
	if (GlobalVariables.using_gl): for i in array_obj: i.visible = false
	for i in range(colliderArray.size()):
		colliderArray[i].collision_layer = 0
		colliderArray[i].collision_mask = 0

func SetUI(state : bool):
	if (state):
		for i in range(colliderArray.size()):
			colliderArray[i].collision_layer = 1
			colliderArray[i].collision_mask = 1
		animator.play("show text")
		if (GlobalVariables.using_gl): for i in array_obj: i.visible = true
		inter.fs_dec = false
	else:
		for i in range(colliderArray.size()):
			colliderArray[i].collision_layer = 0
			colliderArray[i].collision_mask = 0
		animator.play("hide text")
		uiParent.visible = false
		if (GlobalVariables.using_gl): for i in array_obj: i.visible = false
		inter.fs_dec = false