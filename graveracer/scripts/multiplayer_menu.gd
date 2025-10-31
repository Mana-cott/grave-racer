extends Control

@onready var PlayersLabel = $VBoxContainer/Label
@onready var ServerPassword = $VBoxContainer/ServerHBoxContainer/ServerPassword
@onready var ClientPassword = $VBoxContainer/ClientHBoxContainer/ClientPassword
@onready var StartButton = $VBoxContainer/Start
@onready var IPAddress = $VBoxContainer/IPAddress
var connected_players = []

func _ready():
	# Connect network signals
	NetworkHandler.player_connected.connect(_on_player_connected)
	NetworkHandler.player_disconnected.connect(_on_player_disconnected)
	NetworkHandler.server_created.connect(_on_server_created)
	NetworkHandler.client_connected.connect(_on_client_connected)
	NetworkHandler.room_join_success.connect(_on_room_joined)
	NetworkHandler.room_join_failed.connect(_on_room_join_failed)
	NetworkHandler.game_started.connect(_on_game_started)
	
	# Hide start button initially
	StartButton.visible = false

func _on_server_pressed():
	var password = ServerPassword.text.strip_edges()
	if password.length() > 0:
		NetworkHandler.start_server(password)
	else:
		_show_error("Please enter a room password")

func _on_client_pressed():
	var password = ClientPassword.text.strip_edges()
	var ip = IPAddress.text.strip_edges()
	if password.length() > 0:
		if ip.length() == 0:
			ip = "localhost"
		NetworkHandler.start_client(ip, password)
		# Password will be verified when connection is established
	else:
		_show_error("Please enter the room password")

func _on_start_pressed():
	print("Start button pressed")
	if multiplayer.is_server():
		print("Calling start_game as server...")
		NetworkHandler.start_game.rpc()
		NetworkHandler.start_game()
	else:
		print("Only the server can start the game!")

func _on_server_created():
	print("Server created, showing start button")
	StartButton.visible = true
	_update_player_list()

func _on_client_connected():
	print("Client connected!")
	# Password verification will happen automatically when connection is established
	pass

func _on_room_joined():
	_update_player_list()

func _on_room_join_failed(reason: String):
	_show_error(reason)
	# Disconnect from server
	multiplayer.multiplayer_peer = null

func _on_player_connected(id: int):
	if !connected_players.has(id):
		connected_players.append(id)
	_update_player_list()

func _on_player_disconnected(id: int):
	connected_players.erase(id)
	_update_player_list()

func _on_game_started():
	print("[DEBUG] Game started signal received in menu...")
	# Disable all buttons first
	for child in $VBoxContainer.get_children():
		if child is Button:
			child.disabled = true
	# Then queue free after a short delay
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _update_player_list():
	var text = "Connected Players:\\n"
	for player_id in connected_players:
		text += str(player_id)
		if player_id == multiplayer.get_unique_id():
			text += " (You)"
		if multiplayer.is_server() and player_id == 1:
			text += " (Host)"
		text += "\\n"
	PlayersLabel.text = text

func _show_error(message: String):
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.dialog_text = message
	dialog.popup_centered()
	await dialog.confirmed
	dialog.queue_free()
