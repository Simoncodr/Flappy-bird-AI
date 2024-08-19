extends Node

@onready var weights : Array[float]
@onready var inputs : Array[float]
@onready var hidden_layer_nodes : float = 4
@onready var hidden_layer_values : Array[float]
var final_output : float

func _ready() -> void:
	createConnections()
	#weights.append_array(get_parent())

func createConnections():
	aquireInputData()
	for i in range(inputs.size()):
		for j in range(hidden_layer_nodes):
			var range : float = randf_range(-100,100)
			get_parent().connections.append(range)
	for i in range(hidden_layer_nodes):
		var range : float = randf_range(-1,1)
		get_parent().connections.append(range)
	get_parent().appendWeights()

func _process(_delta) -> void:
	shouldJump()
	

func neuralNetwork() -> float:
	weights.append_array(Game.POPULATIONWHEIGTS[get_parent().number])
	aquireInputData()
	var nodeSaver : Array[float]
	var weightsPosition : float
	for i in range(hidden_layer_nodes):
		var weight : Array
		for j in range(inputs.size()):
			weight.append(weights[weightsPosition])
			weightsPosition += 1
		nodeSaver.append(node(inputs, weight))
	for i in range(hidden_layer_nodes):
		final_output += nodeSaver[i] * weights[weightsPosition]
		weightsPosition += 1
	return sigmoid(final_output)

func node(input : Array, weight : Array) -> float:
	var output : float
	for i in range(input.size()):
		output += input[i] * weight[i]
	return sigmoid(output)

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func shouldJump():
	#print(neuralNetwork())
	if neuralNetwork() >= 0.5:
		get_parent().jump()

func aquireInputData():
	inputs.clear()
	inputs.append_array(get_parent().gatherData())

func printBestBirdNodes():
	pass
