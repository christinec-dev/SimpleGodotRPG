extends Node2D

#show hide roof on body entry
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Roof.hide()
	#prevent skeleton from entering house
	elif body.name.find("Skeleton") >= 0:
		body.direction = -body.direction
		body.bounceCountdown = 16
		
func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$Roof.show()
