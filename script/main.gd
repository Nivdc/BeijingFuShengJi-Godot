extends Node

signal game_core_readied
signal game_started
signal game_core_updated
signal message_with_diary_window(message: String)
signal message_with_news_window(message: String)
var core = null
var child_window_queue = []
var current_child_window = null

func _ready():
	randomize()#初始化随机数种子

	self.connect("game_core_readied",func():$IntroWindow.emit_signal("game_core_readied"))
	core = preload("res://script/core/game_core.gd").new(self)

	# 搞了半天你跟我说主窗口不能隐藏？...行，我忍了，这个也不是很重要吧。
	# self.get_window().hide()
	# self.connect("game_started",func():self.get_window().show())

	# 那就暂时隐藏主窗口里的内容，等待游戏开始
	$MainContainer.hide()
	self.connect("game_started",func():$MainContainer.show())

	self.connect("game_core_updated", self.update_gui)

	self.connect("message_with_diary_window", self._setup_diary_window)
	self.connect("message_with_news_window", self._setup_news_window)

	# core.add_cash(9999999)
	# core.reduce_health(10)

	update_gui()
	_init_buttons()


func update_gui():
	_update_trees()
	_update_player_status()


func play_sound(sound_name: String):
	var sound = load("res://resource/sound/" + sound_name)
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()


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
	var popup_menu = $MainContainer/NavBar/MenuBar/系统
	popup_menu.id_pressed.connect(self._popup_menu_click)

	var buy_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer/VBoxContainer/Button
	buy_button.pressed.connect(self._setup_buy_window)
	var sell_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer2/VBoxContainer/Button
	sell_button.pressed.connect(self._setup_sell_window)

	var location_buttons = get_tree().get_nodes_in_group("location_buttons")
	for location_button in location_buttons:
		location_button.pressed.connect(func():self._move_to(location_button.text))

	var bank_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer3/Button
	bank_button.pressed.connect(self._setup_bank_window)
	var hospital_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer3/Button2
	hospital_button.pressed.connect(self._setup_hospital_window)
	var post_office_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer3/Button3
	post_office_button.pressed.connect(self._setup_post_office_window)
	var	rental_agency_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer3/Button4
	rental_agency_button.pressed.connect(self._setup_rental_agency_window)
	var cybercafe_button = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer3/Button5
	cybercafe_button.pressed.connect(self._setup_cybercafe_window)


func _popup_menu_click(id: int):
	match id:
		0:
			core.restart_game()
		1:
			get_tree().quit()


func _setup_diary_window(message: String):
	var diary_window_scene = preload("res://scene/diary_window.tscn")
	var new_diary_window = diary_window_scene.instantiate()
	new_diary_window.set_text(message)
	if current_child_window == null:
		new_diary_window.show()
		self.add_child(new_diary_window)
		current_child_window  = new_diary_window
		current_child_window.close_requested.connect(_child_window_closed)
	else:
		child_window_queue.push_back(new_diary_window)


func _setup_news_window(message: String):
	var news_window_scene = preload("res://scene/news_window.tscn")
	var new_news_window = news_window_scene.instantiate()
	new_news_window.set_text(message)
	if current_child_window == null:
		new_news_window.show()
		self.add_child(new_news_window)
		current_child_window  = new_news_window
		current_child_window.close_requested.connect(_child_window_closed)
	else:
		child_window_queue.push_back(new_news_window)


func _child_window_closed():
	if child_window_queue.is_empty():
		current_child_window = null
	else:
		var new_child_window = child_window_queue.pop_front()
		new_child_window.show()
		self.add_child(new_child_window)
		current_child_window  = new_child_window
		current_child_window.close_requested.connect(_child_window_closed)

	core.event_ended.emit()


