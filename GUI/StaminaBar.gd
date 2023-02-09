extends ColorRect

#The function does nothing but set the width of the Bar node by calculating it as the maximum width (72 pixels) multiplied by the player’s health percentage
func _on_Player_playerStatsChanged(var player):
	$Bar.rect_size.x = 72 * player.stamina / player.maxStamina
