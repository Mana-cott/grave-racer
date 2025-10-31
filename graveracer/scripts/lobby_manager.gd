# LobbyManager.gd (Server-side)
extends Node

const PORT = 42069
var peer = ENetMultiplayerPeer.new()

var rooms = {} # Stores all active rooms { "password": { "players": [], "map": null } }
var current_player_count = 0
const MAX_PLAYERS = 4

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_server():
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(peer_id):
	print("New peer connected with ID: ", peer_id)
	# The server welcomes the new client.
	# The client must now send a request to join or create a room.

func _on_peer_disconnected(peer_id):
	print("Peer disconnected with ID: ", peer_id)
	# Handle players leaving rooms or the lobby.
	for room_id in rooms:
		if peer_id in rooms[room_id]["players"]:
			rooms[room_id]["players"].erase(peer_id)
			# If the room is empty, remove it.
			if rooms[room_id]["players"].size() == 0:
				rooms.erase(room_id)
			break

@rpc("any_peer")
func create_room(password: String, map_path: String):
	# Server-side logic for creating a room
	var peer_id = multiplayer.get_rpc_sender_id()
	if password in rooms:
		# Send an RPC back to the client telling them the room already exists
		rpc_id(peer_id, "room_creation_failed", "Room with this password already exists.")
		return

	rooms[password] = {
		"players": [peer_id],
		"map": map_path
	}
	rpc_id(peer_id, "room_created", password)
	
	# Check if we can start the game
	_check_start_game(password)

@rpc("any_peer")
func join_room(password: String):
	# Server-side logic for joining a room
	var peer_id = multiplayer.get_rpc_sender_id()
	if password not in rooms:
		rpc_id(peer_id, "room_join_failed", "Room does not exist.")
		return
	if rooms[password]["players"].size() >= MAX_PLAYERS:
		rpc_id(peer_id, "room_join_failed", "Room is full.")
		return

	rooms[password]["players"].append(peer_id)
	rpc_id(peer_id, "room_joined", password)
	
	# Notify all players in the room that a new player has joined
	for p_id in rooms[password]["players"]:
		if p_id != peer_id:
			rpc_id(p_id, "player_joined_room", peer_id)

	# Check if we can start the game
	_check_start_game(password)

func _check_start_game(password):
	if rooms[password]["players"].size() == MAX_PLAYERS:
		# Start the game for this room
		_start_game_for_room(password)

func _start_game_for_room(password):
	var room_data = rooms[password]
	var player_ids = room_data["players"]
	
	# Tell all clients in the room to load the game scene
	for p_id in player_ids:
		rpc_id(p_id, "load_game_scene", room_data["map"])
	
	# The server loads the game scene as well
	var game_scene = load(room_data["map"]).instantiate()
	get_tree().root.add_child(game_scene)
	
	# Spawn players on the server
	var spawner = game_scene.get_node("MultiplayerSpawner")
	for i in player_ids.size():
		var player = load("res://path/to/player.tscn").instantiate()
		player.name = str(player_ids[i])
		spawner.add_child(player, true)
		
	# Delete the room from the lobby manager
	rooms.erase(password)
