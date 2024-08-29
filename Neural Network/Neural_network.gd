class_name NetworkNode extends Node

# This class represents a neural network node for an actor (e.g., a bird in a game).
# The actor that instantiates this class will utilize the neural network to learn
# and perform specific actions, such as jumping.

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var data : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var parent : Variant = get_parent() # References the parent node (the actor using this network)
var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes
var temp_data: PackedFloat32Array = PackedFloat32Array()

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
	temp_data.resize(max_value)
	data.resize(max_value)
	if network_input > max_value:
		data.resize(network_input)
		temp_data.resize(network_input)


func neuralNetwork() -> PackedFloat32Array:
	var weights_position: int = 0
	
	for i in range(network_hidden_layers.size()):
		# Get input data for the current layer
		if i == 0:
			temp_data = parent.gatherData()
		else:
			temp_data = node_saver.slice(0, network_hidden_layers[i - 1])

		# Initialize nodes for the current layer
		for j in range(network_hidden_layers[i]):
			var node_value: float = 0.0
			for k in range(temp_data.size()):
				node_value += temp_data[k] * weights[weights_position]
				weights_position += 1
			node_saver[j] = max(0.0, node_value)
	
	# Calculate the output layer
	for i in range(network_output):
		data[i] = max(0.0, node_saver[-1 - i] * weights[weights_position])
		weights_position += 1
	
	return data


# Runs the network every frame and send the information to the actor
func _process(_delta) -> void:
	parent.action(neuralNetwork())


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
