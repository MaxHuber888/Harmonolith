extends Node

@export var Player : PackedScene
@export var Lobby : PackedScene
@export var TestMap : PackedScene

const PORT = 9999
const MAX_CLIENTS = 4
var address = "127.0.0.1"

const RAND_SPAWN = 250

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
	load_game.rpc("res://scenes/lobby.tscn")
	add_player.rpc(id)

# Called on server and client
func _on_peer_disconnected(id):
	print("Player disconnected: " + str(id))
	remove_player.rpc(id)
	
	# If host disconnects, disconnect server
	if id == 1:
		multiplayer.server_disconnected.emit()
	
# Called on client only
func _on_connected_to_server():
	print("Connected to server.")
	var peer_id = multiplayer.get_unique_id()

# Called on client only
func _on_connection_failed():
	print("Couldn't connect!")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Server disconnected!")
	for p in %PlayerSpawn.get_children():
		remove_player.rpc(p.name)
	for m in %MapInstance.get_children():
		m.queue_free()
	multiplayer.multiplayer_peer.close()

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

# Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func join_game(address_to_join):
	if address_to_join == "":
		address_to_join = address
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address_to_join, PORT)
	if error:
		print("Couldn't create client!")
		return error
	print("Joining Server IP: " + address_to_join)
	multiplayer.multiplayer_peer = peer

# Set up port mapping for online multiplayer functionality
func upnp_setup():
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(PORT)
	address = upnp.query_external_address()
	print("Server IP: " + address)


# Game loading
@rpc("call_local", "reliable")
func load_game(scene):
	%MainMenu.hide()
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()
	var map = load(scene).instantiate()
	%MapInstance.add_child(map)
	
@rpc("call_local", "reliable")
func add_player(id):
	var player_instance = Player.instantiate()
	player_instance.name = str(id)
	%PlayerSpawn.add_child(player_instance)
	
	var pos := Vector2.from_angle(randf()*2*PI)
	player_instance.position = Vector2(pos.x * RAND_SPAWN * randf(), pos.y * RAND_SPAWN * randf())


@rpc("any_peer", "call_local", "reliable")
func remove_player(id):
	if not %PlayerSpawn.has_node(str(id)):
		return
	%PlayerSpawn.get_node(str(id)).queue_free()


# Game Methods
func _on_solo_button_pressed():
	load_game.rpc("res://scenes/test_map.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_host_button_pressed():
	create_game(true)
	load_game.rpc("res://scenes/lobby.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_local_host_pressed():
	create_game(false)
	load_game.rpc("res://scenes/lobby.tscn")
	add_player.rpc(multiplayer.get_unique_id())

func _on_join_button_pressed():
	join_game(%IPAddress.text)

func _on_settings_button_pressed():
	print("Settings")
