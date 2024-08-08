extends Control


@onready var namelabel = $NameLabel
@onready var number_label = $NumberLabel



func create_player(pnum: String, pname: String):
	$NumberLabel.text = pnum
	$NameLabel.text = pname
