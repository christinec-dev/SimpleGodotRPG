extends ColorRect

func _on_Player_playerStatsChanged(var player):
	#This function simply takes the values from the player and inserts them into the GUI Labels.
	$LabelSAmount.text = str(player.staminaPotions)
