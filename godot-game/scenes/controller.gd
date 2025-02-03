extends Node3D

class_name Controller

@export var ping_server_btn: Button
@export var print_mp_id_btn: Button
@export var spawn_btn: Button
@export var console:RichTextLabel
var dronePrefab: PackedScene = preload("res://scenes/drone.tscn")

var internal_server_port = 8082
var external_server_port: int = 31000 # 8082 for dev # 31000 for production!
var server_address = "localhost"

func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	print("args: ", str(args))
	ping_server_btn.pressed.connect(_ping_server)
	print_mp_id_btn.pressed.connect(_print_mp_id)
	spawn_btn.pressed.connect(_spawn_drones)
	
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
	var server = WebSocketMultiplayerPeer.new()
	server.create_server(internal_server_port) # listen internally on 80
	multiplayer.multiplayer_peer = server
	console_log("I am the server -> id: " + str(multiplayer.get_unique_id()))
	
func start_client() -> void:
	print("joining as client")
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_disconnected_from_server)
	# create client
	var client = WebSocketMultiplayerPeer.new()
	var port = external_server_port
	var ws_url = "ws://" + server_address + ":" + str(port)
	client.create_client(ws_url)
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

var ids_to_spawn = []
func _on_client_connected(client_id) -> void:
	print("client connected: ", str(client_id))
	console_log("client connected: " + str(client_id))
	ids_to_spawn.append(client_id)
	

var drone_offset = 2
@rpc("authority", "call_local", "reliable")
func create_drone(client_id):
	# make drone and assign it to new client
	var player: Drone = dronePrefab.instantiate()
	player.name = str(client_id)
	player.set_multiplayer_authority(client_id)
	get_tree().current_scene.add_child(player)
	player.global_position = Vector3(0,5.5,drone_offset)
	drone_offset += 2


func _spawn_drones():
	_spawn_rpc.rpc()
	
@rpc("any_peer", "call_local")
func _spawn_rpc():
	print(str(len(ids_to_spawn)))
	for id in ids_to_spawn:
		create_drone.rpc(id)
	

func _on_client_disconnected(client_id) -> void:
	print("client disconnected: ", str(client_id))

func _connected_to_server() -> void:
	pass
	#print("connected to server")
	
func _disconnected_from_server() -> void:
	print("disconnected from server")
	
# UI
func _ping_server() -> void:
	print("sending message to server...")
	send_msg_to_server.rpc("hello from client: ", multiplayer.get_unique_id())
	
func _print_mp_id():
	var msg = "multiplayer unique id: " + str(multiplayer.get_unique_id())
	print(msg)
	console_log(msg)
