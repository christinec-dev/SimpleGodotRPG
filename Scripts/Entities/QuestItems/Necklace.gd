extends Area2D

var fiona

func _ready():
	fiona = get_tree().root.get_node("Root/Fiona")

func _on_Necklace_body_entered(body):
	if body.name == "Player":
		# Play sound
		$ObjectSound.play()
		hide()
		fiona.necklaceFound = true

#will play sound before necklace is removed
func _on_ObjectSound_finished():
	get_tree().queue_delete(self)
