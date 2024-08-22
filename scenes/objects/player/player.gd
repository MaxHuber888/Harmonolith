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

func _ready():
	set_multiplayer_authority(name.to_int())
	$DisplayAuthority.visible = is_multiplayer_authority()
	$"PlayerID Display".set_text("[center]%s[/center]" % name)
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
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

# handle mouse peek for camera movement
#func _input(event: InputEvent):
	#if event is InputEventMouseMotion:
		#var target = event.position - get_viewport().size * cam_mouse_influence
		#if target.length() < cam_deadzone:
			#camera.position = Vector2(0,0)
		#else:
			#camera.position = target.normalized() * (target.length() - cam_deadzone) * cam_mouse_influence
	
