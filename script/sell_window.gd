extends Window


@onready var info_label =  $MarginContainer/VBoxContainer/Label
@onready var default_info_text = info_label.get_text()
@onready var line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

var taget_good_name = null
var selling_limit = null

func set_target_good_name(good_name: String):
	var player_status = get_parent().core.player_status
	assert(player_status["storage"].has(good_name) == true, "Error: Try to sell an item that doesn't exist.")
	taget_good_name = good_name
	selling_limit = player_status["storage"][taget_good_name]["number"]
	info_label.set_text(default_info_text % [selling_limit, taget_good_name])
	line_edit.set_text(str(selling_limit)) 


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(taget_good_name != null, "Error: no good selected.")
	assert(selling_limit != null, "Error: selling_limit not calculated")
	if line_edit.get_text().is_valid_int() == true:
		var selling_quantity = line_edit.get_text() as int
		if selling_quantity <= selling_limit:
			get_parent().core.sell_good(taget_good_name, selling_quantity)
			self.emit_signal("close_requested")
		else:
			print("请输入上限内的数量")
	else:
		print("请输入数字")


func _cancel():
	self.emit_signal("close_requested")
