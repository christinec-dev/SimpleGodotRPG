extends KinematicBody2D

# Player movement speed
export var speed = 75

#Player direction before stopping
var lastDirection = Vector2(0,1) #points player down

#combat
var attackPlaying = false
var attackCooldownTime = 1000
var nextAttackTime = 0
var attackDamage = 30

#combat : fireball
var fireballDamage = 50
var fireballCooldown = 1000
var nextFireballTime = 0
var fireballScene = preload("res://Scenes/Combat/Fireball.tscn")

#Potions
enum Potion {HEALTH, STAMINA}
var healthPotions = 1
var staminaPotions = 1

#player stats
var health = 100
var maxHealth = 100
var healthRegen = 1
var stamina = 100
var maxStamina = 100
var staminaRegen = 2
signal playerStatsChanged

#XP and Levelling
var xp = 8
var xpNextLevel = 100
var level = 1
signal playerLevelUp

func _ready():
	#calls the signal if changes to its vales are made
	emit_signal("playerStatsChanged", self)

func _process(delta):
	#Regenerates stamina
	var newStamina = min(stamina + staminaRegen * delta, maxStamina)
	if newStamina != stamina:
		stamina = newStamina
		emit_signal("playerStatsChanged", self)
	#Regenerates health	
	var newHealth = min(health + healthRegen * delta, maxHealth)
	if newHealth != health:
		health = newHealth
		emit_signal("playerStatsChanged", self)
		
func _physics_process(delta):
	#Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#If input is digital normalize it for diagonal movement
	#This code is used to correct a problem that occurs when we use the keyboard or the D-Pad to move diagonally.
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized() #"Normalizing" means setting a vector's length to 1.
		
	#Apply movement
	var movement = speed * direction * delta
	#decreases speed when attacking
	if attackPlaying:
		movement = 0.3 * movement
	move_and_collide(movement) #returns a KinematicCollision2D object, which contains information about the collision and the colliding body.
	
	#allows us to do combat anims without it being replaced by idle anims
	if not attackPlaying:
		animatesPlayer(direction)
	
	#we need to rotate the ray to point it in the direction the player is facing.	
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 8


func _input(event):
	#combat input
	#this will allows these anims to play before other anims when btns pressed

	if event.is_action_pressed("attack"):
		# Check if player can attack
		var now = OS.get_ticks_msec()
		if now >= nextAttackTime:
			# What's the target?
			var target = $RayCast2D.get_collider()
			if target != null:
				#Skeleton
				if target.name.find("Skeleton") >= 0:
					#Skeleton hit
					target.hit(attackDamage)
			
			#play attack anim
			if stamina >= 25:
				stamina = stamina - 5
				emit_signal("playerStatsChanged", self)
				attackPlaying = true
				var animation = getAnimDirection(lastDirection) + "_attack"
				$AnimatedSprite.play(animation)
				
				# Play attack sound
				$AttackSound.play()
				
				#attack cooldown time
				nextAttackTime = now + attackCooldownTime
				
	elif event.is_action_pressed("fireball"):
		# Check if player can attack
		var now = OS.get_ticks_msec()
		if stamina >= 25 and now >= nextFireballTime:
			stamina = stamina - 5
			emit_signal("playerStatsChanged", self)
			attackPlaying = true
			var animation = getAnimDirection(lastDirection) + "_fireball"
			$AnimatedSprite.play(animation)
			
			# Play fireball sound
			$FireballSound.play()
				
			#fireball cooldown time
			nextFireballTime = now + fireballCooldown
	
	elif event.is_action_pressed("ui_interact"):
		var now = OS.get_ticks_msec()
		if now >= nextAttackTime:
			# What's the target?
			var target = $RayCast2D.get_collider()
			if target != null:
				#NPC
				if target.is_in_group("NPCs"):
					#talk to npc
					target.talk() #found in fionas script
					return
				
				#Sleep
				if target.name == "Bed":
					$AnimationPlayer.play("Sleep")
					yield(get_tree().create_timer(1), "timeout")
					health = maxHealth
					stamina = maxStamina
					emit_signal("playerStatsChanged", self)
					return
			
	#potion drinking input	
	elif event.is_action_pressed("drink_health"):
		if healthPotions > 0:
			healthPotions = healthPotions -1
			health = min(health + 50, maxHealth)
			emit_signal("playerStatsChanged", self)
			# Play sound
			$ObjectSound.play()
	
	elif event.is_action_pressed("drink_stamina"):
		if staminaPotions > 0:
			staminaPotions = staminaPotions - 1
			stamina = min(stamina + 50, maxStamina)
			emit_signal("playerStatsChanged", self)
			# Play sound
			$ObjectSound.play()
			
