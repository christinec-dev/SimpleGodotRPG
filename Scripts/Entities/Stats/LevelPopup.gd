extends Popup

var player

func _ready():
	player = get_node("/root/Root/Player")
	set_process_input(false)

#lets the player choose what to upgrade
func _on_Player_playerLevelUp():
	set_process_input(true)
	popup_centered()
	get_tree().paused = true
	#play sound
	$LevelUpSound.play()

#if key a, upgrade stamina, if b, upgrade health
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			player.maxHealth += 50
			player.health += 50
			player.emit_signal("playerStatsChanged", player)
			hide()
			set_process_input(false)
			get_tree().paused = false
		elif event.scancode == KEY_B:
			player.maxHStamina += 50
			player.stamina += 50
			player.emit_signal("playerStatsChanged", player)
			hide()
			set_process_input(false)
			get_tree().paused = false
