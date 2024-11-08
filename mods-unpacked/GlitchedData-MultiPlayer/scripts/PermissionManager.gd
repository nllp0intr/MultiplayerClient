extends Node

const DescriptionManager = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/DescriptionManager.gd")
const InteractionBranch = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/InteractionBranch.gd")
const ItemInteraction = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/ItemInteraction.gd")
const ItemManager = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/ItemManager.gd")
const PickupIndicator = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/PickupIndicator.gd")
const RoundManager = preload("res://mods-unpacked/GlitchedData-MultiPlayer/scripts/RoundManager.gd")

@export var roundManager : RoundManager
@export var itemManager : ItemManager
@export var indicatorArray : Array[PickupIndicator]
@export var interactionBranchArray : Array[InteractionBranch]
@export var description : DescriptionManager
@export var userItemsParent : Node3D
@export var stackDisabledItemArray : Array[String]
@export var stackDisabledItemArray_bools : Array[bool]

func _ready():
	#SetItemInteraction(true)
	pass

func SetIndicators(state : bool):
	if (state):
		for i in range(indicatorArray.size()):
			indicatorArray[i].interactionAllowed = true
	if (!state):
		for i in range(indicatorArray.size()):
			indicatorArray[i].interactionAllowed = false
			indicatorArray[i].moving = false

func DisableShotgun():
	for i in range (interactionBranchArray.size()):
		if (interactionBranchArray[i].interactionAlias == "shotgun"):
			interactionBranchArray[i].interactionAllowed = false
			break
	for i in range (indicatorArray.size()):
		if (indicatorArray[i].itemName == "SHOTGUN"):
			indicatorArray[i].interactionAllowed = false
			break
			

func SetInteractionPermissions(state : bool):
	if (state):
		for i in range(interactionBranchArray.size()):
			interactionBranchArray[i].interactionAllowed = true
	if (!state):
		for i in range(interactionBranchArray.size()):
			interactionBranchArray[i].interactionAllowed = false
	if (roundManager.roundArray[roundManager.currentRound].usingItems && itemManager.items_dynamicIndicatorArray.size() != 0):
		if (state):
			for i in range(itemManager.items_dynamicInteractionArray.size()):
				itemManager.items_dynamicInteractionArray[i].interactionAllowed = true
				itemManager.items_dynamicIndicatorArray[i].interactionAllowed = true
		else:
			for i in range(itemManager.items_dynamicInteractionArray.size()):
				itemManager.items_dynamicInteractionArray[i].interactionAllowed = false
				itemManager.items_dynamicIndicatorArray[i].interactionAllowed = false

func SetItemInteraction(state : bool):
	var children = userItemsParent.get_children()
	for i in range(children.size()):
		if (children[i].get_child(0) != null):
			if (children[i].get_child(0) is PickupIndicator):
				var tempindicator : PickupIndicator = children[i].get_child(0)
				tempindicator.interactionAllowed = state
			if (children[i].get_child(1) is InteractionBranch):
				var tempBranch : InteractionBranch = children[i].get_child(1)
				tempBranch.interactionAllowed = state

@export var inter : ItemInteraction
func SetStackInvalidIndicators():
	if (inter.stealing): stackDisabledItemArray_bools[5] = true
	else: stackDisabledItemArray_bools[5] = false
	if (roundManager.dealerCuffed): stackDisabledItemArray_bools[4] = true
	else: stackDisabledItemArray_bools[4] = false
	if (roundManager.barrelSawedOff): stackDisabledItemArray_bools[0] = true
	else: stackDisabledItemArray_bools[0] = false
	if (roundManager.roundArray[roundManager.currentRound].usingItems && itemManager.items_dynamicIndicatorArray.size() != 0):
		for i in range(stackDisabledItemArray.size()):
			for c in range(itemManager.items_dynamicInteractionArray.size()):
				if (itemManager.items_dynamicInteractionArray[c].itemName == stackDisabledItemArray[i] && stackDisabledItemArray_bools[i]):
					itemManager.items_dynamicInteractionArray[c].interactionInvalid = true
					itemManager.items_dynamicIndicatorArray[c].interactionInvalid = true
				if (itemManager.items_dynamicInteractionArray[c].itemName == stackDisabledItemArray[i] && !stackDisabledItemArray_bools[i]):
					itemManager.items_dynamicInteractionArray[c].interactionInvalid = false
					itemManager.items_dynamicIndicatorArray[c].interactionInvalid = false

func RevertDescriptionUI():
	description.EndLerp()