class_name AI extends Node

@onready var weights : PackedFloat32Array # Stores the weights for this actor
@onready var inputs : PackedFloat32Array # Stores the inputs fo use in the next layer of the network
@onready var parent : Variant = get_parent() # References the parent node (the actor using this network)

@onready var network_input : int
@onready var network_hidden_layers : PackedInt32Array 
@onready var network_output : int


# Called when the node is added to the scene.
func _ready() -> void:
	presetConnection()


# Load the trained data into the actor
func presetConnection():
	weights.append_array(dataFromJSON()["weights"])
	network_input = dataFromJSON()["nodes"][0]
	for i in range(1, dataFromJSON()["nodes"].size() - 1):
		network_hidden_layers.append(dataFromJSON()["nodes"][i])
	network_output = dataFromJSON()["nodes"][-1]


# This function does the dirtywork and determins the output based on the input and weights
func neuralNetwork() -> PackedFloat32Array:
	var final_output: PackedFloat32Array = []
	
	# Initialize necessary variables
	#var node_saver: PackedFloat32Array = [] # Saves the values for all the nodes
	var node_saver: Array[float] = [] # Saves the values for all the nodes
	var weights_position: int = 0 # Used to know what weight should be used when
	
	# Uses the inputs from the previous layer, unless it's the first one. Then i uses the data from the parent
	for i in range(network_hidden_layers.size()):
		if i != 0:
			inputs.clear()
			for j in range(network_hidden_layers[i - 1]):
				inputs.append(node_saver[-1- j])
		else:
			acquireInputData()
	
	# Loops through the layer and adds the weight and layer together to get an final value for each node
		for j in range(network_hidden_layers[i]):
			var weight: Array = []
			for k in range(inputs.size()):
				weight.append(weights[weights_position])
				weights_position += 1
			node_saver.append(node(inputs, weight))
	
	# Calculates the final output and appends it to the output array
	for i in range(network_hidden_layers[-1]):
		final_output.append(sigmoid(node_saver[i] * weights[weights_position]))
		weights_position += 1
	
	# Return the final output
	return final_output


# Handles the math for every node in the network.
# It adds together the values of the input and their respective weights into a final value
func node(input : Array, weight : Array) -> float:
	var output_node : float = 0
	for i in range(input.size()):
		output_node += input[i] * weight[i]
	return sigmoid(output_node)


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
