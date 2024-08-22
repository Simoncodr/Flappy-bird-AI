class_name NetworkNode extends Node

@onready var weights : Array[float]
@onready var inputs : Array[float]
@onready var hidden_layers : Array[int] = [8, 8, 8, 8]
var connections : Array[float]
var final_output : float

func _ready() -> void:
	createConnections()

func createConnections():
	aquireInputData()
	for i in range(inputs.size()):
		for j in range(hidden_layers[0]):
			var range : float = randf_range(-100,100)
			connections.append(range)
	for i in range(hidden_layers.size()-1):
		for j in range(hidden_layers[i]):
			for k in range(hidden_layers[i + 1]):
				var range : float = randf_range(-1,1)
				connections.append(range)
	for i in range(hidden_layers[hidden_layers.size() - 1]):
		var range : float = randf_range(-1,1)
		connections.append(range)
	Game.POPULATIONWHEIGTS.append(connections)

func neuralNetwork() -> float:
	weights.append_array(Game.POPULATIONWHEIGTS[get_parent().number])
	aquireInputData()
	var node_saver : Array[float]
	var weights_position : float
	for i in range(hidden_layers.size()):
		for j in range(hidden_layers[i]):
			var weight : Array
			for k in range(inputs.size()):
				weight.append(weights[weights_position])
				weights_position += 1
			node_saver.append(node(inputs, weight))
	for i in range(hidden_layers[hidden_layers.size() - 1]):
		final_output += node_saver[i] * weights[weights_position]
		weights_position += 1
	return sigmoid(final_output)

func node(input : Array, weight : Array) -> float:
	var output : float
	for i in range(input.size()):
		output += input[i] * weight[i]
	return sigmoid(output)

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func shouldJump():
	if neuralNetwork() >= 0.5:
		get_parent().jump()

func aquireInputData():
	inputs.clear()
	inputs.append_array(get_parent().gatherData())


func _process(_delta) -> void:
	shouldJump()
