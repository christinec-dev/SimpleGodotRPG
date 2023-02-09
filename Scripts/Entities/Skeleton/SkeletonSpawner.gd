extends Node2D

# Nodes references
var tilemap
var tree_tilemap

#spawner variables
export var spawnArea : Rect2 = Rect2(50, 150, 700, 700)
export var maxSkeletons = 40
export var startSkeletons = 10
var skeletonCount = 0
var skeletonScene = preload("res://Scenes/Enemies/Skeleton.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()

#checks valid spawn positions
func testPosition(position : Vector2):
	#check if it has grass or sand
	var cellCoord = tilemap.world_to_map(position)
	var cellTypeID = tilemap.get_cellv(cellCoord)
	var grassOrSand = (cellTypeID == tilemap.tile_set.find_tile_by_name("Grass") || cellTypeID == tilemap.tile_set.find_tile_by_name("Sand"))
	
	#check if it has trees
	cellCoord = tilemap.world_to_map(position)
	cellTypeID = tilemap.get_cellv(cellCoord)
	var noTreesOrWater = (cellTypeID != tilemap.tile_set.find_tile_by_name("Tree") || cellTypeID != tilemap.tile_set.find_tile_by_name("Water"))
	
	return grassOrSand and noTreesOrWater

#The function that handles the signal is very simple, it simply decrease the quantity of skeletons by one:
func onSkeletonDeath():
	skeletonCount = skeletonCount - 1
	
#spawn skeleton	
func instanceSkeleton():
	# Instance the skeleton scene and add it to the scene tree
	var skeleton = skeletonScene.instance()
	add_child(skeleton)
	# Connect Skeleton's death signal to the spawner
	skeleton.connect("death", self, "onSkeletonDeath")
	
	# Place the skeleton in a valid position
	var validPos = false
	while not validPos:
		skeleton.position.x = spawnArea.position.x + rng.randf_range(0, spawnArea.size.x)
		skeleton.position.y = spawnArea.position.y + rng.randf_range(0, spawnArea.size.y)
		validPos = testPosition(skeleton.position)
		# Play skeleton's birth animation
		skeleton.arise()

func _ready():
	#get tilemap ref
	tilemap = get_tree().root.get_node("Root/Tilemap")
	tree_tilemap = get_tree().root.get_node("Root/TreesTilemap")
	
	#init random num gen
	rng.randomize()
	
	#Create skeletons
	if not get_parent().loadSavedGame:
		for i in range(startSkeletons):
			instanceSkeleton()
		skeletonCount = startSkeletons

func _on_Timer_timeout():
	#check if we need to create skeletons every second
	if skeletonCount < maxSkeletons:
		instanceSkeleton()
		skeletonCount = skeletonCount + 1	
		
#save items to be added to save file
func saveToDictionary():
	var skeletons = []
	for node in get_children():
		if node.name.find("Skeleton") >= 0:
			skeletons.append(node.saveToDictionary())
	return skeletons
	
#load game items from save file
func fromDictionary(data):
	skeletonCount = data.size()
	for skeletonData in data:
		var skeleton = skeletonScene.instance()
		skeleton.fromDictionary(skeletonData)
		add_child(skeleton)
		skeleton.get_node("Timer").start()
		
		# Connect Skeleton's death signal to the spawner
		skeleton.connect("death", self, "onSkeletonDeath")

