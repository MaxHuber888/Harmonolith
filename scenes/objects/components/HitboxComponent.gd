extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent

# Called when the node enters the scene tree for the first time.
func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
