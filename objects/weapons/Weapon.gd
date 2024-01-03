extends CollisionShape2D

var attack_damage := 10.0
var knockback := 100.0
var stun_time := 1.5

func _on_hitbox_area_entered(area):
	if area is HitboxComponent:
		print("Hit!")
		var hitbox : HitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback = knockback
		attack.attack_position = global_position
		attack.stun_time = stun_time
		
		hitbox.damage(attack)
