extends Node

signal server_disconnected
signal player_list(playerDict)
signal loginStatus(statusFlag)
signal keyReceived(status)

var accountName = null
var loggedIn = false
var invitePendingIdx = null
var peer
var crtManager

var incomingInvites = []
var outgoingInvites = []

func _ready():
	multiplayer.connection_failed.connect(_onConnectionFail)
	multiplayer.server_disconnected.connect(_onServerDisconnected)

func connectToServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("localhost", 2244)
	if error:
		print("ERROR: %s" % error)
		return error
	multiplayer.set_multiplayer_peer(peer)

func attemptLogin():
	var keyFile = FileAccess.open("res://privatekey.key", FileAccess.READ)
	if !keyFile: 
		closeSession("noKey")
		return false
	verifyUserCreds.rpc(keyFile.get_buffer(keyFile.get_length()))

@rpc("any_peer")
func notifySuccessfulLogin(username):
	print("SUCCESSFULLY LOGGED IN AS %s" % username)
	accountName = username
	print(accountName)
	print("")
	loggedIn = true
	loginStatus.emit(0, "SUCCESS")
	print(multiplayer.get_unique_id())

@rpc("any_peer")
func closeSession(reason):
	multiplayer.multiplayer_peer = null
	loggedIn = false
	print("MULTIPLAYER SESSION TERMINATED: '%s'" % reason)
	await get_tree().create_timer(1).timeout
	if reason == "nonexistentUser":
		loginStatus.emit(1, "User Does Not Exist.")
	elif reason == "incorrectCreds":
		loginStatus.emit(2, "Incorrect Credentials.")
	elif reason == "noKey":
		loginStatus.emit(3, "No User Key Detected.")
	elif reason == "noUsername":
		loginStatus.emit(3, "You didn't set a username.")
	elif reason == "userExists":
		loginStatus.emit(4, "User already exists")
	else:
		loginStatus.emit(-1, "Unknown Error.")

func _onConnectionFail():
	multiplayer.multiplayer_peer = null

func _onServerDisconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
	print("Server Disconected")

@rpc("any_peer")
func receiveUserCreationStatus(return_value: bool): 
	if return_value == false:
		print("USER ALREADY EXISTS")
		closeSession("userExists")
	else:
		print("CREATED USER SUCCESSFULLY")
		loginStatus.emit(5) 
	
@rpc("any_peer")
func receivePrivateKey(keyString):
	var keyFile = FileAccess.open("res://privatekey.key", FileAccess.WRITE)
	keyFile.store_string(keyString)
	keyFile.close()
	keyReceived.emit(true)

@rpc("any_peer")
func receivePlayerList(dict):
	player_list.emit(dict)

@rpc("any_peer")
func receiveInvite(fromUsername, fromID):
	incomingInvites.append({"id": fromID,"username": fromUsername})
	crtManager.OpenInvite(fromUsername, fromID)

@rpc("any_peer")
func receiveInviteStatus(status):
	crtManager.receiveInviteStatus(status)

# GHOST FUNCTIONS
@rpc("any_peer") func requestUserExistsStatus(username : String): pass
@rpc("any_peer", "reliable") func requestNewUser(username: String) : pass
@rpc("any_peer") func verifyUserCreds(keyFileData): pass
@rpc("any_peer") func requestPlayerList(): pass
@rpc("any_peer") func createInvite(to : int): pass
@rpc("any_peer") func acceptInvite(from): pass
@rpc("any_peer") func denyInvite(from): pass
@rpc("any_peer") func retractInvite(to): pass
@rpc("any_peer") func rectractAllInvites(): pass