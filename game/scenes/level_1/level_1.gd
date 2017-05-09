extends Node2D

signal player_restart
signal set_player_restart_pos(restart_pos)

func _ready():
	emit_signal("set_player_restart_pos", get_node("player_start").get_pos())
	emit_signal("player_restart")
