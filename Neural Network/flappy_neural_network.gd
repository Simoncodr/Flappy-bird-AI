class_name NetworkNode extends Node

# This class represents a neural network node for an actor (e.g., a bird in a game).
# The actor that instantiates this class will utilize the neural network to learn
# and perform specific actions, such as jumping.

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var inputs : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var hidden_layers : PackedInt32Array = [8, 4, 7, 8] #NOTE The numbers specify how many nodes are in each layer
@onready var output : PackedInt32Array = [2] # NOTE The number of outputs
@onready var parent = get_parent() # References the parent node (the actor using this network)

# Called when the node is added to the scene.
func _ready() -> void:
	createConnections() # Created the connections
	weights.append_array(Network.POPULATIONWEIGHTS[parent.number]) # Appends the current weights that the actor should have

# Calculates the nessesary amount of connections needed and appends an initial value to the weights array
func createConnections():
	
	# Gets the data from the parent to determin the size of the input layer
	acquireInputData()
	
	# Initialize necessary variables
	var connections : PackedFloat32Array = []
	
	# Creates connections from the input layer to the first hidden layer
	for input_index in range(inputs.size()):
		for hidden_index in range(hidden_layers[0]):
			var weight: float = randf_range(-100, 100)
			connections.append(weight)
	
	# Creates the connections between the hidden layers
	for layer_index in range(hidden_layers.size() - 1):
		for neuron_index in range(hidden_layers[layer_index]):
			for next_neuron_index in range(hidden_layers[layer_index + 1]):
				var weight: float = randf_range(-1, 1)
				connections.append(weight)
	
	# Creates the connections from the final layer to the output
	for i in range(output.size()):
		for j in range(hidden_layers[-1]):
			var weight: float = randf_range(-1, 1)
			connections.append(weight)
	
	# Adds the connections to the population weights
	Network.POPULATIONWEIGHTS.append(connections)

# This function does the dirtywork and determins the output based on the input and weights
func neuralNetwork() -> PackedFloat32Array:
	var final_output: PackedFloat32Array = []
	
	# Initialize necessary variables
	var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes
	var weights_position: int = 0 # Used to know what weight should be used when
	
	# Uses the inputs from the previous layer, unless it's the first one. Then i uses the data from the parent
	for i in range(hidden_layers.size()):
		if i != 0:
			inputs.clear()
			for j in range(hidden_layers[i - 1]):
				inputs.append(node_saver[-1- j])
		else:
			acquireInputData()
	
	# Loops through the layer and adds the weight and layer together to get an final value for each node
		for j in range(hidden_layers[i]):
			var weight: Array = []
			for k in range(inputs.size()):
				weight.append(weights[weights_position])
				weights_position += 1
			node_saver.append(node(inputs, weight))
	
	# Calculates the final output and appends it to the output array
	for i in range(hidden_layers[-1]):
		final_output.append(sigmoid(node_saver[i] * weights[weights_position]))
		weights_position += 1
	
	# Return the final output
	return final_output


# Handles the math for every node in the network.
# It adds together the values of the input and their respective weights into a final value
func node(input : Array, weight : Array) -> float:
	var output : float = 0
	for i in range(input.size()):
		output += input[i] * weight[i]
	return sigmoid(output)


# Sigmoid function (It takes the given number and turns it into a number between 0 and 1)
func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))


# Gets the input data from the parent
func acquireInputData() -> void:
	inputs.clear()
	inputs.append_array(parent.gatherData())


# Runs the network every frame and send the information to the actor
func _process(_delta) -> void:
	parent.action(neuralNetwork())
