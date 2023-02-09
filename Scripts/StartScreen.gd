extends Node2D

var selectedMenu = 0
	
func changeMenuColor():
	$NewGame.color = Color.gray
	$LoadGame.color = Color.gray
	$Quit.color = Color.gray
	
	match selectedMenu:
		0:
			$NewGame.color = Color.greenyellow
		1:
			$LoadGame.color = Color.greenyellow
		2:
			$Quit.color = Color.greenyellow
			
func _ready():
	changeMenuColor()
	
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		selectedMenu = (selectedMenu + 1)  % 3
		changeMenuColor()
	elif Input.is_action_just_pressed("ui_up"):
		if selectedMenu > 0:
			selectedMenu = selectedMenu - 1
		else:
			selectedMenu = 2
		changeMenuColor()
	elif Input.is_action_just_pressed("ui_accept"):
		match selectedMenu:
			0:
				#new game
				get_tree().change_scene("res://Scenes/Main.tscn")
			1:
				#load game
				var nextLevelResource = load("res://Scenes/Main.tscn")
				#we use the load() statement to load the scene in memory as a PackedScene resource.
				#The scene is now in memory, but it’s not yet a node. To create the actual node, we must call the instance() function of PackedScene.
				#we add the newly created node to the current scene
				#, we tell Godot to remove the start menu from the node tree by calling the queue_free() function.
				var nextLevel = nextLevelResource.instance()
				nextLevel.loadSavedGame = true
				get_tree().root.call_deferred("add_child", nextLevel)
				queue_free()
			2:
				#quit
				get_tree().quit()
			
