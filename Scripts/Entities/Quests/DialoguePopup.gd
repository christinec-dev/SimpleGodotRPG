extends Popup

var npcName setget nameSet
var dialog setget dialogSet
var answers setget answersSet
var npc 

#sets dialog values
func nameSet(new_value):
	npcName = new_value
	$ColorRect/NPCName.text = new_value
	
func dialogSet(new_value):
	dialog = new_value
	$ColorRect/Dialog.text = new_value

func answersSet(new_value):
	answers = new_value
	$ColorRect/Answers.text = new_value

#opens the dialogue popup:
func open():
	get_tree().paused = true
	popup()	
	$AnimationPlayer.playback_speed = 60.0 / dialog.length()
	$AnimationPlayer.play("ShowDialog")

#close the dialogue popup:
func close():
	get_tree().paused = false
	hide()

#In its default state (hidden), this panel should not receive input.
func _ready():
	set_process_input(false)

#We want to enable input only when the ShowDialogue animation is finished.
func _on_AnimationPlayer_animation_finished(anim_name):
	set_process_input(true)

#This function checks that the detected input is a keyboard event (InputEventKey). If one of the valid keys (A or B) is pressed, the input is disabled and the player’s choice is sent to the NPC via the talk() function (which we will write in the next section).
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			set_process_input(false)
			npc.talk("A")
		elif event.scancode == KEY_B:
			set_process_input(false)
			npc.talk("B")	
		
