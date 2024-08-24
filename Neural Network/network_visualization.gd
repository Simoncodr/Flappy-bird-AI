extends Control

@onready var manager : HBoxContainer = $HBoxContainer
@onready var network_node : PackedScene = preload("res://Neural Network/node.tscn")
var nodes : Array[Variant]
var input : Array[Variant]
var output : Array[Variant]
var actor : RigidBody2D


func _ready():
	getActor()
	createVisualizationNodes()

func getActor():
	if Network.POPULATION.size() > 0:
		actor = Network.POPULATION[0]

func createVisualizationNodes():
	# For inputs
	var inputs = VBoxContainer.new()
	inputs.alignment = BoxContainer.ALIGNMENT_CENTER
	inputs.add_theme_constant_override("separation", 30)
	for i in range(3):
		var node = network_node.instantiate()
		input.append(node)
		inputs.add_child(node)
	manager.add_child(inputs)
	
	# For hidden layers
	for i in range(Network.hidden_layers.size()):
		var hidden_layers = VBoxContainer.new()
		hidden_layers.add_theme_constant_override("separation", 30)
		hidden_layers.alignment = BoxContainer.ALIGNMENT_CENTER
		for j in range(Network.hidden_layers[i]):
			var node = network_node.instantiate()
			nodes.append(node)
			hidden_layers.add_child(node)
		manager.add_child(hidden_layers)
	
	# For output
	var outputs = VBoxContainer.new()
	outputs.alignment = BoxContainer.ALIGNMENT_CENTER
	outputs.add_theme_constant_override("separation", 30)
	for i in range(Network.output[0]):
		var node = network_node.instantiate()
		output.append(node)
		outputs.add_child(node)
	manager.add_child(outputs)

func changeNodeValues():
	# Input layers
	var input_data : PackedFloat32Array = actor.gatherData()
	for i in range(3):
		var value = input_data[i]
		var int_value = int(value) 
		var formatted_value = str(int_value)
		input[i].updateText(formatted_value)
	
	# Hidden layers
	for i in range(nodes.size()):
		var value = actor.get_node("NetworkNode").node_saver[i]
		var formatted_value = String("%0.2f" % value) 
		nodes[i].updateText(formatted_value)
	
	# Output layers
	var output_data = actor.get_node("NetworkNode").neuralNetwork()
	for i in range(Network.output[0]):
		var value = output_data[i]
		var formatted_value = String("%0.2f" % value) 
		output[i].updateText(formatted_value)


func _process(_delta):
	getActor()
	$Label.text = "Actor number: " + str(actor.number)
	changeNodeValues()
