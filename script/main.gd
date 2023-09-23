extends Node

signal game_started

@onready var core := preload("res://script/core/game_core.gd").new(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("game_started",func():print("hello,world"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func test():
	print("test")
