extends Label

func _ready():
	updateText("0.10")

func updateText(value : String):
	text = value
