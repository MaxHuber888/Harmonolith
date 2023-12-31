extends CharacterBody2D

func _ready():
	set_multiplayer_authority(name.to_int())
	$DisplayAuthority.visible = is_multiplayer_authority()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	var speed_multiplier = Vector2(500,300)
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed_multiplier
	move_and_slide()
