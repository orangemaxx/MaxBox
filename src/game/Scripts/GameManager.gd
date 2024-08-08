class_name GameManager extends Node

var client = SocketIOClient
var backendURL: String
var roomCode: String
var lobby_res = preload("res://Scenes/UI/Lobby.tscn")

var lobby

var players = {}
var playernum = 0
var maxplayers: int

func _ready():
	# prepare URL
	backendURL = "http://127.0.0.1:8000/socket.io"


	# initialize client
	client = SocketIOClient.new(backendURL, {"host": true, "game": "ydkj"})

	# this signal is emitted when the socket is ready to connect
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)

	# add client to tree to start websocket
	add_child(client)

func _exit_tree():
	# optional: disconnect from socketio server
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	# connect to socketio server when engine.io connection is ready
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend!")
	else:
		print("Socket connected")

func on_socket_event(event_name: String, payload: Variant, _name_space):
	print("Received ", event_name, " ", payload)
	match event_name:
		"lobbyStart":
			var lobby_scene = lobby_res.instantiate()
			add_child(lobby_scene)
			roomCode = payload['room']
			maxplayers = payload['maxplayers']
			lobby = $Lobby
			lobby.createLobby(roomCode)
		"playerJoin":
			_playerJoin(payload)

func _playerJoin(payload):
	var pname = payload['name']
	if playernum >= maxplayers:
		client.socketio_send("disconnectPlayer", {"name": pname, "reason": "Max Players Has Been Reached"})
	else:
		print("Player Joined")
		if pname in players:
			players[pname] = {"score": 0}
		else:
			playernum += 1
			lobby.addPlayer(pname, playernum)
			players[pname] = {"score": 0}
			print(players)

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
