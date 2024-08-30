extends CharacterBody2D

@onready var camera = $Camera2D
const cam_deadzone = 50
const cam_mouse_influence = 0.3

@onready var anim_tree = $AnimTree
@onready var anim_state = anim_tree.get("parameters/playback")
enum player_states {
	MOVE, 
	ATTACK, 
	DODGE, 
	DEAD
}
var current_states = player_states.MOVE

var input_movement = Vector2.ZERO
var speed = Vector2(500, 500)
var dodge_coeff = 2

var health = 100

var frozen = true
var faction_id = -1
var direction = "right"

func _ready():
	set_multiplayer_authority(name.to_int())
	frozen = true
	$"PlayerID Display".set_text("[center]%s[/center]" % name)
	$DisplayAuthority.set_color(Color("#000000"))
	
func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	if not frozen:
		camera.make_current()
		match current_states:
			player_states.MOVE:
				move()
			player_states.ATTACK:
				attack()
			player_states.DODGE:
				dodge()
		update_hurtbox_position()

# movement
func move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		anim_state.travel("Walk")
		
		# Flip sprite based on movement direction
		if input_movement.x < 0 and direction == "right":
			$BodySprite.flip_h = true  # Flip horizontally
			direction = "left"
		elif input_movement.x > 0 and direction == "left":
			$BodySprite.flip_h = false  # Reset to original orientation
			direction = "right"
		
		velocity = input_movement * speed
		
	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		current_states = player_states.ATTACK
	
	if Input.is_action_just_pressed("dodge"):
		current_states = player_states.DODGE
	
	move_and_slide()

# attacking
func attack():
	anim_state.travel("Attack")
	current_states = player_states.MOVE

# dodge roll
func dodge():
	anim_state.travel("Dodge")
	velocity = input_movement * speed * dodge_coeff
	current_states = player_states.MOVE
	move_and_slide()

func _on_hitbox_body_entered(body):
	health -= 25
	print("yowch")
	pass # Replace with function body.


func _on_hurtbox_body_entered(body):
	print("Hit enemy " + body.name)
	pass # Replace with function body.


func unfreeze():
	if not frozen:
		return
	frozen = false
	$Camera2D.enabled = true
	
# handle mouse peek for camera movement
#func _input(event: InputEvent):
	#if event is InputEventMouseMotion:
		#var target = event.position - get_viewport().size * cam_mouse_influence
		#if target.length() < cam_deadzone:
			#camera.position = Vector2(0,0)
		#else:
			#camera.position = target.normalized() * (target.length() - cam_deadzone) * cam_mouse_influence
	
func update_hurtbox_position():
	var mouse_position = get_global_mouse_position()
	var player_position = global_position
	var direction_vector = mouse_position - player_position

	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			$Hurtbox.set_rotation_degrees(0)  # Move hurtbox to the right of the player
		else:
			$Hurtbox.set_rotation_degrees(180) # Move hurtbox to the left of the player
	else:
		if direction_vector.y < 0:
			$Hurtbox.set_rotation_degrees(270)  # Move hurtbox below the player
		else:
			$Hurtbox.set_rotation_degrees(90)  # Move hurtbox above the player

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
