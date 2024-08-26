extends CharacterBody2D

@onready var camera = $Camera2D
const cam_deadzone = 50
const cam_mouse_influence = 0.3

@onready var anim_tree = $AnimTree
@onready var anim_state = anim_tree.get("parameters/playback")
enum player_states {MOVE, ATTACK, DODGE, DEAD}
var current_states = player_states.MOVE

var input_movement = Vector2.ZERO
var speed = Vector2(500, 300)

var frozen = true
var faction_id = -1

func _ready():
	set_multiplayer_authority(name.to_int())
	frozen = true
	$"PlayerID Display".set_text("[center]%s[/center]" % name)
	$DisplayAuthority.set_color(Color("#000000"))
	
func _physics_process(delta):
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

# movement
func move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Walk/blend_position", input_movement)
		anim_tree.set("parameters/Dodge/blend_position", input_movement)
		anim_state.travel("Walk")
		
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

# dodge roll
func dodge():
	anim_state.travel("Dodge")
	velocity = input_movement * speed
	move_and_slide()

func _on_state_reset():
	current_states = player_states.MOVE
	
func unfreeze():
	if not frozen:
		return
	frozen = false
	$Camera2D.enabled = true
	
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

# handle mouse peek for camera movement
#func _input(event: InputEvent):
	#if event is InputEventMouseMotion:
		#var target = event.position - get_viewport().size * cam_mouse_influence
		#if target.length() < cam_deadzone:
			#camera.position = Vector2(0,0)
		#else:
			#camera.position = target.normalized() * (target.length() - cam_deadzone) * cam_mouse_influence
	
