#When the fireball animation ends, the function instantiates a new fireball scene, placing it 4 pixels away in front of the player. 
#In our case, it will allow us to see in the editor what kind of potion we instantiated. Without using the keyword tool, both types of potions would be shown in the editor with the same sprite.
tool

extends Area2D

# store the type of potion:
enum Potion {HEALTH, STAMINA}
export (Potion) var type = Potion.HEALTH # keyword export makes a variable visible in the Inspector

# the sprite will change as soon as we change the value of Type in the Inspector.
# remember, the sprite is made of of two potions on the image, so the x position frames each one
func _process(delta):
	if Engine.editor_hint:
		if type == Potion.STAMINA:
			$Sprite.region_rect.position.x = 8
		else:
			$Sprite.region_rect.position.x = 0
			
#When running the game, we need to set potion’s sprite at the beginning. So, we must put the type check in the _ready() function:
func _ready():
	if type == Potion.STAMINA:
		$Sprite.region_rect.position.x = 8
	else:
		$Sprite.region_rect.position.x = 0
		
#If the player walk over a potion, we want it to be picked up.
func _on_Potions_body_entered(body):
	if body.name == "Player":
		body.addPotion(type)
		get_tree().queue_delete(self)
