extends Control

@export var address = '127.0.0.1'
@export var port = 8910
@export var num_lobby = 4   # number of players in lobby, max of 32

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called on server and clients
func peer_connected(id):
	print("Player Connected: " + str(id))

# Called on server and clients
func peer_disconnected(id):
	print("Player Disconnected: " + str(id))

# Called only from clients
func connected_to_server(id):
	send_player_info.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
	print("Connected to server.")
	
# Called only from clients
func connection_failed(id):
	print("Failed to connect!")

@rpc("any_peer")
func send_player_info(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : name,
			"id": id,
			"score": 0
		}
		
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_info.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, num_lobby)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	send_player_info($LineEdit.text, multiplayer.get_unique_id())
	
	
	print("Waiting for players...")
	pass # Replace with function body.

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.

func _on_start_game_button_down():
	start_game.rpc()
	pass # Replace with function body.
