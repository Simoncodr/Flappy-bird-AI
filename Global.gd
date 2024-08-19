extends Node

var STATE : String = "AI" # PLAYER, AI
var SCORE : int = 0
var AMOUNT : int = 100
var GENERATION : int = 1

var POPULATION : Array[Variant] 
var POPUlATIONSCORE : Array[float]
var POPULATIONWHEIGTS : Array = []
var MUTATION_RATE : float = 0.1

var Pipes : Array
