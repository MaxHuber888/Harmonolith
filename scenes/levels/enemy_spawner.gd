extends Node2D

var enemy_scene := preload("res://scenes/objects/enemies/brat.tscn")
var spawn_points := []
var spawn_time = 5
var max_enemies = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = spawn_time
	
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	# spawn only on server-side, synchronize on clients
	if is_multiplayer_authority():
		# check how many entites spawned already
		var entities = get_tree().get_nodes_in_group("Entities")
		if entities.size() < max_enemies:
			var spawn = spawn_points[randi() % spawn_points.size()]
			var enemy = enemy_scene.instantiate()
			enemy.position = spawn.position
			
			print("Enemy spawn")
			add_child(enemy, true)
			enemy.add_to_group("Entities")
	
