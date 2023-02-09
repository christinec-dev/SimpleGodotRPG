extends Popup

onready var player = get_node("/root/Root/Player") #The onready keyword defers initialization of a variable until _ready() is called.
var alreadyPaused
var selectedMenu

func changemenuColor():
	#The first three lines set the menu items to the default color
	$ColorRect/Resume.color = Color.gray
	$ColorRect/SaveGame .color = Color.gray
	$ColorRect/MainMenu.color = Color.gray
	# Then, the match statement is used to check which item is highlighted to change its color.
	match selectedMenu:
		0:
			$ColorRect/Resume.color = Color.greenyellow
		1:
			$ColorRect/SaveGame .color = Color.greenyellow
		2:
			$ColorRect/MainMenu.color = Color.greenyellow

func _input(event):
	#: if the player presses the menu button, we want to pause the game and show the menu.
	if not visible:
		if Input.is_action_just_pressed("menu"):
			# If player is dead, go to start screen
			if player.health <= 0:
				get_node("/root/Root").queue_free()
				get_tree().change_scene("res://Scenes/StartScreen.tscn")
				get_tree().paused = false
				return
			#pause game
			get_tree().paused = true
			#reset popup
			selectedMenu = 0
			changemenuColor()
			#showpopup
			player.set_process_input(false)
			popup()
	else:
		#we want to navigate the menu with the up and down arrow keys and select the highlighted item with the enter key
		if Input.is_action_just_pressed("ui_down"):
			selectedMenu = (selectedMenu + 1) % 3;
			changemenuColor()
		elif Input.is_action_just_pressed("ui_up"):
			if selectedMenu > 0:
				selectedMenu = selectedMenu - 1
			else:
				selectedMenu = 2
			changemenuColor()
		elif Input.is_action_just_pressed("ui_accept"):
			match selectedMenu:
				0:
					#resume game
					if not alreadyPaused:
						get_tree().paused = false
					player.set_process_input(true)
					hide()
				1:
					#save game 
					get_node("/root/Root").save()
					get_tree().paused = false
					hide()
				2:
					#main menu
					get_node("/root/Root").queue_free()
					get_tree().change_scene("res://Scenes/StartScreen.tscn")
					get_tree().paused = false
	
