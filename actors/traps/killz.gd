extends Node2D

func _on_area_2d_body_entered( body: Node ) -> void:
	print("Killz")
	if HealthComponent.FIELD_NAME in body:
		var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
		health_component.instakill()
	else:
		body.queue_free()

func _on_area_2d_area_entered( area: Area2D ) -> void:
	print("Killz 2")
#	if HealthComponent.FIELD_NAME in area:
#		var health_component: Health_component = area[HealthComponent.FIELD_NAME]
#		health_component.instakill()
#	else:
#		area.queue_free()