#movement anims
func animatesPlayer(direction: Vector2):
	#The function animate_player() takes a Vector2 argument that represents the direction of the player movement.
	if direction != Vector2.ZERO:
		#gradually update last_direction to counteract the bounce of the analog stick
		lastDirection = 0.5 * lastDirection + 0.5 * direction
		#choose walk anim based on direction
		
		var animation = getAnimDirection(lastDirection)+ "_walk"
		#Set the FPS of the animation indicated by the first argument. The second argument is the number of FPS
		$AnimatedSprite.frames.set_animation_speed(animation, 2 + 8 * direction.length())
		$AnimatedSprite.play(animation)
	else:
		#play idle animation based on direction
		var animation = getAnimDirection(lastDirection)+ "_idle"
		$AnimatedSprite.play(animation)

#gets anim direction
func getAnimDirection(direction: Vector2):
	# first it normalizes the direction vector to make sure it has length 1 
	var normDirection = direction.normalized()
	
	# then it simply checks the values of the x and y coordinates of the vector to decide in which of these arcs it’s located. Based on that, it returns the animation string prefix.
	if normDirection.y >= 0.707:
		return "down"
	elif normDirection.y <= -0.707:
		return "up"
	elif normDirection.x <= - 0.707:
		return "left"
	elif normDirection.x >= 0.707:
		return "right"
	return "down" #default

#When the fireball animation ends, the function instantiates a new fireball scene, placing it 4 pixels away in front of the player. 
func _on_AnimatedSprite_animation_finished():
	attackPlaying = false #stop combat anims from playing and return to normal movement anims
	if $AnimatedSprite.animation.ends_with("_fireball"):
		#instantiate fireball
		var fireball = fireballScene.instance()
		fireball.attackDamage = fireballDamage
		fireball.direction = lastDirection.normalized()
		fireball.position = position + lastDirection.normalized() * 4
		get_tree().root.get_node("Root").add_child(fireball)
	
#player damage plays hit/game over anims
func hit(damage):
	health -= damage
	emit_signal("playerStatsChanged", self)
	if health <= 0:
		set_process(false)
		$AnimationPlayer.play("Game Over")
		$BackgroundMusic.stop()
		$MusicGameOver.play()
	else:
		$AnimationPlayer.play("Hit")
	
#adds potions to inventory
func addPotion(type):
	if type == Potion.HEALTH:
		healthPotions = healthPotions +1
	else:
		staminaPotions = staminaPotions + 1
	emit_signal("playerStatsChanged", self)
	# Play sound
	$ObjectSound.play()

#add xp when skeleton dies
func addXP(value):
	xp += value
	#has player reahced next level
	if xp >= xpNextLevel:
		level += 1
		xpNextLevel *= 2
		emit_signal("playerLevelUp")
	emit_signal("playerStatsChanged", self)

#save items to be added to save file
func saveToDictionary():
	return {
		"position": [position.x, position.y],
		"health": health,
		"maxHealth": maxHealth,
		"stamina": stamina,
		"maxStamina": maxStamina,
		"xp": xp,
		"xpNextLevel": xpNextLevel,
		"level": level,
		"healthPotions": healthPotions,
		"staminaPotions": staminaPotions
	}

#load game items from save file
func fromDictionary(data):
	position = Vector2(data.position[0], data.position[1])
	health = data.health
	maxHealth = data.maxHealth
	stamina = data.stamina
	maxStamina = data.maxStamina
	xp = data.xp
	xpNextLevel = data.xpNextLevel
	level = data.level
	healthPotions = data.healthPotions
	staminaPotions = data.staminaPotions
	
