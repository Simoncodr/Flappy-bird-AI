extends RigidBody2D

var jump_impulse = Vector2(0, -700)
var max_velocity = 600  
var rotation_speed = 0.4 
var example : bool = true
var number : int
var score : int
var game_state : String
@onready var pipes : Array = get_parent().PIPES
@onready var texture : Sprite2D = $Sprite2D

# Inputs
var velocity : float = 0
var distanceToPipeY : float = 0
var distanceToPipe : float = 0

func _process(_delta) -> void:
	birdRotation(linear_velocity.y)
	dynamicScore()
	showOrHide()

func birdRotation(velocityY: float) -> void:
	var max_rotation = deg_to_rad(75)  
	var min_rotation = deg_to_rad(-75)  
	var desired_rotation = clamp(velocityY / 400.0, min_rotation, max_rotation)
	texture.rotation = lerp_angle(rotation, desired_rotation, rotation_speed)

func _input(event) -> void:
	if event.is_action_pressed("jump") and event.is_pressed():
		apply_central_impulse(jump_impulse - linear_velocity)

func action(network : PackedFloat32Array) -> void:
	if network[0] > network[1]:
		apply_central_impulse(jump_impulse - linear_velocity)

func _integrate_forces(state) -> void:
	var velocity_force = state.linear_velocity
	if velocity_force.y < 0 and velocity_force.length() > max_velocity:
		velocity_force = velocity_force.normalized() * max_velocity
	state.linear_velocity = velocity_force


func _on_area_2d_area_entered(area) -> void:
	if area.is_in_group("PIPES"):
		calculateFitness()
		deleteSelf()

func deleteSelf() -> void:
	Network.POPULATION.erase(self)
	queue_free()


func gatherData() -> PackedFloat32Array:
	var data : PackedFloat32Array = []
	velocity = linear_velocity.y
	if pipes.size() > 0 and pipes[0] != null:
		distanceToPipeY = pipes[0].global_position.y - global_position.y
		distanceToPipe = pipes[0].global_position.x - global_position.x
	data.append(velocity)
	data.append(distanceToPipeY)
	data.append(distanceToPipe)
	return data 

func dynamicScore():
	if global_position.y >= pipes[0].global_position.y + 160 and global_position.y <= pipes[0].global_position.y + 30:
		score += 5
	else:
		score -= 1

func calculateFitness() -> void:
	if Network.POPUlATIONSCORE.size() >= number:
		gatherData()
		Network.POPUlATIONSCORE[number] = (5000-distanceToPipe) * (get_parent().SCORE + 1)# + score

func showOrHide():
	if self == Network.POPULATION[0]:
		show()
	else:
		hide()
