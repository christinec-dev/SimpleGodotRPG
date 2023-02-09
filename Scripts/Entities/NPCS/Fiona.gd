extends StaticBody2D

enum QuestStatus { NOT_STARTED, STARTED, COMPLETED }
var questStatus = QuestStatus.NOT_STARTED
var dialogState = 0
var necklaceFound = false

#ref vars
var dialogPopup
var player
enum Potion { HEALTH, STAMINA }

func _ready():
	dialogPopup = get_tree().root.get_node("Root/UI/DialoguePopup")
	player = get_tree().root.get_node("Root/Player")

#play anim
#implements dialog state
#show current line of dialog
#rewards quest completed
func talk(answer = ""):
	#set anim to talk
	$AnimatedSprite.play("talk")
	
	#set dialogpopup
	dialogPopup.npc = self
	dialogPopup.npcName = "Fiona"
	
	#show current dialog
	match questStatus:
		QuestStatus.NOT_STARTED:
			match dialogState:
				0:
					#update dialog tree
					dialogState = 1
					dialogPopup.dialog = "Hello adventurer! I lost my necklace, can you find it for me?"
					
					dialogPopup.answers = "[A] Yes  [B] No"
					dialogPopup.open()
				1:
					match answer:
						"A":
							# Update dialogue tree state
							dialogState = 2
							# Show dialogue popup
							dialogPopup.dialog = "Thank you!"
							dialogPopup.answers = "[A] Bye"
							dialogPopup.open()
						"B":
							# Update dialogue tree state
							dialogState = 3
							# Show dialogue popup
							dialogPopup.dialog = "If you change your mind, you'll find me here."
							dialogPopup.answers = "[A] Bye"
							dialogPopup.open()
				2:
					# Update dialogue tree state
					dialogState = 0
					questStatus = QuestStatus.STARTED
					# Close dialogue popup
					dialogPopup.close()
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
				3:
					# Update dialogue tree state
					dialogState = 0
					# Close dialogue popup
					dialogPopup.close()
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")	
		
		QuestStatus.STARTED:
			match dialogState:
				0:
					# Update dialogue tree state
					dialogState = 1
					# Show dialogue popup
					dialogPopup.dialog = "Did you find my necklace?"
					if necklaceFound:
						dialogPopup.answers = "[A] Yes  [B] No"
					else:
						dialogPopup.answers = "[A] No"
					dialogPopup.open()
				1:
					if necklaceFound and answer == "A":
						# Update dialogue tree state
						dialogState = 2
						# Show dialogue popup
						dialogPopup.dialog = "You're my hero! Please take this potion as a sign of my gratitude!"
						dialogPopup.answers = "[A] Thanks"
						dialogPopup.open()
					else:
						# Update dialogue tree state
						dialogState = 3
						# Show dialogue popup
						dialogPopup.dialog = "Please, find it!"
						dialogPopup.answers = "[A] I will!"
						dialogPopup.open()
				2:
					# Update dialogue tree state
					dialogState = 0
					questStatus = QuestStatus.COMPLETED
					# Close dialogue popup
					dialogPopup.close()
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
					# Add potion and XP to the player. 
					yield(get_tree().create_timer(0.5), "timeout") #I added a little delay in case the level advancement panel appears.
					player.addPotion(Potion.HEALTH)
					player.addXP(50)  
				3:
					# Update dialogue tree state
					dialogState = 0
					# Close dialogue popup
					dialogPopup.close()
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
		
		QuestStatus.COMPLETED:
			match dialogState:
				0:
					# Update dialogue tree state
					dialogState = 1
					# Show dialogue popup
					dialogPopup.dialog = "Thanks again for your help!"
					dialogPopup.answers = "[A] Bye"
					dialogPopup.open()
				1:
					# Update dialogue tree state
					dialogState = 0
					# Close dialogue popup
					dialogPopup.close()
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")

#save items to be added to save file
func saveToDictionary():
	return {
		"questStatus": questStatus,
		"necklaceFound": necklaceFound
	}
	
#load game items from save file
func fromDictionary(data):
	questStatus = int(data.questStatus)
	necklaceFound = data.necklaceFound
