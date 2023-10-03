extends Node

signal game_core_readied
signal game_started
signal game_core_updated
var core = null


func _ready():
	randomize()#初始化随机数种子
	self.set_process(false)#禁用帧处理，不需要这个

	self.connect("game_core_readied",func():$IntroWindow.emit_signal("game_core_readied"))
	core = preload("res://script/core/game_core.gd").new(self)

	# 搞了半天你跟我说主窗口不能隐藏？...行，我忍了，这个也不是很重要吧。
	# self.get_window().hide()
	# self.connect("game_started",func():self.get_window().show())

	# 那就暂时隐藏主窗口里的内容，等待游戏开始
	# $MainContainer.hide()
	self.connect("game_started",func():$MainContainer.show())

	self.connect("game_core_updated", self.update_gui)

	core.add_good("《上海小宝贝》（禁书）",100)
	update_gui()
	_init_buttons()


func update_gui():
	_update_trees()
	_update_player_status()


func _update_trees():
	var good_tree = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Tree
	good_tree.clear()
	good_tree.set_column_title(0, "商品")
	good_tree.set_column_title(1, "黑市价格")
	good_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	good_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	var good_tree_root = good_tree.create_item()
	for good in core.goods_list:
		if good["is_active"] == true:
			var good_treeitem = good_tree.create_item(good_tree_root)
			good_treeitem.set_text(0, good["name"])
			good_treeitem.set_text(1, str(good["price"]))
			good_treeitem.set_tooltip_text(0, " ")
			good_treeitem.set_tooltip_text(1, " ")

	var storage_tree_title_label = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Label
	storage_tree_title_label.set_text("您的出租屋( %d/%d )" % [core.player_status["used_storage_size"], core.player_status["storage_size"]])
	var storage_tree = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Tree
	storage_tree.clear()
	storage_tree.set_column_title(0, "商品")
	storage_tree.set_column_title(1, "买进价格")
	storage_tree.set_column_title(2, "数量")
	storage_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	storage_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	storage_tree.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_LEFT)
	# storage_tree.set_column_custom_minimum_width （这一行留待后用)
	var storage_tree_root = storage_tree.create_item()
	for good_name in core.player_status["storage"].keys():
		var storage_treeitem = storage_tree.create_item(storage_tree_root)
		storage_treeitem.set_text(0, good_name)
		storage_treeitem.set_text(1, str(core.player_status["storage"][good_name]["record_price"]))
		storage_treeitem.set_text(2, str(core.player_status["storage"][good_name]["number"]))
		storage_treeitem.set_tooltip_text(0, " ")
		storage_treeitem.set_tooltip_text(1, " ")
		storage_treeitem.set_tooltip_text(2, " ")

func _update_player_status():
	var player_status_labels = get_tree().get_nodes_in_group("player_status_labels")
	# 还是难逃一死，我擦...
	player_status_labels[0].set_text("现金: %d 元" % core.player_status["cash"])
	player_status_labels[1].set_text("存款: %d 元" % core.player_status["bank_deposit_amount"])
	player_status_labels[2].set_text("欠债: %d 元" % core.player_status["debt_amount"])
	player_status_labels[3].set_text("健康: %d %%"  % core.player_status["health"])
	player_status_labels[4].set_text("名声: %d %%"  % core.player_status["reputation"])

	var storage_info_label = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Label
	storage_info_label.set_text("您的出租屋( %d/%d )" % [core.player_status["used_storage_size"], core.player_status["storage_size"]])


func _init_buttons():
	var location_buttons = get_tree().get_nodes_in_group("location_buttons")
	for location_button in location_buttons:
		location_button.pressed.connect(func():core.move(location_button.text))
