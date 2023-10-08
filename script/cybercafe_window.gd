extends Window


func _ready():
	self.connect("close_requested",func():self.leave_cybercafe())
	var close_button = $MarginContainer/VBoxContainer/MarginContainer/Button
	close_button.pressed.connect(func():self.emit_signal("close_requested"))

func leave_cybercafe():
	self.hide()
	var random_add_cash = _random_number(10) + 1
	get_parent().core.add_cash(random_add_cash)
	var leave_message = "感谢电信改革，可以免费上网! 还挣了美国网络广告费%d元，嘿嘿!" % random_add_cash
	get_parent().emit_signal("message_with_diary_window", leave_message)
	get_parent().emit_signal("game_core_updated")

# 生成一个范围在[0,max_value)内随机数。
func _random_number(max_value: int) ->int:
	return randi() % max_value