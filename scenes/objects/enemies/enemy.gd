class_name Enemy
extends CharacterBody2D

signal hit_player

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
enum {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
}
var state = IDLE

var speed = 300
var steering_coeff = 2
var sight_range = 350
var attack_range = 60

var health = 100
var target

func _ready():
	$Sight/CollisionShape2D.shape.radius = sight_range
	$AttackRange/CollisionShape2D.shape.radius = attack_range

func _physics_process(delta):
	match state:
		IDLE:
			idle()
		MOVE:
			move(target, delta)
		ATTACK:
			attack()
		HURT:
			hurt()
	if health < 0:
		queue_free()

func idle():
	anim_state.travel("idle")
	pass

func move(target, delta):
	var direction = (target.position - global_position).normalized()
	# Flip sprite based on movement direction
	if direction.x < 0:
		$Sprite2D.flip_h = true  # Flip horizontally
		$Hitbox.scale.x = -1
		$Hurtbox.scale.x = -1
		$AttackRange.scale.x = -1
	elif direction.x > 0:
		$Sprite2D.flip_h = false  # Reset to original orientation
		$Hitbox.scale.x = 1
		$Hurtbox.scale.x = 1
		$AttackRange.scale.x = 1
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * steering_coeff
	velocity += steering
	anim_state.travel("walk")
	move_and_slide()

func attack():
	anim_state.travel("attack")
	
func hurt():
	anim_state.travel("hurt")

# COLLISION DETECTION

func _on_sight_body_entered(body):
	target = body
	state = MOVE

func _on_sight_body_exited(body):
	state = IDLE

func _on_attack_range_body_entered(body):
	state = ATTACK

func _on_attack_range_body_exited(body):
	state = MOVE

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		print("hit player " + body.name)
		hit_player.emit()

func _on_hitbox_body_entered(body):
	print("oof")
	health -= 50
	state = HURT
