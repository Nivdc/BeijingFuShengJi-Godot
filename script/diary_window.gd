extends Window


func _ready():
	self.connect("close_requested",func():self.hide())
	var close_button = $DiaryWindow/MarginContainer/VBoxContainer/MarginContainer/button_clicked
	close_button.pressed.connect(func():self.emit_signal("close_requested"))


func set_text(txt: String):
	var txt_label = $DiaryWindow/MarginContainer/VBoxContainer/HBoxContainer/Label
	txt_label.set_text(txt)
