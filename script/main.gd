extends Node

signal game_core_readied
signal game_started
var core = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()#初始化随机数种子
	self.set_process(false)#禁用帧处理，不需要这个

	# 搞了半天你跟我说主窗口不能隐藏？...行，我忍了，这个也不是很重要吧。
	# self.get_window().hide()
	# self.connect("game_started",func():self.get_window().show())

	self.connect("game_core_readied",func():$IntroWindow.emit_signal("game_core_readied"))
	core = preload("res://script/core/game_core.gd").new(self)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
