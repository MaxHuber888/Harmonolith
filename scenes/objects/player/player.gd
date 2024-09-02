extends CharacterBody2D

@onready var camera = $Camera2D
const cam_deadzone = 50

@onready var anim_player = $AnimPlayer
@onready var player_sprite = $BodySprite
enum player_states {
	NORMAL,
	DODGE, 
	EMOTE, 
	DEAD
}
var current_states = player_states.NORMAL
var walking_angle = 0
var looking_angle = 0
var player_moving = false
var player_attacking = false

var input_movement = Vector2.ZERO
var speed = Vector2(500, 500)
var dodge_coeff = 2

var health = 100

var frozen = true
var faction_id = -1

func _ready():
	set_multiplayer_authority(name.to_int())
	frozen = true
	anim_player.stop()
	anim_player.play(str("idle-",walking_angle))
	#$"PlayerID Display".set_text("[center]%s[/center]" % name)
	$DisplayAuthority.set_color(Color("#000000"))
	
func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	if not frozen:
		camera.make_current()
		update_current_angle()
		match current_states:
			player_states.NORMAL:
				normal()
			player_states.DODGE:
				dodge()
			player_states.EMOTE:
				emote()
			player_states.DEAD:
				die()
			
		

# moves the player, plays attack animation when attacking
func normal():
	# GET USER MOVEMENT INPUT
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# IF MOVING
	if input_movement != Vector2.ZERO:
		# IF ATTACKING
		if Input.is_action_just_pressed("attack"):
			# PLAY ATTACKING MOVING
			anim_player.play(str("attack-walk-",looking_angle))
		# IF NOT ATTACKING
		else:
			# PLAY MOVING
			anim_player.play(str("walk-",walking_angle))
		
		velocity = input_movement * speed
	
	# IF NOT MOVING
	else:
		# IF ATTACKING
		if Input.is_action_just_pressed("attack"):
			anim_player.play(str("attack-idle-",looking_angle))
		# IF NOT ATTACKING
		else:
			# PLAY IDLE
			anim_player.play(str("idle-",looking_angle))
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("dodge"):
		current_states = player_states.DODGE
		
	if Input.is_action_just_pressed("emote"):
		current_states = player_states.EMOTE
	
	move_and_slide()

func emote():
	anim_player.play("emote-wave")
	await anim_player.animation_finished
	current_states = player_states.NORMAL
	
func die():
	pass

# dodge roll
func dodge():
	velocity = input_movement * speed * dodge_coeff
	current_states = player_states.NORMAL
	move_and_slide()

func _on_hitbox_body_entered(body):
	health -= 25
	print("Player hit!")
	pass # Replace with function body.


func _on_hurtbox_body_entered(body):
	print("Hit enemy " + body.name)
	pass # Replace with function body.


func unfreeze():
	if not frozen:
		return
	frozen = false
	$Camera2D.enabled = true
	
func update_current_angle():
	# Get vector between player and mouse
	var mouse_position = get_global_mouse_position()
	var player_position = global_position
	var direction_vector = mouse_position - player_position
	
	looking_angle = get_direction_of_vector(direction_vector)
	walking_angle = get_direction_of_vector(velocity)
	
	$"PlayerID Display".set_text("[center]%s[/center]" % str(looking_angle))

func get_direction_of_vector(vec: Vector2) -> int:
	# Get angle in degrees, with 0 being down
	var angle = int(rad_to_deg(vec.angle()))
	angle = angle - 90
	if angle > 0:
		angle += -360
	angle = angle * -1
	
	const RAY_NUM = 4 # or 8 if you want 8 directions
	
	if RAY_NUM == 4:
		# Match to nearest 90 deg ray
		if angle <= 45 or angle > 315:
			return 0
		elif angle > 45 and angle <= 135:
			return 90
		elif angle > 135 and angle <= 225:
			return 180
		elif angle > 225 and angle <= 315:
			return 270
		else:
			return 0
	elif RAY_NUM == 8:
		# Match to nearest 45 deg ray
		if angle <= 22 or angle > 337:
			return 0
		elif angle > 22 and angle <= 67:
			return 45
		elif angle > 67 and angle <= 112:
			return 90
		elif angle > 112 and angle <= 157:
			return 135
		elif angle > 157 and angle <= 202:
			return 180
		elif angle > 202 and angle <= 247:
			return 225
		elif angle > 247 and angle <= 292:
			return 270	
		elif angle > 292 and angle <= 337:
			return 315
		else:
			return 0
	else:
		print("invalid ray count in Player")
		return -1

func set_faction(f_id):
	faction_id = f_id
	match faction_id:
		0:
			$DisplayAuthority.set_color(Color("#ffca21"))
		1:
			$DisplayAuthority.set_color(Color("#0097ff"))
		2:
			$DisplayAuthority.set_color(Color("#50f14a"))
		3:
			$DisplayAuthority.set_color(Color("#ff0056"))
