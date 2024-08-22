extends Node

@export var TreeObj : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(5):
		var tree = TreeObj.instantiate()
		$EnemySpawn.add_child(tree)
		
		var pos := Vector2.from_angle(randf()*2*PI)
		tree.position = Vector2(pos.x * 1000 * randf(), pos.y * 1000 * randf())
		print(tree.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
