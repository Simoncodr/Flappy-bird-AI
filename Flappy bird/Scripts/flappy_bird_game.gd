extends Control

@onready var score : Label = $VBoxContainer/score
@onready var generation : Label = $VBoxContainer/generation
@onready var bird_amount : Label = $"VBoxContainer/bird amount"
@onready var visualizer : PackedScene = preload("res://Neural Network/Network_visualization.tscn")
var Pipes = preload("res://Flappy bird/Scenes/pipes.tscn")
var Birds = preload("res://Flappy bird/Scenes/bird.tscn")

var birdVelocity : float = 0
var distanceToCenter : float = 0
var distanceToPipe : float = 0
var SCORE : int = 0
var PIPES : Array

var game_state : String = "learn" # learn or preset


func _ready() -> void:
	if game_state == "learn":
		createBirds()
		#addVisualizer()
	else:
		createBird()
	createPipes()

func addVisualizer():
	var viz = visualizer.instantiate()
	add_child(viz)

func _process(_delta) -> void:
	score.text = "SCORE: " + str(SCORE)
	generation.text = "GENERATION: " + str(Network.GENERATION)
	bird_amount.text = "BIRD AMOUNT: " +str(Network.POPULATION.size())
	reload()

func createPipes():
	var pipes_instance = Pipes.instantiate()
	add_child(pipes_instance)
	PIPES.append(pipes_instance)

func _on_timer_timeout() -> void:
	createPipes()

func createBirds() -> void:
	for i in Network.AMOUNT:
		var bird = Birds.instantiate()
		Network.POPULATION.append(bird)
		Network.POPUlATIONSCORE.append(0)
		bird.number = i
		bird.global_position = Vector2(100, get_viewport().get_visible_rect().size.y/2)
		add_child(bird)

func createBird() -> void:
	var bird = Birds.instantiate()
	bird.global_position = Vector2(100, get_viewport().get_visible_rect().size.y/2)
	Network.POPULATION.append(bird)
	Network.POPUlATIONSCORE.append(0)
	bird.game_state = "preset"
	bird.number = 0
	add_child(bird)

func reload() -> void:
	if Network.POPULATION.size() == 0:
		if game_state == "learn":
			Network.evaluateFitness()
		get_tree().reload_current_scene()
