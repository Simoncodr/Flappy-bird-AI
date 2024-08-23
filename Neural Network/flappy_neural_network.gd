class_name NetworkNode extends Node

@onready var weights : PackedFloat32Array
@onready var inputs : PackedFloat32Array
@onready var hidden_layers : Array[int] = [8, 4, 7, 8]
@onready var parent = get_parent()


func _ready() -> void:
	createConnections()
	weights.append_array(Network.POPULATIONWEIGHTS[parent.number])

func createConnections():
	acquireInputData()
	
	# Initialize necessary variables
	var connections : PackedFloat32Array
	
	# Connect input layer to the first hidden layer
	for input_index in range(inputs.size()):
		for hidden_index in range(hidden_layers[0]):
			var weight: float = randf_range(-100, 100)
			connections.append(weight)
	
	# Connect hidden layers to each other
	for layer_index in range(hidden_layers.size() - 1):
		for neuron_index in range(hidden_layers[layer_index]):
			for next_neuron_index in range(hidden_layers[layer_index + 1]):
				var weight: float = randf_range(-1, 1)
				connections.append(weight)
	
	# Connect the last hidden layer to the output layer
	for output_index in range(hidden_layers[-1]):
		var weight: float = randf_range(-1, 1)
		connections.append(weight)
	
	# Add the connections to the population weights
	Network.POPULATIONWEIGHTS.append(connections)


func neuralNetwork() -> float:
	var final_output: float = 0.0
	
	# Initialize necessary variables
	var node_saver: PackedFloat32Array
	var weights_position: int = 0
	
	# Gemmer inputet fra laget før.
	for i in range(hidden_layers.size()):
		if i != 0:
			inputs.clear()
			for j in range(hidden_layers[i - 1]):
				inputs.append(node_saver[node_saver.size() - j - 1])
		else:
			acquireInputData()
	
		for j in range(hidden_layers[i]):
			var weight: Array = []
			for k in range(inputs.size()):
				weight.append(weights[weights_position])
				weights_position += 1
			node_saver.append(node(inputs, weight))
	
	# Calculate the final output
	for i in range(hidden_layers[-1]):
		final_output += node_saver[i] * weights[weights_position]
		weights_position += 1
	
	# Return the sigmoid of the final output
	return sigmoid(final_output)


# Handles the math for every node in the network.
func node(input : Array, weight : Array) -> float:
	var output : float
	for i in range(input.size()):
		output += input[i] * weight[i]
	return sigmoid(output)


# Sigmoid function (It takes the given number and turns it into a number between 0 and 1)
func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))


# Uses the output of the neural network, to determin in the bird should jump
func shouldJump() -> void:
	# If the value is equal to or bigger and 0.5 the bird jumps
	if neuralNetwork() >= 0.5:
		parent.jump()


# Gets the input data from the parent
func acquireInputData() -> void:
	inputs.clear()
	inputs.append_array(parent.gatherData())

# Runs the network every frame to determin if the bird should jump
func _process(_delta) -> void:
	shouldJump()
