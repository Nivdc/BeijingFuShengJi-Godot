extends Window


@onready var info_label =  $MarginContainer/VBoxContainer/Label
@onready var default_info_text = info_label.get_text()

var cost_price = null
var increased_size = 10


func set_price_and_storage_size(price: int, current_storage_size: int):
	cost_price = price
	info_label.set_text(default_info_text % [current_storage_size, price, current_storage_size + increased_size])


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(cost_price != null, "Error: no price entered.")
	assert(get_parent().core.player_status["cash"] > cost_price, "Error: cost_price calculation error.")
	get_parent().core.reduce_cash(cost_price)
	get_parent().core.add_storage_size(increased_size)
	# 我日...
	get_parent().emit_signal("message_with_diary_window", "我的房子可以放%d个物品了!可是，好像中介公司骗了我一些钱..." % get_parent().core.player_status["storage_size"])
	get_parent().emit_signal("game_core_updated")
	self.emit_signal("close_requested")



func _cancel():
	get_parent().emit_signal("message_with_diary_window", "呵! 小心为妙! 传闻北京有的租房中介公司很能骗人....")
	self.emit_signal("close_requested")
