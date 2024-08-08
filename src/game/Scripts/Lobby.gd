extends Control

@onready var player_list = $PlayerList
const PLAYER_CONTAINER = preload("res://Scenes/UI/player_container.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func createLobby(code: String):
	get_node("RoomCode").text = code

func addPlayer(pname: String, pnum: int):
	var new_player = PLAYER_CONTAINER.instantiate()
	new_player.create_player(str(pnum), pname)
	if player_list.get_node("HBox1").get_children().size() < 5:
		player_list.get_node("HBox1").add_child(new_player)
	else:
		player_list.get_node("HBox2").add_child(new_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
