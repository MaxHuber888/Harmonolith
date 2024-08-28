extends CharacterBody2D

var speed = 300
var closestPlayer

signal hit_player

enum {
	SWARM,
	ATTACK,
	HURT,
}

var state = SWARM

func _ready():
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var randomnum = rng.randf()

func _physics_process(delta):
	closestPlayer = find_closest_player()
	match state:
		SWARM:
			move(closestPlayer, delta)
		ATTACK:
			attack()
		HURT:
			hurt()

func move(target, delta):
	var direction = (target.position - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	$AnimatedSprite2D.play("walk")
	move_and_slide()

func attack():
	$AnimatedSprite2D.play("attack")
	hit_player.emit()
	
func hurt():
	pass

func find_closest_player():
	var closestDistance = 100000000
	var closestPlayer = Object
	
	var all_players = get_tree().get_nodes_in_group("Player")
	for player in all_players:
		var enemy2player_distance = position.distance_to(player.position)
		if enemy2player_distance < closestDistance:
			closestDistance = enemy2player_distance
			closestPlayer = player
	return closestPlayer

func _on_hitbox_body_entered(body):
	state = ATTACK
	print("hit player " + body.name)
