class_name AI extends Node

# This is for the trained dataset. This cannot be used for learning, but will read from any predefined JSON file, with stored data
# The data must be trained with the training network that comes alongside this program, as it's structure does not follow normal standards

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var data : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var parent : Variant = get_parent() # References the parent node (the actor using this network)
var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes

@onready var network_input : int
@onready var network_hidden_layers : PackedInt32Array
@onready var network_output : int

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
	presetConnection()
	findLargest()


# This function does the dirtywork and determins the output based on the input and weights
func neuralNetwork() -> PackedFloat32Array:
	var weights_position: int = 0
	var temp_data: PackedFloat32Array = PackedFloat32Array()
	
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


# ReLU function (It takes in a number, and returns it. Unless it's negative, in which case it returns 0)
func relu(x: float) -> float:
	return max(0.0, x)


# Runs the network every frame and send the information to the actor
func _process(_delta) -> void:
	parent.action(neuralNetwork())


# Load the trained data into the actor
func presetConnection():
	weights.append_array(dataFromJSON()["weights"])
	network_input = dataFromJSON()["nodes"][0]
	for i in range(1, dataFromJSON()["nodes"].size() - 1):
		network_hidden_layers.append(dataFromJSON()["nodes"][i])
	network_output = dataFromJSON()["nodes"][-1]


# Collects stored data from the JSON file
func dataFromJSON() -> Dictionary:
	var final_output : Dictionary = {}
	var path : String = "res://Neural Network/Data.json"
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_string : String = file.get_as_text().strip_edges()
		
		# Reades the data, and collects it from the dictionary
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var json_data : Dictionary = json.get_data()
			final_output["nodes"] = json_data.get("nodes", [])
			final_output["weights"] = json_data.get("weights", [])
		file.close()
	
	# Returns the data in a dictionary
	return final_output
