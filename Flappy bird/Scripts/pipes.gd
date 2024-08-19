extends Node2D

var once : bool = false

@onready var viewport : Vector2 = get_viewport().get_visible_rect().size
@onready var distance : int = randi_range(150,150)
@onready var starting_position : Vector2 = Vector2(viewport.x + 100, viewport.y / 2 + randf_range(-viewport.y/4, viewport.y/4))

@onready var bottom_pipe : CollisionShape2D = $Pipes/bottom
@onready var top_pipe : CollisionShape2D = $Pipes/top

func _ready() -> void:
	global_position = starting_position
	bottom_pipe.position.y = distance + 400
	top_pipe.position.y = -distance - 400


func _process(_delta) -> void:
	global_position.x -= 5
	addPoint()
	delete()

func delete() -> void:
	if global_position.x < -30:
		queue_free()

func addPoint() -> void:
	if global_position.x < 100:
		if !once:
			Game.Pipes.erase(self)
			once = true
			if Game.Pipes.size() > 0:
				Game.SCORE += 1

