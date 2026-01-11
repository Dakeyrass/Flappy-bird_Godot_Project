extends Area2D


signal hit 


func _on_body_entered(body: Node2D) -> void:
	hit.emit() # Quand quelque chose touche cette Area2D, envoie le signal "hit"
