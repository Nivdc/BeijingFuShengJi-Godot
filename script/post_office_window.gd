extends Window

@onready var info_label =  $MarginContainer/VBoxContainer/Label
@onready var default_info_text = info_label.get_text()
@onready var line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

var max_repayment_amount = null

func set_player_debt_and_total_property(player_debt, player_cash):
	var new_info = default_info_text % player_debt
	if player_cash < player_debt:
		new_info += "\n村长老婆狂吞“雪中丐”补钙片，冷笑道：“你还得起吗?”"
	info_label.set_text(new_info)
	max_repayment_amount = player_cash if player_cash < player_debt else player_debt
	line_edit.set_text(str(max_repayment_amount))


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(max_repayment_amount != null, "Error: no good selected.")
	if line_edit.get_text().is_valid_int() == true:
		var repayment_amount = line_edit.get_text() as int
		if repayment_amount <= max_repayment_amount:
			get_parent().core.repay_debt(repayment_amount)
			get_parent().emit_signal("game_core_updated")
			self.emit_signal("close_requested")
		else:
			print("请输入上限内的数量")
	else:
		print("请输入数字")


func _cancel():
	self.emit_signal("close_requested")
