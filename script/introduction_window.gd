extends Window

signal game_core_readied

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("close_requested",func():self.hide())
	self.connect("game_core_readied",func():$Button.set_disabled(false))
	$Button.pressed.connect(self._start_game)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _start_game():
	emit_signal("close_requested")
	get_parent().emit_signal("game_started")