func _setup_buy_window():
	var good_tree = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Tree
	var selected_good = good_tree.get_selected()
	if selected_good == null:
		self.message_with_diary_window.emit("我还没有选定买什么物品呢。")
		return
	
	var good_price = selected_good.get_text(1) as int # 获取第二列的价格
	if good_price > core.player_status["cash"]:
		if core.player_status["bank_deposit_amount"] > 0:
			self.message_with_diary_window.emit("俺带的现金不够，去银行提点钱吧。")
		else:
			self.message_with_diary_window.emit("俺的现金不够，银行又没有存款，咋办哩?")		
		return

	var good_name = selected_good.get_text(0)
	$BuyWindow.set_target_good_name_and_price(good_name, good_price)
	$BuyWindow.show()


func _setup_sell_window():
	var storage_tree = $MainContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Tree
	var selected_good = storage_tree.get_selected()
	if selected_good == null:
		self.message_with_diary_window.emit("我还没有选定卖什么物品呢。")
		return

	var good_name = selected_good.get_text(0)
	$SellWindow.set_target_good_name(good_name)
	$SellWindow.show()


func _move_to(location_name: String):
	core.move(location_name)
	play_sound("shutdoor.wav")

func _setup_bank_window():
	$BankWindow.set_game_core(core)
	$BankWindow.show()
	play_sound("opendoor.wav")


func _setup_hospital_window():
	if core.player_status["health"] < core.environment_settings["max_health"]:
		$HospitalWindow.set_game_core(core)
		$HospitalWindow.show()
	else:
		self.message_with_diary_window.emit("小护士笑咪咪地望着俺：\"大哥！神经科这边挂号.\"")

	play_sound("opendoor.wav")


func _setup_post_office_window():
	var player_debt           = core.player_status["debt_amount"]
	var player_cash           = core.player_status["cash"]
	var player_bank_deposit   = core.player_status["bank_deposit_amount"]
	var player_total_property = player_cash + player_bank_deposit
	if player_debt > 0 :
		$PostOfficeWindow.set_player_debt_and_total_property(player_debt, player_cash)
		$PostOfficeWindow.show()
	elif player_debt == 0 :
		if player_total_property < 1_000 :
			self.message_with_diary_window.emit("村长嘿嘿笑道：“你没钱,有神经病!”")
		elif player_total_property > 1_000 and player_total_property < 100_000:
			self.message_with_diary_window.emit("村长朝俺点头：\"兄弟,您想支援家乡1000元吗？\"")
		elif player_total_property > 100_000 and player_total_property < 10_000_000:
			self.message_with_diary_window.emit("村长在电话中朝俺鞠躬:\"富豪!我想把我女儿嫁给您.\"...")
		elif player_total_property > 10_000_000:
			self.message_with_diary_window.emit("村长在电话中朝俺下跪，说：\"您简直是我亲爹！\"")
		# may this happen? I think never.
		else:
			self.message_with_diary_window.emit("村长说：\"您是农村年轻人的典范！\"")
	
	play_sound("opendoor.wav")


func _setup_rental_agency_window():
	var current_storage_size = core.player_status["storage_size"]
	if current_storage_size >= 140:
		self.message_with_diary_window.emit("中介说，您的房子比局长的还大!还租房?")
		return
	
	var player_cash = core.player_status["cash"]
	if  player_cash < 30000:
		self.message_with_diary_window.emit("中介说，您没有三万现金就想租房? 一边凉快去!")
		return
	else:
		var price = 0
		if player_cash <= 30000 :
			price = 25000
		else:
			price = player_cash/2 + 2000
		$RentalAgencyWindow.set_price_and_storage_size(price, current_storage_size)
		$RentalAgencyWindow.show()


var cybercafe_enter_count := 0
func _setup_cybercafe_window():
	if cybercafe_enter_count < 2:
		$CybercafeWindow.show()
		cybercafe_enter_count+=1
	elif core.player_status["cash"] < 15:
		self.message_with_diary_window.emit("进网吧至少身上要带15元，呵呵，取钱再来。")
	else:
		self.message_with_diary_window.emit("村长放出话来：你别总是在网吧里鬼混，快去做正经买卖! ")
