extends Control

@onready var score : Label = $VBoxContainer/score
@onready var generation : Label = $VBoxContainer/generation
var Pipes = preload("res://Flappy bird/Scenes/pipes.tscn")
var Birds = preload("res://Flappy bird/Scenes/bird.tscn")

var birdVelocity : float = 0
var distanceToCenter : float = 0
var distanceToPipe : float = 0

var population_size = 100
var mutation_rate = 0.1
var tempArray : Array


func _ready() -> void:
	createBirds()
	createPipes()

func _process(_delta) -> void:
	score.text = "SCORE: " + str(Game.SCORE)
	generation.text = "GENERATION: " + str(Game.GENERATION)
	reload()

func createPipes():
	var pipes_instance = Pipes.instantiate()
	add_child(pipes_instance)
	Game.Pipes.append(pipes_instance)

func _on_timer_timeout() -> void:
	createPipes()

func createBirds() -> void:
	for i in Game.AMOUNT:
		var bird = Birds.instantiate()
		Game.POPULATION.append(bird)
		Game.POPUlATIONSCORE.append(0)
		#Game.POPULATIONWHEIGTS.append(tempArray)
		bird.number = i
		bird.global_position = Vector2(100, get_viewport().get_visible_rect().size.y/2)
		add_child(bird)


func reload() -> void:
	if Game.POPULATION.size() == 0:
		Game.Pipes.clear()
		evaluateFitness()
		clearPopulationMemory()
		Game.SCORE = 0
		#await get_tree().create_timer(0.1).timeout
		Game.GENERATION += 1
		get_tree().reload_current_scene()


func evaluateFitness() -> void:
	var value_index_pairs : Array = []
	for i in range(Game.POPUlATIONSCORE.size()):
		value_index_pairs.append([Game.POPUlATIONSCORE[i], i])
	
	var top_count : float = min(10, value_index_pairs.size())
	var top_values : Array[float] = []
	var top_indices : Array[float] = []
	
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
	Game.MUTATION_RATE = (1 - sigmoid(total_score, 8000)) + 0.005
	print("Mutation rate: ", Game.MUTATION_RATE)
	
	var store_indices : Array = []
	store_indices.append_array(trimStoredIndices(top_indices, top_values))
	#store_indices.append_array(top_indices)
	Game.POPUlATIONSCORE.clear()
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
		best_weights.append(Game.POPULATIONWHEIGTS[indices[i]])
	#print("POPULATION WHEIGHTS: ", Game.POPULATIONWHEIGTS)
	#print("Stored weights: ", best_weights[1])
	Game.POPULATIONWHEIGTS.clear()
	mutateWeights(best_weights)

func mutateWeights(new_weights : Array) -> void:
	#print("Weights before: ", Game.POPULATIONWHEIGTS)
	for i in 10:
		var mutatingWeights: Array
		mutatingWeights.append_array(new_weights[i])
		for j in 10:
			var mutationWeights : Array
			mutationWeights.append_array(mutatingWeights)
			for k in range(mutationWeights.size()):
				var mutation : float = 1 + (1 * randf_range(-Game.MUTATION_RATE, Game.MUTATION_RATE))
				mutationWeights[k] *= mutation
			Game.POPULATIONWHEIGTS.append(mutationWeights)
	#print("Weights after: ", Game.POPULATIONWHEIGTS[1][1])

func clearPopulationMemory() -> void:
	Game.POPULATION.clear()
