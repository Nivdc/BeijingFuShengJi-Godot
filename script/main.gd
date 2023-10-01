extends Node

signal game_core_readied
signal game_started
var core = null


func _ready():
	randomize()#初始化随机数种子
	self.set_process(false)#禁用帧处理，不需要这个
	# $MainContainer.hide()#暂时隐藏主窗口内容，等待游戏开始

	# 搞了半天你跟我说主窗口不能隐藏？...行，我忍了，这个也不是很重要吧。
	# self.get_window().hide()
	# self.connect("game_started",func():self.get_window().show())
	self.connect("game_started",func():$MainContainer.show())

	self.connect("game_core_readied",func():$IntroWindow.emit_signal("game_core_readied"))
	core = preload("res://script/core/game_core.gd").new(self)

	update_tree()


func update_tree():
	var good_tree = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Tree
	good_tree.clear()
	good_tree.set_column_title(0, "商品")
	good_tree.set_column_title(1, "黑市价格")
	good_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	good_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	var root = good_tree.create_item()
	for good in core.goods_list:
		if good["is_active"] == true:
			var good_treeitem = good_tree.create_item(root)
			good_treeitem.set_text(0, good["name"])
			good_treeitem.set_text(1, str(good["price"]))
			good_treeitem.set_tooltip_text(0, " ")
			good_treeitem.set_tooltip_text(1, " ")
