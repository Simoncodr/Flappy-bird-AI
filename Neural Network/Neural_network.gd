class_name NetworkNode extends Node

# This class represents a neural network node for an actor (e.g., a bird in a game).
# The actor that instantiates this class will utilize the neural network to learn
# and perform specific actions, such as jumping.

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var inputs : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var parent : Variant = get_parent() # References the parent node (the actor using this network)
var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes

@onready var network_input : int = Network.input
@onready var network_hidden_layers : PackedInt32Array = Network.hidden_layers
@onready var network_output : int = Network.output

var max_layer_size: int;

func getMaxLayerSize() -> int:
	var max_size = max(network_input, network_output);
	
	for i in network_hidden_layers.size():
		var size = network_hidden_layers[i];
		max_size = max(max_size, size);
		
	return max_size;

# Finds the largest value in the hidden layers
func findLargest():
	var max_value = 0  # Start with the smallest possible value
	for value in network_hidden_layers:
		if value > max_value:
			max_value = value
	node_saver.resize(max_value)
	inputs.resize(max_value)
	if parent.gatherData().size() > max_value:
		inputs.resize(parent.gatherData())

# Called when the node is added to the scene.
func _ready() -> void:
	createConnections() # Created the connections
	weights.append_array(Network.POPULATIONWEIGHTS[parent.number]) # Appends the current weights that the actor should have
	findLargest()
	
	max_layer_size = getMaxLayerSize();


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


func newNeuralNetwork() -> PackedFloat32Array:
	var old_layer: PackedFloat32Array = PackedFloat32Array();
	old_layer.resize(max_layer_size);
	
	var new_layer: PackedFloat32Array = old_layer.duplicate();
	
	# Insert input values in old_layer
	acquireInputData();
	for i in network_input:
		old_layer.set(i, inputs[i]);
	
	var weight_index_offset: int = 0;
	var prev_layer_size: int = network_input;
	var layer_size: int
	
	# Calculate hidden layers
	for i in network_hidden_layers.size():
		layer_size = network_hidden_layers[i];
		
		for j in layer_size:
			var value: float;
			for k in prev_layer_size:
				var weight: float = weights[weight_index_offset + j * prev_layer_size + k];
				value += old_layer[k] * weight;
				
			new_layer[j] = relu(value);
		
		weight_index_offset += prev_layer_size * layer_size;
		prev_layer_size = layer_size;
		
		# copy new_layer values to old_layer
		for j in max_layer_size:
			old_layer[j] = new_layer[j];
	
	# Calculate output
	for i in network_output:
		var value: float;
		for j in prev_layer_size:
			value += old_layer[j] * weights[weight_index_offset + i * prev_layer_size + j];
		new_layer[i] = relu(value);

	# Return the final output
	var output: PackedFloat32Array = new_layer.slice(0, network_output);

	return output;


# This function does the dirtywork and determins the output based on the input and weights
func neuralNetwork() -> PackedFloat32Array:
	var final_output: PackedFloat32Array = [];
	
	# Initialize necessary variables
	var weights_position: int = 0 # Used to know what weight should be used when
	
	# Uses the inputs from the previous layer, unless it's the first one. Then i uses the data from the parent
	for i in range(network_hidden_layers.size()):
		var tempInputLength : int = 0
		if i != 0:
			for j in range(network_hidden_layers[i - 1]):
				inputs[j] = (node_saver[-1- j])
				tempInputLength += 1
		else:
			acquireInputData()
			tempInputLength += parent.gatherData().size()
		#print(tempInputLength)
	# Loops through the layer and adds the weight and layer together to get an final value for each node
		for j in range(network_hidden_layers[i]):
			var node_value: float = 0.0
			for k in range(tempInputLength):
				node_value += inputs[k] * weights[weights_position]
				weights_position += 1
			node_saver[j] = (relu(node_value))
	
	# Calculates the final output and appends it to the output array
	for i in range(network_output):
		final_output.append(relu(node_saver[-i] * weights[weights_position]))
		weights_position += 1
	
	# Return the final output
	return final_output


# ReLU function (It takes in a number, and returns it. Unless it's negative, in which case it returns 0)
func relu(x: float) -> float:
	return max(0.0, x)

# Gets the input data from the parent
func acquireInputData() -> void:
	var data = parent.gatherData();
	for i in range(data.size()):
		inputs[i] = data[i];


# Runs the network every frame and send the information to the actor
func _process(_delta) -> void:
	#var start_time := Time.get_ticks_usec();
	#var result := neuralNetwork();
	#var end_time := Time.get_ticks_usec();
	
	#print("old time: ", (end_time - start_time) / 1000.0, " ms");
	
	var start_time = Time.get_ticks_usec();
	var result = newNeuralNetwork();
	var end_time = Time.get_ticks_usec();
	
	print("total time: ", (end_time - start_time) / 1000.0, " ms");
	
	parent.action(result);
	
