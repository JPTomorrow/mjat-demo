extends Node3D

class_name Controller

@export var ping_server_btn: Button
@export var console:RichTextLabel

var server_port: int = 8082
var server_address = "127.0.0.1"

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	print("args: ", str(args))
	ping_server_btn.pressed.connect(_ping_server)
	
	if args.has("-s"):
		start_server()
	else:
		start_client()

func console_log(msg: String):
	console.text += msg + "\n"

func start_server() -> void:
	print("starting server")
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_client_disconnected)
	
	# start server
	var server = ENetMultiplayerPeer.new()
	server.create_server(server_port, 500)
	multiplayer.multiplayer_peer = server
	
func start_client() -> void:
	print("joining as client")
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_disconnected_from_server)
	
	# create client
	var client = ENetMultiplayerPeer.new()
	client.create_client(server_address, server_port)
	multiplayer.multiplayer_peer = client
	console_log("started as client -> id: " + str(multiplayer.get_unique_id()))

# only called from client
@rpc("any_peer")
func send_msg_to_server(msg: String, client_id: int):
	if multiplayer.is_server():
		print("message recieved on server -> client_id: ", msg, str(client_id))
		send_msg_to_client.rpc("hey there client! -> server_id: " + str(multiplayer.get_unique_id()))
		
# only callsed from server
@rpc("authority")
func send_msg_to_client(msg: String):
	print("message recieved on client: ", msg)
	console_log(msg)
	
func _on_client_connected(client_id) -> void:
	print("client connected: ", str(client_id))
	
func _on_client_disconnected(client_id) -> void:
	print("client disconnected: ", str(client_id))

func _connected_to_server() -> void:
	print("connected to server")
	
func _disconnected_from_server() -> void:
	print("disconnected from server")
	
# UI
func _ping_server() -> void:
	print("sending message to server...")
	send_msg_to_server.rpc("hello from client: ", multiplayer.get_unique_id())
