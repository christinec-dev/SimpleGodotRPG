extends Area2D
 #Area2D allow the fireballs to cross water but be stopped by other obstacles

var tilemap #tilemap variable will contain a reference TileMap, which will let us know if the fireball is above water
var speed = 80
var direction : Vector2
var attackDamage

func _ready():
	# in main.tscn root/tilemap
	tilemap = get_tree().root.get_node("Root/Tilemap")

func _process(delta):
	#The position of the fireball must be recalculated at each frame.
	#The position is updated by adding to the current position the movement in this frame, calculated as speed * delta * direction
	position = position + speed * delta * direction	

#In this function we will check with what kind of object the fireball collided.
func _on_Fireball_body_entered(body):
	# ignore player and water collision
	if body.name == "Player":
		return
	
	if body.name == "Tilemap":
		var cellCoord = tilemap.world_to_map(position)
		var cellTypeID = tilemap.get_cellv(cellCoord)
		if cellTypeID == tilemap.tile_set.find_tile_by_name("Water"):
			return
		
	# if fireball its skeleton, call hit() func
	if body.name.find("Skeleton") >= 0:
		body.hit(attackDamage)
		
	#Stop movement and explode
	direction = Vector2.ZERO
	$AnimatedSprite.play("explode")

	# Play explosion sound
	$ExplosionSound.play()
	
#When the explosion animation ends, we can remove the fireball from the scene tree.
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "explode":
		get_tree().queue_delete(self)

#If the fireball does not hit anything, the fireball will self-destruct in 2 seconds.
func _on_Timer_timeout():
	$AnimatedSprite.play("explode")
