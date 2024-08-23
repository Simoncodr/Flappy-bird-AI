extends Node

var AMOUNT : int = 100
var POPULATION : Array[Variant] 
var POPUlATIONSCORE : Array[float]
var POPULATIONWEIGHTS : Array = []
var MUTATION_RATE : float = 0.3
var GENERATION : int = 1

func evaluateFitness() -> void:
	var value_index_pairs : Array = []
	for i in range(Network.POPUlATIONSCORE.size()):
		value_index_pairs.append([Network.POPUlATIONSCORE[i], i])
	
	var top_count : float = min(10, value_index_pairs.size())
	var top_values : PackedFloat32Array
	var top_indices : PackedFloat32Array
	
	for i in range(top_count):
		top_values.append(float("-inf"))
		top_indices.append(-1)
	
	for value_index_pair in value_index_pairs:
		var value : float = value_index_pair[0]
		var index : float = value_index_pair[1]
		
		for j in range(top_count):
			if value > top_values[j]:
				for k in range(top_count - 1, j, -1):
					top_values[k] = top_values[k - 1]
					top_indices[k] = top_indices[k - 1]
				
				top_values[j] = value
				top_indices[j] = index
				break
	
	var total_score : float
	for i in range(top_count):
		print("Original Position: ", top_indices[i], ":  SCORE: ", top_values[i])
		total_score += top_values[i]
		#TODO bestemme en formel der ændre mutation ud fra den gennemsnitslige score.
	total_score /= top_values.size()
	Network.MUTATION_RATE = (1 - sigmoid(total_score, 12000)) + 0.005
	print("Mutation rate: ", Network.MUTATION_RATE)
	
	var store_indices : Array = []
	store_indices.append_array(trimStoredIndices(top_indices, top_values))
	#store_indices.append_array(top_indices)
	Network.POPUlATIONSCORE.clear()
	print("Stored indices: ", store_indices)
	getWeights(store_indices)

func sigmoid(x: float, bias : float) -> float:
	x /= bias
	return 1.0 / (1.0 + exp(-x))

#TODO Få dette til at virke bedere + tilføjelse af variabel mutationsrate
func trimStoredIndices(indices : Array, scores) -> Array:
	var base_value : int = scores[0]  
	print("Highest value: ", base_value)
	for i in range(indices.size()):
		if (scores[i] * 3) < base_value:
			print("To change: ", indices[i], "  The high value: ", base_value)
			indices[i] = indices[0]
	return indices


func getWeights(indices: Array) -> void:
	var best_weights : Array = []
	for i in range(indices.size()):
		best_weights.append(Network.POPULATIONWEIGHTS[indices[i]])
	Network.POPULATIONWEIGHTS.clear()
	mutateWeights(best_weights)

func mutateWeights(new_weights : Array) -> void:
	for i in range(new_weights.size()):
		var mutatingWeights: Array
		mutatingWeights.append_array(new_weights[i])
		for j in range(new_weights.size()):
			var mutationWeights : Array
			mutationWeights.append_array(mutatingWeights)
			for k in range(mutationWeights.size()):
				var mutation : float = 1 + (1 * randf_range(-Network.MUTATION_RATE, Network.MUTATION_RATE))
				mutationWeights[k] *= mutation
			Network.POPULATIONWEIGHTS.append(mutationWeights)
	Network.POPULATION.clear()
	Network.GENERATION += 1
