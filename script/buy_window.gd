extends Window


# 写这么多单独的window脚本似乎是一种不祥之兆...
# 我决定在所有设计里挑一种最垃圾的出来，先做了再说，
# 你觉得你写的好，那你来，写完了记得给我推个PR。
@onready var info_label =  $MarginContainer/VBoxContainer/Label
@onready var default_info_text = info_label.get_text()
@onready var line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

var taget_good_name = null
var buying_limit = null


func set_target_good_name_and_price(good_name: String, good_price: int):
	var player_status = get_parent().core.player_status
	var player_cash = player_status["cash"]
	var unused_storage_size = player_status["storage_size"] - player_status["used_storage_size"]
	taget_good_name = good_name
	buying_limit = player_cash/good_price if player_cash/good_price <= unused_storage_size else unused_storage_size
	info_label.set_text(default_info_text % [player_cash, buying_limit, taget_good_name])
	line_edit.set_text(str(buying_limit)) 


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(taget_good_name != null, "Error: no good selected.")
	assert(buying_limit != null, "Error: buying_limit not calculated")
	if line_edit.get_text().is_valid_int() == true:
		var buying_quantity = line_edit.get_text() as int
		if buying_quantity <= buying_limit:
			get_parent().core.buy_good(taget_good_name, buying_quantity)
			get_parent().play_sound("buy.wav")
			self.emit_signal("close_requested")
		else:
			print("请输入上限内的数量")
	else:
		print("请输入数字")


func _cancel():
	self.emit_signal("close_requested")
