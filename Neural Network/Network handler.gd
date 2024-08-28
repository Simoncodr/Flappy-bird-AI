extends Node

# This script must be autoloaded for anything for anything to work

var AMOUNT : int = 100 # Amount of actors per generation
var POPULATION : Array[Variant] # Stores each actor for whatever use
var POPUlATIONSCORE : PackedFloat32Array # Score of each actor 
var POPULATIONWEIGHTS : Array = [] # Stores all the weights of each actor in an array
var MUTATION_RATE : float = 0.3 # Determins how much the weights mutate after each generation
var GENERATION : int = 1 # Number of generations passed

var input : int = 3 # NOTE The number of inputs
var hidden_layers : PackedInt32Array = [8, 8] #NOTE The numbers specify how many nodes are in each layer
var output : int = 2 # NOTE The number of outputs


# Calculates the fitness of each actor, by looking at its score
# This function calculates the fitness of each actor by evaluating its score.
# It determines the top performers and adjusts the mutation rate for the neural network.
func evaluateFitness() -> void:
	var value_index_pairs : Array = [] # Stores pairs of scores and their corresponding indices
	
	# Populates the value_index_pairs array with scores and their indices from the population
	for i in range(Network.POPUlATIONSCORE.size()):
		value_index_pairs.append([Network.POPUlATIONSCORE[i], i])
	
	var top_count : float = min(10, value_index_pairs.size()) # Determines how many top scores to consider
	var top_values : PackedFloat32Array = [] # Stores the top scores
	var top_indices : PackedFloat32Array = [] # Stores the indices of the top scores
	
	# Initializes the top_values and top_indices arrays with default values
	for i in range(top_count):
		top_values.append(0)
		top_indices.append(-1)
	
	# Identifies the top scores and their corresponding indices
	for value_index_pair in value_index_pairs:
		var value : float = value_index_pair[0] # Extracts the score
		var index : float = value_index_pair[1] # Extracts the index
		
		# Inserts the value into the correct position in the top_values array
		for j in range(top_count):
			if value > top_values[j]:
				# Shifts lower values down the list to make space for the new top value
				for k in range(top_count - 1, j, -1):
					top_values[k] = top_values[k - 1]
					top_indices[k] = top_indices[k - 1]
				
				# Inserts the new top value and its index
				top_values[j] = value
				top_indices[j] = index
				break
	
	# Calculates the average of the top scores
	var total_score : float = 0
	for i in range(top_count):
		total_score += top_values[i]
	
	# Adjusts the mutation rate based on the average top score
	total_score /= top_values.size()
	Network.MUTATION_RATE = (1 - sigmoid(total_score, 12000)) + 0.005
	
	# Stores the indices of the top performers for future reference
	var store_indices : Array = []
	store_indices.append_array(trimStoredIndices(top_indices, top_values))
	
	# Clears the population scores and sends the indices of the best performing actors to the next phaze of the network
	Network.POPUlATIONSCORE.clear()
	getWeights(store_indices)


# Sigmoid function (It takes the given number and turns it into a number between 0 and 1)
# This Sigmoid function as a crucial change in the form of a "bias"
# This bias is not the same as normally uses in neural networks, but is to help lower the mutation rate.
# The bias can, and should, be changed depending on the situation to get the best mutation curve possible for the situration
func sigmoid(x: float, bias : float) -> float:
	x /= bias
	return 1.0 / (1.0 + exp(-x))


# Replaces specific indices if the score assosiated is 3 times lower than the best performing actor
# This speeds up learning if one or more actors de exeptionally well
func trimStoredIndices(indices : Array, scores) -> Array:
	var base_value : int = scores[0]  
	for i in range(indices.size()):
		if (scores[i] * 3) < base_value:
			indices[i] = indices[0]
	return indices


# This function retrieves the weights of the top-performing actors based on their indices.
# It then clears the current population weights and prepares the new weights for mutation.
func getWeights(indices: Array) -> void:
	var best_weights : Array = [] # Array to store the weights of the top performing actors
	
	# Loops through the given indices and collect the corresponding weights from the population
	for i in range(indices.size()):
		best_weights.append(Network.POPULATIONWEIGHTS[indices[i]])
	
	# Clears the current population weights to prepare for the next generation
	Network.POPULATIONWEIGHTS.clear()
	
	# Mutates the collected weights to generate a new set of weights for the population
	mutateWeights(best_weights)


# This function mutates the weights of the top-performing actors to generate a new set of weights
# for the next generation. This is the secret sauce that actuallly makes the network learn
func mutateWeights(new_weights : Array) -> void:
	# Loops through each set of weights in the provided new_weights array
	for i in range(new_weights.size()):
		var mutatingWeights: Array = [] # Temporary array to hold weights for mutation
		mutatingWeights.append_array(new_weights[i]) # Copy the current set of weights
		
		# Prepares the weight arrays one at a time for mutation
		for j in range(new_weights.size()):
			var mutationWeights : Array = [] # Array to store the mutated weights
			mutationWeights.append_array(mutatingWeights) # Copy the weights to be mutated
			
			# Applies mutation to each weight in the current set
			for k in range(mutationWeights.size()):
				var mutation : float = 1 + (1 * randf_range(-Network.MUTATION_RATE, Network.MUTATION_RATE))
				mutationWeights[k] *= mutation # Mutates the weight
			
			# Adds the mutated weights to the population weights
			Network.POPULATIONWEIGHTS.append(mutationWeights)
	
	# Clear the current population and increment the generation count. Now the cycle can repeat
	Network.POPULATION.clear()
	Network.GENERATION += 1

# Saves the data to a txt file
func _input(_event):
	if Input.is_action_just_pressed("save"):
		var actor : Variant = POPULATION[0]
		var weights : PackedFloat32Array = POPULATIONWEIGHTS[actor.number]
		
		var path : String = "res://Neural Network/Data.json"
		var file = FileAccess.open(path, FileAccess.WRITE)
		
		# Prepare the nodes array
		var nodes : Array[int] = []
		nodes.append(input)
		for i in range(hidden_layers.size()):
			nodes.append(hidden_layers[i])
		nodes.append(output)
		
		# Prepare the weights array
		var weights_array : Array = []
		for i in range(weights.size()):
			weights_array.append(weights[i])
		
		# Create a dictionary to store nodes and weights
		var data_dict : Dictionary = {
			"nodes": nodes,
			"weights": weights_array
		}
		
		# Convert the dictionary to a JSON string
		var data_string : String = JSON.stringify(data_dict)
		
		# Write the JSON string to the file
		file.store_string(data_string)
		
		# Close the file
		file.close()
		
		print("Network saved!")


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
