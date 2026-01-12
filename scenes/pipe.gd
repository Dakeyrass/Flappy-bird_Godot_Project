extends Area2D

signal hit 
signal scored

func _on_body_entered(_body: Node2D) -> void:
	hit.emit() # Quand quelque chose touche cette Area2D, envoie le signal "hit"

func _on_score_area_body_entered(_body: Node2D) -> void:
	scored.emit()
