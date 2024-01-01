extends Node

@export var Player : PackedScene

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(id, player_info)
signal player_disconnected(id)
signal server_disconnected

const PORT = 9999
const MAX_CLIENTS = 4

var default_address = "127.0.0.1"

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"name" : "Name"
	}

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
# Called on server and client
func _on_peer_connected(id):
	print("Player connected: " + str(id))
	register_player.rpc_id(id, player_info)
	load_game.rpc("res://maps/lobby.tscn")
	add_player.rpc(id)

# Called on server and client
func _on_peer_disconnected(id):
	print("Player disconnected: " + str(id))
	remove_player.rpc(id)
	players.erase(id)
	player_disconnected.emit(id)

# Called on client only
func _on_connected_to_server():
	print("Connected to server.")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

# Called on client only
func _on_connection_failed():
	print("Couldn't connect!")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Server disconnected!")
	multiplayer.multiplayer_peer = null

# Server
func create_game(is_online):
	if is_online:
		upnp_setup()
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)
	if error:
		print("Couldn't create host!")
		return error
	
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)

#  Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func join_game(address):
	if address == "":
		address = default_address
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print("Couldn't create client!")
		return error
	print("Joining Server IP: " + address)
	multiplayer.multiplayer_peer = peer

# Set up port mapping for online multiplayer functionality
func upnp_setup():
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(PORT)
	var ip_address = upnp.query_external_address()
	print("Server IP: " + ip_address)
	%DisplayPublicIP.text = "Server IP: " + ip_address

# Game Methods
func _on_solo_button_pressed():
	load_game.rpc("res://maps/test_map.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_host_button_pressed():
	create_game(true)
	load_game.rpc("res://maps/lobby.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_local_host_pressed():
	create_game(false)
	load_game.rpc("res://maps/lobby.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_join_button_pressed():
	join_game(%IPAddress.text)

# Game loading
# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(map_scene_path):
	%Menu.hide()
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()
	var map = load(map_scene_path).instantiate()
	%MapInstance.add_child(map)

@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
@rpc("call_local", "reliable")
func add_player(id):
	var player_instance = Player.instantiate()
	player_instance.name = str(id)
	%PlayerSpawn.add_child(player_instance)

@rpc("any_peer", "call_local", "reliable")
func remove_player(id):
	if %PlayerSpawn.get_node(str(id)):
		%PlayerSpawn.get_node(str(id)).queue_free()
