extends RigidBody2D

var neural_network : PackedScene = preload("res://Neural Network/flappy_neural_network.tscn")

var jump_impulse = Vector2(0, -700)
var max_velocity = 600  
var rotation_speed = 0.4 
var example : bool = true
var number : int
var score : int
@onready var texture : Sprite2D = $Sprite2D

# Inputs
var velocity : float = 0
var distanceToPipeY : float = 0
var distanceToPipe : float = 0

func _ready() -> void:
	var brain = neural_network.instantiate()
	add_child(brain)

func _process(_delta) -> void:
	birdRotation(linear_velocity.y)
	dynamicScore()

func birdRotation(velocity: float) -> void:
	var max_rotation = deg_to_rad(75)  
	var min_rotation = deg_to_rad(-75)  
	var desired_rotation = clamp(velocity / 400.0, min_rotation, max_rotation)
	texture.rotation = lerp_angle(rotation, desired_rotation, rotation_speed)

func _input(event) -> void:
	if event.is_action_pressed("jump") and event.is_pressed() and Game.STATE == "PLAYER":
		apply_central_impulse(jump_impulse - linear_velocity)

func jump() -> void:
	if Game.STATE == "AI":
		apply_central_impulse(jump_impulse - linear_velocity)

func _integrate_forces(state) -> void:
	var velocity = state.linear_velocity
	if velocity.y < 0 and velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
	state.linear_velocity = velocity


func _on_area_2d_area_entered(area) -> void:
	if area.is_in_group("PIPES"):
		calculateFitness()
		deleteSelf()

func deleteSelf() -> void:
	Game.POPULATION.erase(self)
	queue_free()


func gatherData() -> Array[float]:
	var data : Array[float]
	velocity = linear_velocity.y
	if Game.Pipes.size() > 0 and Game.Pipes[0] != null:
		distanceToPipeY = Game.Pipes[0].global_position.y - global_position.y
		distanceToPipe = Game.Pipes[0].global_position.x - global_position.x
	data.append(velocity)
	data.append(distanceToPipeY)
	data.append(distanceToPipe)
	return data 

func dynamicScore():
	if global_position.y >= Game.Pipes[0].global_position.y - 50 and global_position.y <= Game.Pipes[0].global_position.y + 50:
		score += 1
	else:
		score -= 1

func calculateFitness() -> void:
	if Game.POPUlATIONSCORE.size() >= number:
		gatherData()
		Game.POPUlATIONSCORE[number] = (5000-distanceToPipe) * (Game.SCORE + 1) + score
