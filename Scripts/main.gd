extends Control

var ip:String = "127.0.0.1"
var port:int = 28960
var maxClients:int = 2

func _ready():
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	print("started")


func _client_connected(_id):
	print("Clent connected successfully")


func _client_disconnected(_id):
	print("Client disconnected")


func _connected_fail(_id):
	print("Connection failed")


# if the host startup was selected
func _on_HostSelect_pressed():
	$Init.hide()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, maxClients)
	get_tree().set_network_peer(peer)
	print("Set up as host")
	get_node("Host").hostShowScreen()


# if the client startup was selected
func _on_ClientSelect_pressed():
	$Init.hide()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	print("Set up as client")
	get_node("Client").clientShowScreen()






