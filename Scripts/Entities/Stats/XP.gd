extends ColorRect

func _on_Player_playerStatsChanged(var player):
	#This function simply takes the values from the player and inserts them into the GUI Labels.
	$ValueXP.text = str(player.xp) + "/" + str(player.xpNextLevel)
	$ValueLVL.text = str(player.level)
