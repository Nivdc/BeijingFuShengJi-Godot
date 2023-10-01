extends Window

signal game_core_readied

func _ready():
	self.set_process(false)#禁用帧处理，不需要这个
	self.connect("close_requested",func():self.hide())
	self.connect("game_core_readied",func():$Button.set_disabled(false))
	$Button.pressed.connect(self._start_game)


func _start_game():
	emit_signal("close_requested")
	get_parent().emit_signal("game_started")
