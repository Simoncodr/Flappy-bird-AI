class_name NetworkNode extends Node

# This class represents a neural network node for an actor (e.g., a bird in a game).
# The actor that instantiates this class will utilize the neural network to learn
# and perform specific actions, such as jumping.

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var data : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var parent : Variant = get_parent() # References the parent node (the actor using this network)
var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes

@onready var network_input : int = Network.input
@onready var network_hidden_layers : PackedInt32Array = Network.hidden_layers
@onready var network_output : int = Network.output

# Finds the largest value in the hidden layers
func findLargest():
	var max_value = network_output  # Start with the smallest possible value
	for value in network_hidden_layers:
		if value > max_value:
			max_value = value
	node_saver.resize(max_value)
	data.resize(max_value)
	if network_input > max_value:
		data.resize(network_input)

# Called when the node is added to the scene.
func _ready() -> void:
	createConnections() # Created the connections
	weights.append_array(Network.POPULATIONWEIGHTS[parent.number]) # Appends the current weights that the actor should have
	findLargest()


# Calculates the nessesary amount of connections needed and appends an initial value to the weights array
func createConnections():
	
	# Initialize necessary variables
	var connections : PackedFloat32Array = []
	
	# Creates connections from the input layer to the first hidden layer
	for i in range(network_input):
		for j in range(network_hidden_layers[0]):
			var weight: float = randf_range(-100, 100)
			connections.append(weight)
	
	# Creates the connections between the hidden layers
	for i in range(network_hidden_layers.size() - 1):
		for j in range(network_hidden_layers[i]):
			for k in range(network_hidden_layers[i + 1]):
				var weight: float = randf_range(-1, 1)
				connections.append(weight)
	
	# Creates the connections from the final layer to the output
	for i in range(network_output):
		for j in range(network_hidden_layers[-1]):
			var weight: float = randf_range(-1, 1)
			connections.append(weight)
	
	# Adds the connections to the population weights
	Network.POPULATIONWEIGHTS.append(connections)


# This function does the dirtywork and determins the output based on the input and weights
func neuralNetwork() -> PackedFloat32Array:
	
	# Initialize necessary variables
	var weights_position: int = 0 # Used to know what weight should be used when
	
	# Uses the inputs from the previous layer, unless it's the first one. Then i uses the data from the parent
	for i in range(network_hidden_layers.size()):
		var tempInputLength : int = 0
		if i != 0:
			for j in range(network_hidden_layers[i - 1]):
				data[j] = (node_saver[-1- j])
				tempInputLength += 1
		else:
			for j in range(network_input):
				data[j] = parent.gatherData()[j]
				tempInputLength += 1
		
	# Loops through the layer and adds the weight and layer together to get an final value for each node
		for j in range(network_hidden_layers[i]):
			var node_value: float = 0.0
			for k in range(tempInputLength):
				node_value += data[k] * weights[weights_position]
				weights_position += 1
			node_saver[j] = (relu(node_value))
	
	# Calculates the final output and appends it to the output array
	for i in range(network_output):
		data[i] = (relu(node_saver[-i] * weights[weights_position]))
		weights_position += 1
	
	# Return the final output
	return data


# ReLU function (It takes in a number, and returns it. Unless it's negative, in which case it returns 0)
func relu(x: float) -> float:
	return max(0.0, x)



# Runs the network every frame and send the information to the actor
func _process(_delta) -> void:
	parent.action(neuralNetwork())
