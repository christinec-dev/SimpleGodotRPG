extends KinematicBody2D

var player
var rng = RandomNumberGenerator.new()

#movement vars
export var speed = 25
var direction : Vector2
var lastDirection = Vector2(0, 1)
var bounceCountdown = 0 #when the skeleton hits an obstacle, it changes direction for a certain amount of time to try to go around it. 
var otherAnimsPlaying = false

#stats
var health = 100
var maxHealth = 100
var healthRegen = 1
signal death

#combat
var attackCooldownTime = 1500
var nextAttackTime = 0
var attackDamage = 10

#potion scene
var potionScene = preload("res://Scenes/Combat/Potions.tscn")

func _process(delta):
	# Regenerates health
	health = min(health + healthRegen * delta, maxHealth)
	
	var now = OS.get_ticks_msec()
	if now >= nextAttackTime:
		# What's the target?
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			#attack anim
			otherAnimsPlaying = true
			var animation = getAnimDirection(lastDirection) + "_attack"
			$AnimatedSprite.play(animation)
			#cooldown
			nextAttackTime = now + attackCooldownTime

func _ready():
	player = get_tree().root.get_node("Root/Player")  # from Main.tscn -> Root/Player
	rng.randomize() #RandomNumberGenerator use a time-based seed to initialize the random number generator.

func _physics_process(delta):
	# move the skeleton
	var movement = direction * speed * delta
	var collision = move_and_collide(movement)
	
	if collision != null and collision.collider.name != "Player":
		#the current direction of movement is rotated by a randomly generated angle
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		#an integer number between 2 and 5 is generated randomly (using the randi_range()) function, to be used as a countdown for the “bounce” on the obstacle.
		bounceCountdown = rng.randi_range(2, 5)
	
	#to play walk and idle animations:
	if not otherAnimsPlaying:
		animatesSkeleton(direction)
	
	#cast in which direction skeleton faces	
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() *16
		
func _on_Timer_timeout():
	#calc the position of the player relative to skeleton
	var playerRelativePosition = player.position - position
	
	if playerRelativePosition.length() <= 16:
		# If player is near, don't move but turn toward it
		direction = Vector2.ZERO
		lastDirection = playerRelativePosition.normalized()
	elif playerRelativePosition.length() <= 100 and bounceCountdown == 0:
		# If player is within range, move toward it
		direction = playerRelativePosition.normalized()
	elif bounceCountdown == 0:
		# If player is too far, randomly decide whether to stand still or where to move
		var randomNumber = rng.randf()
		if randomNumber < 0.05:
			direction = Vector2.ZERO
		elif randomNumber < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			
		# Update bounce countdown
		if bounceCountdown > 0:
			bounceCountdown = bounceCountdown - 1
			
#movement anims
func animatesSkeleton(direction: Vector2):
	#The function animate_player() takes a Vector2 argument that represents the direction of the player movement.
	if direction != Vector2.ZERO:
		#gradually update last_direction to counteract the bounce of the analog stick
		lastDirection = direction
		#choose walk anim based on direction
		var animation = getAnimDirection(lastDirection)+ "_walk"
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
	
#spawn birth anim
func arise():
	otherAnimsPlaying = true
	$AnimatedSprite.play("birth")

func _on_AnimatedSprite_animation_finished():
	#start the timer to enable Artificial Intelligence
	#set to false the other_animation_playing variable to allow walk and idle animations to play.
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death":
		#
		get_tree().queue_delete(self)
	otherAnimsPlaying = false

#adds damage to enemy	
func hit(damage):
	health -= damage
	if health > 0:
		#show damage indicator
		$AnimationPlayer.play("Hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false) #function is used to enable/disable the _process() function call at each frame. We disable it, to prevent the regeneration of skeleton’s health.
		otherAnimsPlaying = true
		$AnimatedSprite.play("death")
		emit_signal("death")
		
		# Play death sound
		$DeathSound.play()	
		
		#add xp to player
		player.addXP(25)
		
		#add 80% chance of them dropping potion loot
		if rng.randf() <= 0.8:
			var potion = potionScene.instance()
			#Then, an integer random number is generated using the randi() function. With a modulo (%) 2 operation, you get the reminder of the division by 2 of this number. Since the rest can only be 0 or 1, one of the two types of potion is randomly chosen (0 for health, 1 for stamina).
			potion.type = rng.randi() % 2
			#we cannot directly call the add_child() function to add the potion, because it isn’t safe to add a new Area2D to the node tree inside a function that handles the on_area_entered() signal of another Area2D node. We must therefore use call_deferred() to defer the call to add_child() during idle time.
			get_tree().root.get_node("Root").call_deferred("add_child", potion)
			potion.position = position

#At the beginning, the function checks if the current animation is an attack animation and if the current frame is 1. If these conditions are true, it checks if the player is still in front of the skeleton and within range and, in that case, it calls Player‘s hit() function.
func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation.ends_with("_attack") and $AnimatedSprite.frame == 1:
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			player.hit(attackDamage)
			
		# Play attack sound
		$AttackSound.play()	
		
#save item data to save file
func saveToDictionary():
	return {
		"position" : [position.x, position.y],
		"health" : health
	}
	
#load game items from save file
func fromDictionary(data):
	position = Vector2(data.position[0], data.position[1])
	health = data.health
